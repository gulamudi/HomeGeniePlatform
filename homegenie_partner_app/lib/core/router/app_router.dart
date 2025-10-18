import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/otp_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/onboarding/screens/document_verification_screen.dart';
import '../../features/onboarding/screens/profile_setup_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/jobs/screens/job_details_screen.dart';
import '../../features/jobs/screens/job_in_progress_screen.dart';
import '../../features/jobs/screens/job_completed_screen.dart';
import '../../features/jobs/screens/cancel_job_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/profile/screens/support_screen.dart';
import '../../features/jobs/screens/job_history_screen.dart';
import '../../features/preferences/screens/availability_preferences_screen.dart';
import '../../features/preferences/screens/service_preferences_screen.dart';
import '../../features/profile/screens/payment_information_screen.dart';
import '../../features/profile/screens/privacy_policy_screen.dart';
import '../../features/profile/screens/terms_of_service_screen.dart';
import '../../features/preferences/screens/preferences_screen.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class AppRouter {
  final StorageService _storage;

  AppRouter(this._storage);

  // Global navigator key for navigation from anywhere
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  late final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isLoggedIn = _storage.isLoggedIn();
      final isOnboarded = _storage.isOnboarded();
      final path = state.uri.path;

      // If not logged in and trying to access protected route, redirect to login
      if (!isLoggedIn &&
          path != '/splash' &&
          path != AppConstants.routeLogin &&
          path != AppConstants.routeOtp) {
        return AppConstants.routeLogin;
      }

      // If logged in but not onboarded, redirect to onboarding from login
      if (isLoggedIn && !isOnboarded && path == AppConstants.routeLogin) {
        return AppConstants.routeOnboarding;
      }

      // If logged in and onboarded, redirect to home from login
      if (isLoggedIn && isOnboarded && path == AppConstants.routeLogin) {
        return AppConstants.routeHome;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.routeOtp,
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return OtpScreen(phone: phone);
        },
      ),
      GoRoute(
        path: AppConstants.routeOnboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppConstants.routeDocumentVerification,
        builder: (context, state) => const DocumentVerificationScreen(),
      ),
      GoRoute(
        path: AppConstants.routeProfileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      GoRoute(
        path: AppConstants.routeHome,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppConstants.routeJobDetails,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return JobDetailsScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppConstants.routeJobStarted,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          final serviceName = state.uri.queryParameters['serviceName'] ?? 'Service';
          final customerName = state.uri.queryParameters['customerName'] ?? 'Customer';
          return JobInProgressScreen(
            jobId: jobId,
            serviceName: serviceName,
            customerName: customerName,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeJobCompleted,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          final serviceName = state.uri.queryParameters['serviceName'] ?? 'Service';
          final durationMinutes = int.tryParse(state.uri.queryParameters['duration'] ?? '0') ?? 0;
          final earnings = double.tryParse(state.uri.queryParameters['earnings'] ?? '0') ?? 0;
          return JobCompletedScreen(
            jobId: jobId,
            serviceName: serviceName,
            duration: Duration(minutes: durationMinutes),
            earnings: earnings,
          );
        },
      ),
      GoRoute(
        path: AppConstants.routeCancelJob,
        builder: (context, state) {
          final jobId = state.uri.queryParameters['jobId'] ?? '';
          return CancelJobScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppConstants.routeProfile,
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppConstants.routeJobHistory,
        builder: (context, state) => const JobHistoryScreen(),
      ),
      GoRoute(
        path: AppConstants.routeSupport,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppConstants.routeAvailabilityPreferences,
        builder: (context, state) => const AvailabilityPreferencesScreen(),
      ),
      GoRoute(
        path: AppConstants.routeServicePreferences,
        builder: (context, state) => const ServicePreferencesScreen(),
      ),
      GoRoute(
        path: AppConstants.routeInitialSetup,
        builder: (context, state) => const PreferencesScreen(isInitialSetup: true),
      ),
      GoRoute(
        path: AppConstants.routePaymentGuide,
        builder: (context, state) => const PaymentInformationScreen(),
      ),
      GoRoute(
        path: AppConstants.routePrivacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppConstants.routeTermsOfService,
        builder: (context, state) => const TermsOfServiceScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 16),
            Text('Page not found: ${state.uri.path}'),
            TextButton(
              onPressed: () => context.go(AppConstants.routeHome),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
