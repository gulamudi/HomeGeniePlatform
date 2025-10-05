import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/models/job.dart';
import '../../auth/providers/auth_provider.dart';

final jobDetailsProvider = FutureProvider.family<Job, String>((ref, jobId) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.getJobDetails(jobId);
    final data = response.data;

    if (data == null || data['data'] == null) {
      throw Exception('Job not found');
    }

    final booking = data['data'] as Map<String, dynamic>;
    return _mapBookingToJob(booking);
  } on DioException catch (e) {
    print('Error fetching job details: ${e.message}');
    throw Exception('Failed to fetch job details');
  }
});

Job _mapBookingToJob(Map<String, dynamic> booking) {
  final service = booking['service'] as Map<String, dynamic>?;
  final customer = booking['customer'] as Map<String, dynamic>?;

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
    address: booking['address'] as String? ?? '',
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
