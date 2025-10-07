import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/storage_service.dart';
import '../../../core/models/partner.dart';

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
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthNotifier(this._apiClient, this._storage) : super(AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    // Check if there's an existing session
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _loadUserFromSession(session);
    }

    // Listen to auth state changes
    _supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserFromSession(session);
      } else {
        state = AuthState();
      }
    });
  }

  Future<void> _loadUserFromSession(Session session) async {
    try {
      // Save access token for router/storage checks
      await _storage.saveAccessToken(session.accessToken);

      // Get user data from database
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .eq('user_type', 'partner')
          .maybeSingle();

      if (response != null) {
        // User exists - load partner profile
        final partnerId = response['id'];
        await _storage.savePartnerId(partnerId);
        await _storage.savePartnerPhone(response['phone'] ?? '');

        // Check if partner_profile exists to set onboarding flag
        final partnerProfile = await _supabase
            .from('partner_profiles')
            .select()
            .eq('user_id', partnerId)
            .maybeSingle();

        await _storage.setOnboarded(partnerProfile != null);

        print('✅ Session restored for partner: $partnerId');
        print('Partner onboarded: ${partnerProfile != null}');
        state = state.copyWith(isAuthenticated: true, isLoading: false);
      }
    } catch (e) {
      print('Error loading user from session: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Format phone number (add +91 if not present)
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      print('📱 Sending OTP to: $formattedPhone');

      // Check if phone number is already registered with different user type
      print('⏳ Checking for existing user with this phone...');
      final existingUsers = await _supabase
          .from('users')
          .select('user_type')
          .eq('phone', formattedPhone);

      if (existingUsers.isNotEmpty) {
        final existingUserType = existingUsers[0]['user_type'];
        print('📋 Found existing user with type: $existingUserType');

        if (existingUserType != 'partner') {
          final errorMsg = 'This phone number is already registered as a Customer. Please use the Customer app to login.';
          print('❌ $errorMsg');
          state = state.copyWith(isLoading: false, error: errorMsg);
          throw Exception(errorMsg);
        }
        print('✅ Phone number matches partner user type');
      } else {
        print('✅ No existing user found - new registration');
      }

      // Send OTP via Supabase Auth with partner user_type metadata
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        data: {
          'user_type': 'partner',
        },
      );

      print('✅ OTP sent successfully');
      print('🔑 Use OTP: 123456 for test number 9999999999');

      // Store pending phone
      await _storage.savePartnerPhone(formattedPhone);

      state = state.copyWith(isLoading: false);
    } catch (e) {
      print('❌ Error sending OTP: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
      rethrow;
    }
  }

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      // Format phone number
      final formattedPhone = phone.startsWith('+') ? phone : '+91$phone';

      print('🔐 Verifying OTP for: $formattedPhone');

      // Verify OTP with Supabase (same as consumer app)
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session == null) {
        throw Exception('No session returned after OTP verification');
      }

      print('✅ OTP verified successfully');

      // Check if user exists in our users table
      var existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (existingUser == null) {
        // Create new partner user (fallback if trigger didn't work)
        print('🔨 Creating new partner user...');

        final userData = {
          'id': response.user!.id,
          'phone': formattedPhone,
          'user_type': 'partner',
          'full_name': 'Partner ${formattedPhone.substring(formattedPhone.length - 4)}',
        };

        existingUser = await _supabase
            .from('users')
            .insert(userData)
            .select()
            .single();

        print('✅ Partner user created');

        // Create partner profile as well
        await _supabase
            .from('partner_profiles')
            .insert({'user_id': response.user!.id})
            .select()
            .maybeSingle();

        print('✅ Partner profile created');
      }

      // Check if partner_profile exists to determine if onboarding is needed
      final partnerProfile = await _supabase
          .from('partner_profiles')
          .select()
          .eq('user_id', response.user!.id)
          .maybeSingle();

      bool isNewPartner = partnerProfile == null;
      print('Partner profile exists: ${partnerProfile != null}');

      // Save partner ID and access token for router/storage checks
      await _storage.savePartnerId(response.user!.id);
      await _storage.savePartnerPhone(formattedPhone);
      await _storage.saveAccessToken(response.session!.accessToken);

      // Set onboarded flag based on partner_profile existence
      await _storage.setOnboarded(partnerProfile != null);

      print('✅ Partner logged in successfully');
      print('Partner ID: ${response.user!.id}');
      print('Is new partner: $isNewPartner');

      state = state.copyWith(
        isAuthenticated: true,
        isLoading: false,
      );

      return {
        'is_new_partner': isNewPartner,
        'partner_id': response.user!.id,
      };
    } catch (e) {
      print('❌ OTP verification error: $e');
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
    await _supabase.auth.signOut();
    await _storage.clearAll();
    state = AuthState();
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _loadUserFromSession(session);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(apiClientProvider),
    ref.watch(storageServiceProvider),
  );
});
