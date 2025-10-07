import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:intl/intl.dart';
import '../../../address/providers/address_provider.dart';
import '../../../booking/providers/booking_provider.dart';
import '../../../services/providers/services_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Invalidate providers to ensure fresh data on login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(addressesProvider);
      ref.invalidate(bookingsProvider);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddressSelector(BuildContext context, WidgetRef ref) {
    final addresses = ref.read(addressesProvider);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Select Address',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: addresses.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final address = addresses[index];
                  return InkWell(
                    onTap: () {
                      ref.read(addressesProvider.notifier).setDefaultAddress(address.id!);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Icon(
                            address.is_default ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: address.is_default ? AppTheme.primaryBlue : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${address.flat_house_no}, ${address.street_name}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                Text(
                                  '${address.area}, ${address.city}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push('/addresses/add');
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add New Address'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final defaultAddress = ref.watch(defaultAddressProvider);
    final upcomingBookings = ref.watch(upcomingBookingsProvider);
    final pastBookings = ref.watch(pastBookingsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Address Card at the top
          SizedBox(height: MediaQuery.of(context).padding.top + 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: InkWell(
              onTap: () => _showAddressSelector(context, ref),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              child: Container(
                padding: const EdgeInsets.all(12),
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
                      child: const Icon(
                        Icons.location_on,
                        color: AppTheme.primaryBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            defaultAddress != null
                                ? '${defaultAddress.flat_house_no}, ${defaultAddress.street_name}'
                                : 'Tap to add address',
                            style: TextStyle(
                              fontSize: 14,
                              color: defaultAddress != null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textHint,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Upcoming'),
                  Tab(text: 'History'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: AppTheme.primaryBlue,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                splashBorderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Upcoming Bookings
                RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(bookingsProvider.notifier).loadBookings();
                  },
                  child: upcomingBookings.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [_EmptyState()],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: upcomingBookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = upcomingBookings[index];
                            return _BookingCard(booking: booking);
                          },
                        ),
                ),
                // Booking History
                RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(bookingsProvider.notifier).loadBookings();
                  },
                  child: pastBookings.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(16),
                          children: const [_EmptyState(isHistory: true)],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: pastBookings.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final booking = pastBookings[index];
                            return _BookingCard(booking: booking);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isHistory;

  const _EmptyState({this.isHistory = false});

  @override
  Widget build(BuildContext context) {
    final imageName = isHistory ? 'empty_history' : 'empty_upcoming';
    final fallbackIcon = isHistory ? Icons.history_outlined : Icons.calendar_today_outlined;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/$imageName.png',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 192,
                  height: 192,
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: BorderRadius.circular(96),
                  ),
                  child: Icon(
                    fallbackIcon,
                    size: 96,
                    color: AppTheme.textHint,
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              isHistory ? 'No booking history' : 'No upcoming bookings',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isHistory
                  ? 'You don\'t have any past bookings yet.'
                  : 'You don\'t have any upcoming bookings. Start a new booking to schedule your next service.',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends ConsumerWidget {
  final dynamic booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(serviceByIdProvider(booking.service_id));
    final dateFormat = DateFormat('EEE, dd MMM');
    final timeFormat = DateFormat('hh:mm a');
    final partner = booking.partner;
    final hasPartner = partner != null && booking.status != 'pending';

    return InkWell(
      onTap: () {
        context.push('/booking/${booking.id}');
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Service name, date/time, and status badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service?.name ?? 'Service',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${dateFormat.format(booking.scheduled_date)} - ${timeFormat.format(booking.scheduled_date)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildStatusBadge(booking.status),
              ],
            ),

            // Dashed divider
            const SizedBox(height: 16),
            CustomPaint(
              painter: DashedLinePainter(
                color: AppTheme.borderColor.withOpacity(0.6),
              ),
              size: const Size(double.infinity, 1),
            ),
            const SizedBox(height: 16),

            // Partner info
            if (hasPartner) ...[
              Row(
                children: [
                  ClipOval(
                    child: partner['avatar_url'] != null
                        ? Image.network(
                            partner['avatar_url'],
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 40,
                                height: 40,
                                color: AppTheme.borderColor,
                                child: const Icon(
                                  Icons.person,
                                  color: AppTheme.textSecondary,
                                  size: 20,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 40,
                            height: 40,
                            color: AppTheme.borderColor,
                            child: const Icon(
                              Icons.person,
                              color: AppTheme.textSecondary,
                              size: 20,
                            ),
                          ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          partner['full_name'] ?? 'Partner',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _getPartnerRating(partner),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getPartnerReviewCount(partner),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.textSecondary.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Duration and Address
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.hourglass_top,
                      size: 16,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${booking.duration_hours} ${booking.duration_hours == 1 ? 'hour' : 'hours'}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.home,
                      size: 16,
                      color: AppTheme.textSecondary.withOpacity(0.6),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getAddressDisplay(booking.address),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textPrimary.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toLowerCase()) {
      case 'pending':
        backgroundColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        displayText = 'Pending';
        break;
      case 'confirmed':
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        displayText = 'Confirmed';
        break;
      case 'in_progress':
        backgroundColor = const Color(0xFFDBEAFE);
        textColor = const Color(0xFF2563EB);
        displayText = 'In Progress';
        break;
      case 'completed':
        backgroundColor = const Color(0xFFD1FAE5);
        textColor = const Color(0xFF059669);
        displayText = 'Completed';
        break;
      case 'cancelled':
        backgroundColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFFDC2626);
        displayText = 'Cancelled';
        break;
      default:
        backgroundColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF6B7280);
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }

  String _getAddressDisplay(dynamic address) {
    if (address == null) return 'No address';

    try {
      if (address is Map<String, dynamic>) {
        final street = address['street_name'] ?? address['streetName'];
        if (street != null) return street;
      }
      return 'Address';
    } catch (e) {
      return 'Address';
    }
  }

  IconData _getServiceIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'gardening':
        return Icons.park_outlined;
      case 'handyman':
        return Icons.handyman;
      default:
        return Icons.home_repair_service;
    }
  }

  String _getPartnerRating(Map<String, dynamic> partner) {
    try {
      final profiles = partner['partner_profiles'];
      if (profiles is List && profiles.isNotEmpty) {
        final rating = profiles[0]['rating'];
        if (rating != null) {
          return rating.toStringAsFixed(1);
        }
      }
      return '0.0';
    } catch (e) {
      return '0.0';
    }
  }

  String _getPartnerReviewCount(Map<String, dynamic> partner) {
    try {
      final profiles = partner['partner_profiles'];
      if (profiles is List && profiles.isNotEmpty) {
        final totalJobs = profiles[0]['total_jobs'];
        if (totalJobs != null && totalJobs > 0) {
          return '($totalJobs reviews)';
        }
      }
      return '(No reviews)';
    } catch (e) {
      return '(No reviews)';
    }
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  final double dashWidth;
  final double dashSpace;

  DashedLinePainter({
    required this.color,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(startX + dashWidth, 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
