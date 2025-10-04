import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/home/presentation/pages/main_navigation_page.dart';
import '../../features/services/presentation/pages/service_selection_page.dart';
import '../../features/services/presentation/pages/service_details_page.dart';
import '../../features/booking/presentation/pages/select_date_time_page.dart';
import '../../features/booking/presentation/pages/select_address_page.dart';
import '../../features/booking/presentation/pages/payment_method_page.dart';
import '../../features/booking/presentation/pages/booking_checkout_page.dart';
import '../../features/booking/presentation/pages/booking_confirmation_page.dart';
import '../../features/booking/presentation/pages/bookings_page.dart';
import '../../features/booking/presentation/pages/booking_details_page.dart';
import '../../features/booking/presentation/pages/reschedule_booking_page.dart';
import '../../features/booking/presentation/pages/cancel_booking_page.dart';
import '../../features/booking/presentation/pages/rate_partner_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/address/presentation/pages/addresses_page.dart';
import '../../features/address/presentation/pages/add_address_page.dart';
import '../../features/address/presentation/pages/edit_address_page.dart';
import '../../features/support/presentation/pages/help_center_page.dart';
import '../../features/support/presentation/pages/faq_page.dart';
import '../../features/support/presentation/pages/contact_support_page.dart';
import '../../features/support/presentation/pages/submit_ticket_page.dart';
import '../../features/profile/presentation/pages/notifications_settings_page.dart';
import '../../features/profile/presentation/pages/language_settings_page.dart';
import '../../features/profile/presentation/pages/payment_methods_page.dart';
import '../storage/storage_service.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/otp-verification',
        name: 'otp-verification',
        builder: (context, state) {
          final phoneNumber = state.uri.queryParameters['phone'] ?? '';
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),

      // Main Navigation (contains bottom nav with Home, Bookings, Profile)
      GoRoute(
        path: '/',
        name: 'main',
        builder: (context, state) => const MainNavigationPage(),
      ),

      // Service Routes
      GoRoute(
        path: '/service-selection',
        name: 'service-selection',
        builder: (context, state) => const ServiceSelectionPage(),
      ),
      GoRoute(
        path: '/service/:id',
        name: 'service-details',
        builder: (context, state) {
          final serviceId = state.pathParameters['id']!;
          return ServiceDetailsPage(serviceId: serviceId);
        },
      ),

      // Booking Flow Routes
      GoRoute(
        path: '/booking/select-date-time',
        name: 'select-date-time',
        builder: (context, state) {
          final serviceId = state.uri.queryParameters['serviceId'] ?? '';
          final basePrice = double.tryParse(state.uri.queryParameters['basePrice'] ?? '0') ?? 0.0;
          return SelectDateTimePage(
            serviceId: serviceId,
            basePrice: basePrice,
          );
        },
      ),
      GoRoute(
        path: '/booking/select-address',
        name: 'select-address',
        builder: (context, state) => const SelectAddressPage(),
      ),
      GoRoute(
        path: '/booking/payment-method',
        name: 'payment-method',
        builder: (context, state) => const PaymentMethodPage(),
      ),
      GoRoute(
        path: '/booking/checkout',
        name: 'booking-checkout',
        builder: (context, state) => const BookingCheckoutPage(),
      ),
      GoRoute(
        path: '/booking/confirmation/:id',
        name: 'booking-confirmation',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return BookingConfirmationPage(bookingId: bookingId);
        },
      ),

      // Booking Details
      GoRoute(
        path: '/booking/:id',
        name: 'booking-details',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return BookingDetailsPage(bookingId: bookingId);
        },
      ),

      // Reschedule Booking
      GoRoute(
        path: '/booking/reschedule/:id',
        name: 'reschedule-booking',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return RescheduleBookingPage(bookingId: bookingId);
        },
      ),

      // Cancel Booking
      GoRoute(
        path: '/booking/cancel/:id',
        name: 'cancel-booking',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return CancelBookingPage(bookingId: bookingId);
        },
      ),

      // Rate Partner
      GoRoute(
        path: '/booking/:id/rate',
        name: 'rate-partner',
        builder: (context, state) {
          final bookingId = state.pathParameters['id']!;
          return RatePartnerPage(bookingId: bookingId);
        },
      ),

      // Profile Routes
      GoRoute(
        path: '/profile/edit',
        name: 'edit-profile',
        builder: (context, state) => const EditProfilePage(),
      ),

      // Address Routes
      GoRoute(
        path: '/addresses',
        name: 'addresses',
        builder: (context, state) => const AddressesPage(),
      ),
      GoRoute(
        path: '/addresses/add',
        name: 'add-address',
        builder: (context, state) => const AddAddressPage(),
      ),
      GoRoute(
        path: '/addresses/edit/:id',
        name: 'edit-address',
        builder: (context, state) {
          final addressId = state.pathParameters['id']!;
          return EditAddressPage(addressId: addressId);
        },
      ),

      // Payment Methods
      GoRoute(
        path: '/payment-methods',
        name: 'payment-methods',
        builder: (context, state) => const PaymentMethodsPage(),
      ),

      // Settings Routes
      GoRoute(
        path: '/settings/notifications',
        name: 'notifications-settings',
        builder: (context, state) => const NotificationsSettingsPage(),
      ),
      GoRoute(
        path: '/settings/language',
        name: 'language-settings',
        builder: (context, state) => const LanguageSettingsPage(),
      ),

      // Support Routes
      GoRoute(
        path: '/help-center',
        name: 'help-center',
        builder: (context, state) => const HelpCenterPage(),
      ),
      GoRoute(
        path: '/faq',
        name: 'faq',
        builder: (context, state) => const FaqPage(),
      ),
      GoRoute(
        path: '/contact-support',
        name: 'contact-support',
        builder: (context, state) => const ContactSupportPage(),
      ),
      GoRoute(
        path: '/submit-ticket',
        name: 'submit-ticket',
        builder: (context, state) => const SubmitTicketPage(),
      ),
    ],
    redirect: (context, state) async {
      final isAuthenticated = StorageService.getBool('authenticated') ?? false;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/splash' ||
          state.matchedLocation.startsWith('/otp-verification');

      // If not authenticated and not on auth page, redirect to login
      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      // If authenticated and on auth page, redirect to home
      if (isAuthenticated && isOnAuthPage && state.matchedLocation != '/splash') {
        return '/';
      }

      return null;
    },
  );
});
