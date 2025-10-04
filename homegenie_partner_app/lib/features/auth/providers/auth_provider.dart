import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/models/partner.dart';
import '../../../shared/config/app_config.dart';

final apiClientProvider = Provider((ref) => ApiClient());
final storageServiceProvider = Provider((ref) => StorageService());

class AuthState {
  final bool isAuthenticated;
  final Partner? partner;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.partner,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    Partner? partner,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      partner: partner ?? this.partner,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiClient _apiClient;
  final StorageService _storage;

  AuthNotifier(this._apiClient, this._storage) : super(AuthState());

  Future<void> sendOtp(String phone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // In development mode, we just simulate OTP sending
      if (!AppConfig.enableOtpVerification) {
        await Future.delayed(const Duration(seconds: 1));
        state = state.copyWith(isLoading: false);
        return;
      }

      await _apiClient.sendOtp(phone);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // In development mode, accept any OTP
      if (!AppConfig.enableOtpVerification) {
        await Future.delayed(const Duration(seconds: 1));

        // Create a mock partner ID for development
        final partnerId = 'partner_${phone}_${DateTime.now().millisecondsSinceEpoch}';

        await _storage.savePartnerId(partnerId);
        await _storage.savePartnerPhone(phone);
        await _storage.saveAccessToken('mock_token_$partnerId');

        // For development, assume it's a new partner
        final isNewPartner = !_storage.isOnboarded();

        state = state.copyWith(
          isAuthenticated: true,
          isLoading: false,
        );

        return {
          'is_new_partner': isNewPartner,
          'partner_id': partnerId,
        };
      }

      final response = await _apiClient.verifyOtp(phone, otp);
      final data = response.data;

      await _storage.saveAccessToken(data['access_token']);
      await _storage.saveRefreshToken(data['refresh_token']);
      await _storage.savePartnerId(data['partner_id']);
      await _storage.savePartnerPhone(phone);

      _apiClient.setAuthToken(data['access_token']);

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );

      return {
        'is_new_partner': data['is_new_partner'] ?? false,
        'partner_id': data['partner_id'],
      };
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<void> loadPartner() async {
    try {
      final partnerId = _storage.getPartnerId();
      if (partnerId == null) return;

      state = state.copyWith(isLoading: true);

      final response = await _apiClient.getPartnerProfile(partnerId);
      final partner = Partner.fromJson(response.data);

      state = state.copyWith(
        isAuthenticated: true,
        partner: partner,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    _apiClient.clearAuthToken();
    state = AuthState();
  }

  Future<void> checkAuthStatus() async {
    final isLoggedIn = _storage.isLoggedIn();
    if (isLoggedIn) {
      final token = _storage.getAccessToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
        state = state.copyWith(isAuthenticated: true);
        await loadPartner();
      }
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  );
});
