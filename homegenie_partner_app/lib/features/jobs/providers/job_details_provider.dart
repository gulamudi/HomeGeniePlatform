import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';

final jobDetailsProvider = FutureProvider.family<Job, String>((ref, jobId) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));

  // Return mock job details
  return Job(
    id: jobId,
    bookingId: 'BK001',
    serviceType: 'plumbing',
    serviceName: 'Plumbing Service',
    status: AppConstants.jobStatusAccepted,
    scheduledDate: DateTime.now(),
    scheduledTime: '10:00 AM',
    amount: 500.0,
    partnerEarning: 400.0,
    customerId: 'cust1',
    customerName: 'Rahul Sharma',
    customerPhone: '9876543210',
    address: '123, MG Road, Bangalore - 560001',
    latitude: 12.9716,
    longitude: 77.5946,
    instructions: 'Kitchen sink is leaking. Please bring necessary tools.',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    acceptedAt: DateTime.now().subtract(const Duration(hours: 1)),
  );
});
