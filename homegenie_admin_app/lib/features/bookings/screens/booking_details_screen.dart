import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/bookings_provider.dart';
import '../../../core/network/admin_api_service.dart';

class BookingDetailsScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends ConsumerState<BookingDetailsScreen> {
  String? selectedStatus;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _assignPartner(String partnerId) async {
    try {
      await ref
          .read(adminApiServiceProvider)
          .assignPartnerToBooking(
            bookingId: widget.bookingId,
            partnerId: partnerId,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Partner assigned successfully')),
      );
      ref.invalidate(bookingDetailsProvider(widget.bookingId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateStatus() async {
    if (selectedStatus == null) return;

    try {
      await ref
          .read(adminApiServiceProvider)
          .updateBookingStatus(
            bookingId: widget.bookingId,
            status: selectedStatus!,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status updated successfully')),
      );
      ref.invalidate(bookingDetailsProvider(widget.bookingId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _rescheduleBooking() async {
    if (selectedDate == null || selectedTime == null) return;

    final newDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    try {
      await ref
          .read(adminApiServiceProvider)
          .rescheduleBooking(
            bookingId: widget.bookingId,
            newDate: newDate,
          );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking rescheduled successfully')),
      );
      ref.invalidate(bookingDetailsProvider(widget.bookingId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _cancelBooking() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text(
            'Are you sure you want to cancel this booking? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC3545),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(adminApiServiceProvider)
          .cancelBooking(bookingId: widget.bookingId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking cancelled successfully')),
      );
      ref.invalidate(bookingDetailsProvider(widget.bookingId));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingAsync = ref.watch(bookingDetailsProvider(widget.bookingId));
    final partnersAsync = ref.watch(availablePartnersProvider(
        const PartnerFilters(search: null, verificationStatus: null)));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text('Booking #${widget.bookingId.substring(0, 8)}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: bookingAsync.when(
        data: (booking) {
          if (booking == null) {
            return const Center(child: Text('Booking not found'));
          }

          final customer = booking['customer'] as Map<String, dynamic>?;
          final partner = booking['partner'] as Map<String, dynamic>?;
          final service = booking['service'] as Map<String, dynamic>?;
          final scheduledDate = DateTime.parse(booking['scheduled_date']);
          final address = booking['address'] as Map<String, dynamic>?;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Booking Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FA),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _InfoRow(
                        label: 'Client Name',
                        value: customer?['full_name'] ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Contact Info',
                        value: customer?['phone'] ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Service',
                        value: service?['name'] ?? 'N/A',
                      ),
                      _InfoRow(
                        label: 'Date & Time',
                        value: DateFormat('dd MMM, yyyy at hh:mm a')
                            .format(scheduledDate),
                      ),
                      _InfoRow(
                        label: 'Address',
                        value: address?['full_address'] ??
                            address?['street'] ??
                            'N/A',
                        isLast: true,
                      ),
                    ],
                  ),
                ),
                if (booking['special_instructions'] != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Special Instructions: ${booking['special_instructions']}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                // Assign Partner Section
                _AccordionSection(
                  title: 'Assign Partner',
                  initiallyExpanded: partner == null,
                  child: Column(
                    children: [
                      partnersAsync.when(
                        data: (partners) {
                          final topPartners = partners.take(2).toList();
                          return Column(
                            children: [
                              ...topPartners.map((p) => _PartnerCard(
                                    name: p['full_name'] ?? 'Unknown',
                                    rating: 4.8,
                                    distance: '2.5km away',
                                    onAssign: () => _assignPartner(p['id']),
                                  )),
                              TextButton(
                                onPressed: () =>
                                    context.push('/bookings/${widget.bookingId}/assign'),
                                child: const Text('View All Partners'),
                              ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (e, s) => Text('Error: $e'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Change Status Section
                _AccordionSection(
                  title: 'Change Status',
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        value: selectedStatus ?? booking['status'],
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: ['pending', 'confirmed', 'in_progress', 'completed', 'cancelled']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status[0].toUpperCase() +
                                      status.substring(1).replaceAll('_', ' ')),
                                ))
                            .toList(),
                        onChanged: (value) =>
                            setState(() => selectedStatus = value),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _updateStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Update Status'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Reschedule Section
                _AccordionSection(
                  title: 'Reschedule Booking',
                  child: Column(
                    children: [
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                              : '',
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: const InputDecoration(
                          labelText: 'Time',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedTime != null
                              ? selectedTime!.format(context)
                              : '',
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() => selectedTime = time);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _rescheduleBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Confirm Reschedule'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Cancel Booking Section
                _AccordionSection(
                  title: 'Cancel Booking',
                  child: Column(
                    children: [
                      const Text(
                        'Are you sure you want to cancel this booking? This action cannot be undone.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF6C757D)),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _cancelBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC3545),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Confirm Cancellation'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;

  const _InfoRow({
    required this.label,
    required this.value,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF6C757D),
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          const Divider(height: 1, color: Color(0xFFDEE2E6)),
      ],
    );
  }
}

class _AccordionSection extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _AccordionSection({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_AccordionSection> createState() => _AccordionSectionState();
}

class _AccordionSectionState extends State<_AccordionSection> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                  ),
                ],
              ),
            ),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: widget.child,
            ),
        ],
      ),
    );
  }
}

class _PartnerCard extends StatelessWidget {
  final String name;
  final double rating;
  final String distance;
  final VoidCallback onAssign;

  const _PartnerCard({
    required this.name,
    required this.rating,
    required this.distance,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Color(0xFFE9ECEF),
            child: Icon(Icons.person),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$rating Stars | $distance',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF007BFF),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}
