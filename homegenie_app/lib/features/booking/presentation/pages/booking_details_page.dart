import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../../services/providers/services_provider.dart';

class BookingDetailsPage extends ConsumerWidget {
  final String bookingId;

  const BookingDetailsPage({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingByIdProvider(bookingId));

    if (booking == null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text(
            'Booking Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Booking not found'),
        ),
      );
    }

    final service = ref.watch(serviceByIdProvider(booking.service_id));
    final isUpcoming = booking.status == 'upcoming' || booking.status == 'confirmed';
    final isCompleted = booking.status == 'completed';
    final isCancelled = booking.status == 'cancelled';

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Booking Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  _buildStatusBadge(booking.status),
                  const SizedBox(height: 24),

                  // Service Information Section
                  const Text(
                    'Service Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (service != null)
                    _buildInfoCard(
                      icon: Icons.home_repair_service,
                      title: 'Service Type',
                      value: service.name,
                    ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    title: 'Date & Time',
                    value: DateFormat('MMMM d, yyyy, h:mm a')
                        .format(booking.scheduled_date),
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.access_time,
                    title: 'Duration',
                    value: '${booking.duration_hours} hours',
                  ),
                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.location_on,
                    title: 'Address',
                    value: _formatAddress(booking.address),
                  ),

                  if (booking.special_instructions != null &&
                      booking.special_instructions!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      icon: Icons.note,
                      title: 'Special Instructions',
                      value: booking.special_instructions!,
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Payment Information Section
                  const Text(
                    'Payment Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Service Charge',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            Text(
                              '\u20B9${booking.total_amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Amount',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              '\u20B9${booking.total_amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              _getPaymentIcon(booking.payment_method),
                              size: 20,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatPaymentMethod(booking.payment_method),
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getPaymentStatusColor(
                                        booking.payment_status)
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: Text(
                                booking.payment_status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _getPaymentStatusColor(
                                      booking.payment_status),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Booking ID
                  _buildInfoCard(
                    icon: Icons.receipt,
                    title: 'Booking ID',
                    value: booking.id,
                  ),
                ],
              ),
            ),
          ),

          // Action Buttons based on status
          if (!isCancelled) ...[
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
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isCompleted) ...[
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/booking/${booking.id}/rate');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            'Rate Service',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ] else if (isUpcoming) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                context.push('/booking/reschedule/${booking.id}');
                              },
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppTheme.primaryBlue,
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Reschedule',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryBlue,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                context.push('/booking/cancel/${booking.id}');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.errorRed,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = AppTheme.getStatusColor(status);
    final bgColor = AppTheme.getStatusBackgroundColor(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
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
        crossAxisAlignment: CrossAxisAlignment.start,
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
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
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
      if (address['pin_code'] != null) parts.add(address['pin_code']);
      return parts.join(', ');
    }
    return address.toString();
  }

  IconData _getPaymentIcon(String method) {
    switch (method.toLowerCase()) {
      case 'card':
      case 'credit_card':
      case 'debit_card':
        return Icons.credit_card;
      case 'upi':
        return Icons.phone_android;
      case 'cash':
        return Icons.payments_outlined;
      default:
        return Icons.payment;
    }
  }

  String _formatPaymentMethod(String method) {
    switch (method.toLowerCase()) {
      case 'card':
        return 'Credit/Debit Card';
      case 'upi':
        return 'UPI';
      case 'cash':
        return 'Cash on Service';
      case 'online':
        return 'Online Payment';
      default:
        return method;
    }
  }

  Color _getPaymentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return AppTheme.successGreen;
      case 'pending':
        return AppTheme.warningYellow;
      case 'failed':
        return AppTheme.errorRed;
      default:
        return AppTheme.textSecondary;
    }
  }
}
