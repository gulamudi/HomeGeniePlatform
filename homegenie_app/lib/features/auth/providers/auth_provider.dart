import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/user.dart';
import '../../../core/storage/storage_service.dart';

// Auth State
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final isAuthenticated = await StorageService.isAuthenticated();
      if (isAuthenticated) {
        final userData = await StorageService.getUser();
        if (userData != null) {
          state = state.copyWith(
            user: User.fromJson(userData),
            isLoading: false,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
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

  Future<bool> login(String phoneNumber) async {
    state = state.copyWith(isLoading: true);
    try {
      // In a real app, this would call the API to send OTP
      // For now, we just store the phone number
      await StorageService.saveData('pending_phone', phoneNumber);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<bool> verifyOtp(String phoneNumber, String otp) async {
    state = state.copyWith(isLoading: true);
    try {
      // In a real app, this would verify OTP with backend
      // For testing, we use the bypass from AppConfig

      // Create a mock user
      final user = User(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        phone: phoneNumber,
        full_name: 'Test User',
        user_type: 'customer',
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );

      // Save user data
      await StorageService.saveUser(user.toJson());
      await StorageService.setAuthenticated(true);

      state = state.copyWith(
        user: user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clearAll();
    state = const AuthState();
  }

  void updateUser(User user) {
    state = state.copyWith(user: user);
    StorageService.saveUser(user.toJson());
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});
