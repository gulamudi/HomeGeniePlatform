import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/job_details_provider.dart';

class JobDetailsScreen extends ConsumerWidget {
  final String jobId;

  const JobDetailsScreen({
    super.key,
    required this.jobId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobAsync = ref.watch(jobDetailsProvider(jobId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.support_agent),
            onPressed: () => context.push(AppConstants.routeSupport),
          ),
        ],
      ),
      body: jobAsync.when(
        data: (job) => _buildJobDetails(context, ref, job),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
              const SizedBox(height: 16),
              Text('Error loading job details'),
              TextButton(
                onPressed: () => ref.invalidate(jobDetailsProvider(jobId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobDetails(BuildContext context, WidgetRef ref, Job job) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Customer info card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  child: Text(
                    job.customerName[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppTheme.primaryBlue,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  job.customerName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Booking ID: ${job.bookingId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (job.customerPhone != null &&
                    job.status != AppConstants.jobStatusPending) ...[
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _makeCall(job.customerPhone!),
                        icon: const Icon(Icons.call),
                        label: const Text('Call'),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton.icon(
                        onPressed: () => _sendMessage(job.customerPhone!),
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Job details card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                _buildDetailRow(
                  context,
                  Icons.home_repair_service,
                  'Service',
                  job.serviceName,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.calendar_today,
                  'Date',
                  DateFormat('dd MMMM yyyy').format(job.scheduledDate),
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.access_time,
                  'Time',
                  job.scheduledTime ?? 'Not set',
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  context,
                  Icons.location_on,
                  'Address',
                  job.address,
                ),
                if (job.instructions != null) ...[
                  const SizedBox(height: 12),
                  Divider(height: 1, color: AppTheme.dividerColor),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    context,
                    Icons.note,
                    'Instructions',
                    job.instructions!,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Payment details card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(AppTheme.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Payment Details',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Service Amount',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      '₹${job.amount.toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Earning (80%)',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.successGreen,
                      ),
                    ),
                    Text(
                      '₹${(job.partnerEarning ?? job.amount * 0.8).toStringAsFixed(0)}',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.successGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 80), // Space for bottom buttons
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.iconSecondary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _makeCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _sendMessage(String phone) async {
    final uri = Uri.parse('sms:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
