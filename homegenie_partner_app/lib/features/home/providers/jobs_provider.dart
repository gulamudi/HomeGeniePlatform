import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

final jobsProvider = FutureProvider.family<List<Job>, String>((ref, tab) async {
  final apiClient = ref.watch(apiClientProvider);

  // Determine date filters and status based on tab
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));

  // Helper to format date as YYYY-MM-DD for API
  String formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String? status;
  String? fromDate;
  String? toDate;

  switch (tab) {
    case AppConstants.tabToday:
      fromDate = formatDate(today);
      toDate = formatDate(today);
      status = 'confirmed,in_progress';
      break;
    case AppConstants.tabUpcoming:
      fromDate = formatDate(tomorrow);
      status = 'confirmed';
      break;
    case AppConstants.tabHistory:
      toDate = formatDate(yesterday);
      status = 'completed,cancelled';
      break;
    case AppConstants.tabAvailable:
      status = 'pending';
      break;
  }

  try {
    print('🔍 Fetching $tab jobs - Status: $status, FromDate: $fromDate, ToDate: $toDate');

    final Response response;
    if (tab == AppConstants.tabAvailable) {
      response = await apiClient.getAvailableJobs();
    } else {
      response = await apiClient.getAssignedJobs(
        status: status,
        fromDate: fromDate,
        toDate: toDate,
      );
    }

    print('📦 Response data: ${response.data}');

    final data = response.data;
    if (data == null || data['data'] == null) {
      print('⚠️ No data in response');
      return [];
    }

    final jobsData = data['data']['jobs'] as List;
    print('✅ Found ${jobsData.length} jobs for $tab');
    return jobsData.map((jobJson) => _mapBookingToJob(jobJson)).toList();
  } on DioException catch (e) {
    print('❌ DioException fetching $tab jobs: ${e.message}');
    print('Response: ${e.response?.data}');
    throw Exception('Failed to fetch jobs: ${e.message}');
  } catch (e, stackTrace) {
    print('❌ Unexpected error fetching $tab jobs: $e');
    print('Stack trace: $stackTrace');
    throw Exception('Failed to fetch jobs: $e');
  }
});

Job _mapBookingToJob(Map<String, dynamic> booking) {
  final service = booking['service'] as Map<String, dynamic>?;
  final customer = booking['customer'] as Map<String, dynamic>?;

  // DEBUG: Print booking data to understand structure
  print('🔍 DEBUG - Booking data:');
  print('  ID: ${booking['id']}');
  print('  Status: ${booking['status']}');
  print('  Scheduled Date: ${booking['scheduled_date']}');
  print('  Scheduled Time: ${booking['scheduled_time']}');
  print('  Full booking keys: ${booking.keys.toList()}');

  // Handle address - it can be either a String or a Map
  String addressString = '';
  final addressData = booking['address'];
  if (addressData is String) {
    addressString = addressData;
  } else if (addressData is Map<String, dynamic>) {
    // Construct address string from map - include all local details except city and state
    final parts = <String>[];
    if (addressData['flat'] != null && addressData['flat'].toString().isNotEmpty) {
      parts.add(addressData['flat'].toString());
    }
    if (addressData['building'] != null && addressData['building'].toString().isNotEmpty) {
      parts.add(addressData['building'].toString());
    }
    if (addressData['street'] != null && addressData['street'].toString().isNotEmpty) {
      parts.add(addressData['street'].toString());
    }
    if (addressData['area'] != null && addressData['area'].toString().isNotEmpty) {
      parts.add(addressData['area'].toString());
    }
    if (addressData['sector'] != null && addressData['sector'].toString().isNotEmpty) {
      parts.add(addressData['sector'].toString());
    }
    if (addressData['landmark'] != null && addressData['landmark'].toString().isNotEmpty) {
      parts.add(addressData['landmark'].toString());
    }
    if (addressData['locality'] != null && addressData['locality'].toString().isNotEmpty) {
      parts.add(addressData['locality'].toString());
    }
    // Only add city if no local info is available
    if (parts.isEmpty && addressData['city'] != null) {
      parts.add(addressData['city'].toString());
    }
    addressString = parts.join(', ');
  }

  // Parse scheduled_date as a full timestamp (includes date and time)
  final scheduledDateTime = DateTime.parse(booking['scheduled_date'] as String);

  // Extract time in HH:mm:ss format from the timestamp
  final scheduledTimeString = '${scheduledDateTime.hour.toString().padLeft(2, '0')}:${scheduledDateTime.minute.toString().padLeft(2, '0')}:${scheduledDateTime.second.toString().padLeft(2, '0')}';

  print('✅ DEBUG - Extracted time from scheduled_date: $scheduledTimeString');

  return Job(
    id: booking['id'] as String,
    bookingId: booking['booking_number'] as String? ?? booking['id'] as String,
    serviceType: service?['category'] as String? ?? 'service',
    serviceName: service?['name'] as String? ?? 'Service',
    status: booking['status'] as String,
    scheduledDate: scheduledDateTime,
    scheduledTime: scheduledTimeString,
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
