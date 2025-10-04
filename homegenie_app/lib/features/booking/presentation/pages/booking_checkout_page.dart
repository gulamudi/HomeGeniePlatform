import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../providers/booking_provider.dart';
import '../../../services/providers/services_provider.dart';

class BookingCheckoutPage extends ConsumerStatefulWidget {
  const BookingCheckoutPage({super.key});

  @override
  ConsumerState<BookingCheckoutPage> createState() => _BookingCheckoutPageState();
}

class _BookingCheckoutPageState extends ConsumerState<BookingCheckoutPage> {
  String? _selectedPaymentMethod;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': 'card',
      'name': 'Credit/Debit Card',
      'icon': Icons.credit_card,
    },
    {
      'id': 'upi',
      'name': 'UPI',
      'icon': Icons.phone_android,
    },
    {
      'id': 'cash',
      'name': 'Cash on Service',
      'icon': Icons.payments_outlined,
    },
  ];

  Future<void> _confirmBooking() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a payment method'),
          backgroundColor: AppTheme.warningYellow,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Set payment method
      ref.read(bookingProvider.notifier).setPaymentMethod(_selectedPaymentMethod!);

      // Create booking
      final bookingId = await ref.read(bookingProvider.notifier).createBooking();

      if (bookingId != null && mounted) {
        // Navigate to confirmation page
        context.go('/booking/confirmation/$bookingId');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final service = bookingState.serviceId != null
        ? ref.watch(serviceByIdProvider(bookingState.serviceId!))
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Checkout',
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
                  // Booking Summary Section
                  const Text(
                    'Booking Summary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Service Card
                  if (service != null) ...[
                    _buildInfoCard(
                      icon: Icons.home_repair_service,
                      title: service.name,
                      subtitle: service.category,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Address Card
                  if (bookingState.selectedAddress != null) ...[
                    _buildInfoCard(
                      icon: Icons.location_on,
                      title: 'Address',
                      subtitle: _formatAddress(bookingState.selectedAddress!),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Date & Time Card
                  if (bookingState.selectedDate != null &&
                      bookingState.selectedTimeSlot != null) ...[
                    _buildInfoCard(
                      icon: Icons.calendar_today,
                      title: 'Date & Time',
                      subtitle:
                          '${DateFormat('MMMM d, yyyy').format(bookingState.selectedDate!)}, ${bookingState.selectedTimeSlot}',
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Duration Card
                  if (bookingState.durationHours != null) ...[
                    _buildInfoCard(
                      icon: Icons.access_time,
                      title: 'Duration',
                      subtitle: '${bookingState.durationHours} hours',
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Payment Method Section
                  const Text(
                    'Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Methods List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _paymentMethods.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        final isSelected = _selectedPaymentMethod == method['id'];

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedPaymentMethod = method['id'] as String;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryBlue.withOpacity(0.1),
                                    borderRadius:
                                        BorderRadius.circular(AppTheme.radiusMedium),
                                  ),
                                  child: Icon(
                                    method['icon'] as IconData,
                                    color: AppTheme.primaryBlue,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    method['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_unchecked,
                                  color: isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.textHint,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Total Amount
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          '\u20B9${bookingState.totalAmount?.toStringAsFixed(2) ?? '0.00'}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Button
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
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Confirm Booking',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String subtitle,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
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
      return parts.join(', ');
    }
    return address.toString();
  }
}
