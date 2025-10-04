import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';

// Mock jobs provider - in production, this would fetch from API
final jobsProvider = FutureProvider.family<List<Job>, String>((ref, tab) async {
  // Simulate API call
  await Future.delayed(const Duration(seconds: 1));

  // Generate mock jobs based on tab
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);

  switch (tab) {
    case AppConstants.tabToday:
      return _getMockJobsForDate(today);
    case AppConstants.tabUpcoming:
      return _getMockJobsForDate(today.add(const Duration(days: 1)));
    case AppConstants.tabHistory:
      return _getMockCompletedJobs(today.subtract(const Duration(days: 7)));
    default:
      return [];
  }
});

List<Job> _getMockJobsForDate(DateTime date) {
  return [
    Job(
      id: 'job1',
      bookingId: 'BK001',
      serviceType: 'plumbing',
      serviceName: 'Plumbing Service',
      status: AppConstants.jobStatusAccepted,
      scheduledDate: date,
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
    ),
    Job(
      id: 'job2',
      bookingId: 'BK002',
      serviceType: 'electrical',
      serviceName: 'Electrical Repair',
      status: AppConstants.jobStatusPending,
      scheduledDate: date,
      scheduledTime: '2:00 PM',
      amount: 800.0,
      partnerEarning: 640.0,
      customerId: 'cust2',
      customerName: 'Priya Patel',
      customerPhone: '9876543211',
      address: '456, Whitefield, Bangalore - 560066',
      latitude: 12.9698,
      longitude: 77.7500,
      instructions: 'Multiple switches not working in bedroom.',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];
}

List<Job> _getMockCompletedJobs(DateTime startDate) {
  return [
    Job(
      id: 'job3',
      bookingId: 'BK003',
      serviceType: 'cleaning',
      serviceName: 'Deep Cleaning',
      status: AppConstants.jobStatusCompleted,
      scheduledDate: startDate,
      scheduledTime: '11:00 AM',
      amount: 1200.0,
      partnerEarning: 960.0,
      customerId: 'cust3',
      customerName: 'Amit Kumar',
      address: '789, Indiranagar, Bangalore - 560038',
      createdAt: startDate.subtract(const Duration(days: 1)),
      acceptedAt: startDate.subtract(const Duration(hours: 12)),
      startedAt: startDate.add(const Duration(hours: 11)),
      completedAt: startDate.add(const Duration(hours: 14)),
      rating: 5,
      review: 'Excellent work! Very professional.',
    ),
  ];
}
