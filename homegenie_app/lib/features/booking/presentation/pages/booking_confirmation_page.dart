import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../../services/providers/services_provider.dart';

class BookingConfirmationPage extends ConsumerWidget {
  final String bookingId;

  const BookingConfirmationPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(bookingProvider);
    final service = bookingState.serviceId != null
        ? ref.watch(serviceByIdProvider(bookingState.serviceId!))
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    // Success Icon
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Booking Confirmed!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'You\'ve successfully booked a ${service?.category ?? 'service'}. Here are the details:',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    // Booking Details Cards
                    if (service != null) ...[
                      _buildDetailCard(
                        context,
                        icon: Icons.home_repair_service,
                        title: 'Service',
                        value: service.name,
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (bookingState.selectedDate != null &&
                        bookingState.selectedTimeSlot != null) ...[
                      _buildDetailCard(
                        context,
                        icon: Icons.calendar_today,
                        title: 'Date & Time',
                        value:
                            '${DateFormat('MMMM d, yyyy').format(bookingState.selectedDate!)}, ${bookingState.selectedTimeSlot}',
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (bookingState.selectedAddress != null) ...[
                      _buildDetailCard(
                        context,
                        icon: Icons.location_on,
                        title: 'Address',
                        value: _formatAddress(bookingState.selectedAddress!),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildDetailCard(
                      context,
                      icon: Icons.receipt,
                      title: 'Booking ID',
                      value: bookingId,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Buttons
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/booking/$bookingId');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'View Booking Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () async {
                        // Reset booking state
                        ref.read(bookingProvider.notifier).reset();
                        // Refresh bookings list
                        await ref.read(bookingsProvider.notifier).loadBookings();
                        if (context.mounted) {
                          context.go('/');
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Back to Home',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatAddress(dynamic address) {
    if (address is Map) {
      final parts = <String>[];
      if (address['flat_house_no'] != null) parts.add(address['flat_house_no']);
      if (address['street_name'] != null) parts.add(address['street_name']);
      if (address['area'] != null) parts.add(address['area']);
      if (address['city'] != null) parts.add(address['city']);
      return parts.join(', ');
    }
    // Handle Address object
    final parts = <String>[];
    parts.add(address.flat_house_no);
    parts.add(address.street_name);
    parts.add(address.area);
    parts.add(address.city);
    return parts.join(', ');
  }
}
