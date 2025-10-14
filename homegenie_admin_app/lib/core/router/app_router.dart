import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/screens/admin_login_screen.dart';
import '../../features/auth/screens/admin_otp_screen.dart';
import '../../features/dashboard/screens/admin_dashboard_screen.dart';
import '../../features/bookings/screens/booking_list_screen.dart';
import '../../features/bookings/screens/booking_details_screen.dart';
import '../../features/bookings/screens/assign_partner_screen.dart';
import '../../features/bookings/screens/booking_create_screen.dart';
import '../../features/customers/screens/customer_list_screen.dart';
import '../../features/customers/screens/customer_edit_screen.dart';
import '../../features/partners/screens/partner_list_screen.dart';
import '../../features/partners/screens/partner_edit_screen.dart';
import '../../features/partners/screens/service_selection_screen.dart';
import '../storage/storage_service.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isAuthenticated = StorageService.getBool('authenticated') ?? false;
      final isLoggingIn =
          state.matchedLocation == '/login' ||
          state.matchedLocation.startsWith('/otp-verification');

      print('🟢 [ROUTER] Redirect check:');
      print('   Location: ${state.matchedLocation}');
      print('   isAuthenticated: $isAuthenticated');
      print('   isLoggingIn: $isLoggingIn');

      if (!isAuthenticated && !isLoggingIn) {
        print('   ➡️  Redirecting to /login (not authenticated)');
        return '/login';
      }

      if (isAuthenticated && isLoggingIn) {
        print('   ➡️  Redirecting to / (authenticated on login page)');
        return '/';
      }

      print('   ✅ No redirect');
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const AdminLoginScreen(),
      ),
      GoRoute(
        path: '/otp-verification',
        builder: (context, state) {
          final phone = state.uri.queryParameters['phone'] ?? '';
          return AdminOtpScreen(phoneNumber: phone);
        },
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingListScreen(),
      ),
      GoRoute(
        path: '/bookings/:id',
        builder: (context, state) => BookingDetailsScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/bookings/:id/assign',
        builder: (context, state) => AssignPartnerScreen(
          bookingId: state.pathParameters['id']!,
        ),
      ),
      GoRoute(
        path: '/bookings/create',
        builder: (context, state) {
          final customerId = state.uri.queryParameters['customerId'];
          return BookingCreateScreen(customerId: customerId);
        },
      ),
      GoRoute(
        path: '/customers',
        builder: (context, state) => const CustomerListScreen(),
      ),
      GoRoute(
        path: '/customers/create',
        builder: (context, state) => const CustomerEditScreen(),
      ),
      GoRoute(
        path: '/customers/:id',
        builder: (context, state) => CustomerEditScreen(
          customerId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/partners',
        builder: (context, state) => const PartnerListScreen(),
      ),
      GoRoute(
        path: '/partners/create',
        builder: (context, state) => const PartnerEditScreen(),
      ),
      GoRoute(
        path: '/partners/:id',
        builder: (context, state) => PartnerEditScreen(
          partnerId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '/partners/:id/services',
        builder: (context, state) => ServiceSelectionScreen(
          partnerId: state.pathParameters['id']!,
        ),
      ),
    ],
  );
});
