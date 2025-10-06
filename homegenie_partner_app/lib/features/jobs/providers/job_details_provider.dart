import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../auth/providers/auth_provider.dart';

final jobDetailsProvider = FutureProvider.family<Job, String>((ref, jobId) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    print('🔵 [JobDetailsProvider] Fetching job details for: $jobId');
    final response = await apiClient.getJobDetails(jobId);
    final data = response.data;

    if (data == null || data['data'] == null) {
      throw Exception('No data in response');
    }

    final booking = data['data'] as Map<String, dynamic>;
    print('✅ [JobDetailsProvider] Job details fetched successfully');
    print('   Booking data: $booking');
    return _mapBookingToJob(booking);
  } catch (e, stackTrace) {
    print('❌ [JobDetailsProvider] Error fetching job details: $e');
    print('   Stack trace: $stackTrace');
    throw Exception('Failed to fetch job details: $e');
  }
});

Job _mapBookingToJob(Map<String, dynamic> booking) {
  // API returns 'service' (singular) and 'customer' (singular)
  final service = booking['service'] as Map<String, dynamic>?;
  final customer = booking['customer'] as Map<String, dynamic>?;

  // Handle address - it can be either a String or a Map
  String addressString = '';
  final addressData = booking['address'];
  if (addressData is String) {
    addressString = addressData;
  } else if (addressData is Map<String, dynamic>) {
    // Construct address string from map
    final parts = <String>[];
    if (addressData['street'] != null) parts.add(addressData['street'].toString());
    if (addressData['area'] != null) parts.add(addressData['area'].toString());
    if (addressData['city'] != null) parts.add(addressData['city'].toString());
    if (addressData['state'] != null) parts.add(addressData['state'].toString());
    if (addressData['pincode'] != null) parts.add(addressData['pincode'].toString());
    addressString = parts.join(', ');
  }

  return Job(
    id: booking['id'] as String,
    bookingId: booking['booking_number'] as String? ?? booking['id'] as String,
    serviceType: service?['category'] as String? ?? 'service',
    serviceName: service?['name'] as String? ?? 'Service',
    status: booking['status'] as String,
    scheduledDate: DateTime.parse(booking['scheduled_date'] as String),
    scheduledTime: booking['scheduled_time'] as String?,
    amount: (booking['total_amount'] as num).toDouble(),
    partnerEarning: booking['partner_amount'] != null
        ? (booking['partner_amount'] as num).toDouble()
        : null,
    customerId: booking['customer_id'] as String,
    customerName: customer?['full_name'] as String? ?? 'Customer',
    customerPhone: customer?['phone'] as String?,
    customerPhoto: customer?['avatar_url'] as String?,
    address: addressString.isNotEmpty ? addressString : 'Address not provided',
    latitude: booking['latitude'] as double?,
    longitude: booking['longitude'] as double?,
    instructions: booking['instructions'] as String?,
    acceptedAt: booking['accepted_at'] != null
        ? DateTime.parse(booking['accepted_at'] as String)
        : null,
    startedAt: booking['started_at'] != null
        ? DateTime.parse(booking['started_at'] as String)
        : null,
    completedAt: booking['completed_at'] != null
        ? DateTime.parse(booking['completed_at'] as String)
        : null,
    cancelledAt: booking['cancelled_at'] != null
        ? DateTime.parse(booking['cancelled_at'] as String)
        : null,
    cancelReason: booking['cancel_reason'] as String?,
    rating: booking['rating'] != null ? (booking['rating'] as num).toInt() : null,
    review: booking['review'] as String?,
    createdAt: DateTime.parse(booking['created_at'] as String),
    updatedAt: booking['updated_at'] != null
        ? DateTime.parse(booking['updated_at'] as String)
        : null,
  );
}
