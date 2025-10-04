import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/earnings.dart';

final earningsSummaryProvider = FutureProvider<EarningsSummary>((ref) async {
  await Future.delayed(const Duration(seconds: 1));

  return EarningsSummary(
    totalEarnings: 15000.0,
    pendingAmount: 2000.0,
    withdrawnAmount: 10000.0,
    availableForWithdrawal: 5000.0,
    totalJobs: 25,
    completedJobs: 20,
    averageRating: 4.5,
  );
});

final earningsTransactionsProvider = FutureProvider<List<EarningsTransaction>>((ref) async {
  await Future.delayed(const Duration(seconds: 1));

  return [
    EarningsTransaction(
      id: '1',
      type: 'job_payment',
      amount: 400.0,
      status: 'completed',
      jobId: 'job1',
      jobName: 'Plumbing Service',
      transactionDate: DateTime.now().subtract(const Duration(days: 1)),
      completedAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    EarningsTransaction(
      id: '2',
      type: 'withdrawal',
      amount: 5000.0,
      status: 'completed',
      description: 'Withdrawn to bank account',
      transactionDate: DateTime.now().subtract(const Duration(days: 3)),
      completedAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
    EarningsTransaction(
      id: '3',
      type: 'job_payment',
      amount: 800.0,
      status: 'completed',
      jobId: 'job2',
      jobName: 'Electrical Repair',
      transactionDate: DateTime.now().subtract(const Duration(days: 5)),
      completedAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
    EarningsTransaction(
      id: '4',
      type: 'bonus',
      amount: 500.0,
      status: 'completed',
      description: 'Rating bonus',
      transactionDate: DateTime.now().subtract(const Duration(days: 7)),
      completedAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];
});
