import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../shared/theme/app_theme.dart';
import '../providers/earnings_provider.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(earningsSummaryProvider);
    final transactionsAsync = ref.watch(earningsTransactionsProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Earnings'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary card
            summaryAsync.when(
              data: (summary) => Container(
                margin: const EdgeInsets.all(AppTheme.paddingMedium),
                padding: const EdgeInsets.all(AppTheme.paddingLarge),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryBlue, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Column(
                  children: [
                    Text(
                      'Available Balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '₹${summary.availableForWithdrawal.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'Total Earned',
                            '₹${summary.totalEarnings.toStringAsFixed(0)}',
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Expanded(
                          child: _buildSummaryItem(
                            context,
                            'Jobs Completed',
                            '${summary.completedJobs}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator(color: Colors.white)),
              ),
              error: (_, __) => const SizedBox(),
            ),

            // Withdraw button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Show withdraw dialog
                  _showWithdrawDialog(context);
                },
                icon: const Icon(Icons.account_balance_wallet),
                label: const Text('Withdraw Money'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Transactions list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.paddingMedium),
              child: Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            transactionsAsync.when(
              data: (transactions) => ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppTheme.paddingMedium),
                itemCount: transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getTransactionColor(transaction.type).withOpacity(0.1),
                        child: Icon(
                          _getTransactionIcon(transaction.type),
                          color: _getTransactionColor(transaction.type),
                        ),
                      ),
                      title: Text(transaction.jobName ?? transaction.type),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(transaction.transactionDate),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      trailing: Text(
                        '${transaction.type == 'withdrawal' ? '-' : '+'}₹${transaction.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: transaction.type == 'withdrawal'
                              ? AppTheme.errorRed
                              : AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => const Center(
                child: Text('Error loading transactions'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'job_payment':
        return Icons.work;
      case 'withdrawal':
        return Icons.account_balance;
      case 'bonus':
        return Icons.card_giftcard;
      default:
        return Icons.payment;
    }
  }

  Color _getTransactionColor(String type) {
    switch (type) {
      case 'job_payment':
      case 'bonus':
        return AppTheme.successGreen;
      case 'withdrawal':
        return AppTheme.primaryBlue;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Withdraw Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Amount',
                prefixText: '₹ ',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Bank Account / UPI ID',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Withdrawal request submitted'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}
