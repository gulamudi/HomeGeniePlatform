import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/config/app_config.dart';
import 'package:shared/utils/phone_utils.dart';
import '../../../core/models/user.dart' as app_user;
import '../../../core/storage/storage_service.dart';
import '../../../core/constants/app_constants.dart';

// Auth State
class AuthState {
  final app_user.User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    app_user.User? user,
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
  final SupabaseClient _supabase = Supabase.instance.client;

  AuthNotifier() : super(const AuthState()) {
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
        state = const AuthState();
      }
    });
  }

  Future<void> _loadUserFromSession(Session session) async {
    try {
      // Store the access token for API calls
      await StorageService.setString(AppConstants.userTokenKey, session.accessToken);

      // Get user data from database
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();

      if (response != null) {
        // Check if user is an admin
        final userType = response['user_type'];
        if (userType != 'admin') {
          // This is not an admin account, sign out
          print('❌ Non-admin account detected in session, signing out');
          await _supabase.auth.signOut();
          await StorageService.clear();
          state = const AuthState();
          return;
        }

        // Convert snake_case response to camelCase for User model
        final userJson = {
          'id': response['id'],
          'email': response['email'],
          'phone': response['phone'],
          'fullName': response['full_name'],
          'avatarUrl': response['avatar_url'],
          'userType': response['user_type'],
          'createdAt': response['created_at'],
          'updatedAt': response['updated_at'],
        };

        final user = app_user.User.fromJson(userJson);
        await StorageService.setObject('user', user.toJson());
        await StorageService.setBool('authenticated', true);

        state = state.copyWith(user: user, isLoading: false);
      } else {
        // User doesn't exist in DB yet - this is handled by verifyOtp
        print('⏳ User not found in DB yet, will be created by verifyOtp');
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      print('Error loading user from session: $e');
      state = state.copyWith(isLoading: false, error: e.toString());
    }
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

  Future<Map<String, dynamic>> requestOtp({
    required String phone,
    required String userType,
  }) async {
    state = state.copyWith(isLoading: true);
    try {
      print('═════════════════════════════════════════════════');
      print('🔐 REQUEST OTP DEBUG');
      print('📱 Input phone: $phone');

      // Normalize phone number to E.164 format
      final formattedPhone = PhoneUtils.normalize(phone);
      print('📱 Normalized phone: $formattedPhone');
      print('👤 User type: $userType');
      print('═════════════════════════════════════════════════');

      // Check if phone number is already registered with different user type
      print('⏳ Checking for existing user with this phone...');
      final existingUsers = await _supabase
          .from('users')
          .select('user_type')
          .eq('phone', formattedPhone);

      if (existingUsers.isNotEmpty) {
        final existingUserType = existingUsers[0]['user_type'];
        print('📋 Found existing user with type: $existingUserType');

        if (existingUserType != userType) {
          final errorMsg = existingUserType == 'partner'
              ? 'This phone number is already registered as a Partner. Please use the Partner app to login.'
              : existingUserType == 'customer'
                  ? 'This phone number is already registered as a Customer. Please use the Customer app to login.'
                  : 'This phone number is already registered with a different account type.';
          print('❌ $errorMsg');
          state = state.copyWith(isLoading: false, error: errorMsg);
          throw Exception(errorMsg);
        }
        print('✅ Phone number matches expected user type');
      } else {
        print('✅ No existing user found - new registration');
      }

      // Send OTP via Supabase Auth with admin user_type metadata (same as partner app)
      print('⏳ Calling signInWithOtp...');
      await _supabase.auth.signInWithOtp(
        phone: formattedPhone,
        data: {
          'user_type': 'admin',
        },
      );

      print('✅ OTP sent to: $formattedPhone');
      print('🔑 Use OTP: 123456 for test number 9999999999');

      // Store pending phone and user type
      await StorageService.setString('pending_phone', formattedPhone);
      await StorageService.setString('pending_user_type', userType);

      state = state.copyWith(isLoading: false);
      return {
        'success': true,
        'phone': formattedPhone,
      };
    } catch (e) {
      print('═════════════════════════════════════════════════');
      print('❌ ERROR SENDING OTP');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      if (e is AuthApiException) {
        print('Status code: ${e.statusCode}');
        print('Error code: ${e.code}');
        print('Message: ${e.message}');
      }
      print('═════════════════════════════════════════════════');

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  Future<bool> login(String phoneNumber) async {
    state = state.copyWith(isLoading: true);
    try {
      // Normalize phone number to E.164 format
      final formattedPhone = PhoneUtils.normalize(phoneNumber);

      // Send OTP via Supabase Auth (works with test OTP from config.toml)
      await _supabase.auth.signInWithOtp(phone: formattedPhone);

      print('📱 OTP sent to: $formattedPhone');
      print('🔑 Use OTP: 123456 for test number 9999999999');

      await StorageService.setString('pending_phone', formattedPhone);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      print('❌ Error sending OTP: $e');
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
      // Normalize phone number to E.164 format
      final formattedPhone = PhoneUtils.normalize(phoneNumber);

      // Verify OTP with Supabase (works with test OTP from config.toml)
      final response = await _supabase.auth.verifyOTP(
        phone: formattedPhone,
        token: otp,
        type: OtpType.sms,
      );

      if (response.session == null) {
        throw Exception('No session returned after OTP verification');
      }

      print('✅ OTP verified successfully');

      // Store access token
      await StorageService.setString(AppConstants.userTokenKey, response.session!.accessToken);

      // Check if user exists in our users table
      var existingUser = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      app_user.User user;
      if (existingUser != null) {
        // User exists - check if it's an admin
        final existingUserType = existingUser['user_type'];
        if (existingUserType != 'admin') {
          // This is not an admin account trying to login
          print('❌ Phone number registered as $existingUserType');
          await _supabase.auth.signOut(); // Sign out the session
          state = state.copyWith(isLoading: false);
          throw Exception('This phone number is not registered as an admin. Please contact support.');
        }
        print('✅ Existing admin user found');
      } else {
        // User doesn't exist - try trigger or create manually
        print('⏳ User not found, waiting for database trigger...');
        await Future.delayed(const Duration(milliseconds: 500));

        final retryUser = await _supabase
            .from('users')
            .select()
            .eq('id', response.user!.id)
            .maybeSingle();

        if (retryUser != null) {
          // Check user type again after trigger
          final userType = retryUser['user_type'];
          if (userType != 'admin') {
            print('❌ Phone number registered as $userType');
            await _supabase.auth.signOut();
            state = state.copyWith(isLoading: false);
            throw Exception('This phone number is not registered as an admin. Please contact support.');
          }
          print('✅ User created by trigger');
          existingUser = retryUser;
        } else {
          // If trigger didn't create user after retry, something is wrong
          print('❌ Admin user was not created by trigger after waiting');
          throw Exception('Failed to create admin user record. Please try again.');
        }
      }

      if (existingUser != null) {
        print('✅ Database response (raw): $existingUser');

        // Convert snake_case response to camelCase for User model
        final userJson = {
          'id': existingUser['id'],
          'email': existingUser['email'],
          'phone': existingUser['phone'],
          'fullName': existingUser['full_name'],
          'avatarUrl': existingUser['avatar_url'],
          'userType': existingUser['user_type'],
          'createdAt': existingUser['created_at'],
          'updatedAt': existingUser['updated_at'],
        };

        print('✅ Converted to camelCase: $userJson');
        user = app_user.User.fromJson(userJson);
        print('👤 User loaded: ${user.full_name}');
      } else {
        throw Exception('Failed to create or load user');
      }

      // Save user data locally
      await StorageService.setObject('user', user.toJson());
      await StorageService.setBool('authenticated', true);

      state = state.copyWith(
        user: user,
        isLoading: false,
      );

      return true;
    } catch (e) {
      print('❌ OTP verification error: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
    await StorageService.clear();
    state = const AuthState();
  }

  void updateUser(app_user.User user) {
    state = state.copyWith(user: user);
    StorageService.setObject('user', user.toJson());
  }
}

// Providers
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

final currentUserProvider = Provider<app_user.User?>((ref) {
  return ref.watch(authProvider).user;
});
