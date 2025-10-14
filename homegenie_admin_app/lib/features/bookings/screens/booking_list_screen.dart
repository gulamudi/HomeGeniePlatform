import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';

class BookingListScreen extends ConsumerStatefulWidget {
  const BookingListScreen({super.key});

  @override
  ConsumerState<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends ConsumerState<BookingListScreen> {
  String? selectedStatus;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(0xFF28A745);
      case 'pending':
        return const Color(0xFFFFC107);
      case 'completed':
        return const Color(0xFF007BFF);
      case 'cancelled':
        return const Color(0xFFDC3545);
      case 'in_progress':
        return const Color(0xFF17A2B8);
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingsAsync = ref.watch(bookingsProvider(selectedStatus));

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFFF8F9FA).withOpacity(0.8),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bookings',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF212529),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by ID, client, partner...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFE9ECEF),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  // Filter Chips
                  SizedBox(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      children: [
                        _FilterChip(
                          label: 'Status',
                          isSelected: selectedStatus != null,
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (context) => _StatusFilterSheet(
                                selectedStatus: selectedStatus,
                                onStatusSelected: (status) {
                                  setState(() => selectedStatus = status);
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Date Range', onTap: () {}),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Client', onTap: () {}),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Partner', onTap: () {}),
                        const SizedBox(width: 12),
                        _FilterChip(label: 'Service', onTap: () {}),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Booking List
          Expanded(
            child: bookingsAsync.when(
              data: (bookings) {
                if (bookings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inbox_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No bookings found.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your filters.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    final customer = booking['customer'] as Map<String, dynamic>?;
                    final partner = booking['partner'] as Map<String, dynamic>?;
                    final service = booking['service'] as Map<String, dynamic>?;
                    final status = booking['status'] as String;
                    final scheduledDate = DateTime.parse(booking['scheduled_date']);

                    return _BookingCard(
                      bookingId: booking['id'],
                      serviceName: service?['name'] ?? 'Unknown Service',
                      customerName: customer?['full_name'] ?? 'Unknown Customer',
                      partnerName: partner?['full_name'] ?? 'Unassigned',
                      scheduledDate: scheduledDate,
                      status: status,
                      statusColor: _getStatusColor(status),
                      onTap: () => context.push('/bookings/${booking['id']}'),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF007BFF).withOpacity(0.2)
              : const Color(0xFFE9ECEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF007BFF) : const Color(0xFF495057),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: isSelected ? const Color(0xFF007BFF) : const Color(0xFF495057),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final String bookingId;
  final String serviceName;
  final String customerName;
  final String partnerName;
  final DateTime scheduledDate;
  final String status;
  final Color statusColor;
  final VoidCallback onTap;

  const _BookingCard({
    required this.bookingId,
    required this.serviceName,
    required this.customerName,
    required this.partnerName,
    required this.scheduledDate,
    required this.status,
    required this.statusColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking #${bookingId.substring(0, 8)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      status[0].toUpperCase() + status.substring(1),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                serviceName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Client: $customerName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                'Partner: $partnerName',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                DateFormat('MMM dd, yyyy, hh:mm a').format(scheduledDate),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const Divider(height: 24),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onTap,
                  child: const Text(
                    'View Details',
                    style: TextStyle(
                      color: Color(0xFF007BFF),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusFilterSheet extends StatelessWidget {
  final String? selectedStatus;
  final Function(String?) onStatusSelected;

  const _StatusFilterSheet({
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      null, // All
      'pending',
      'confirmed',
      'in_progress',
      'completed',
      'cancelled',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Filter by Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...statuses.map((status) {
            final displayName = status == null
                ? 'All'
                : status[0].toUpperCase() + status.substring(1).replaceAll('_', ' ');
            return ListTile(
              title: Text(displayName),
              selected: selectedStatus == status,
              onTap: () => onStatusSelected(status),
            );
          }),
        ],
      ),
    );
  }
}
