import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isHighlighted;
  final bool showDate;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onAccept,
    this.onReject,
    this.isHighlighted = false,
    this.showDate = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isHighlighted) {
      return _buildHighlightedCard(context);
    }
    return _buildRegularCard(context);
  }

  Widget _buildHighlightedCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryBlue, width: 2),
      ),
      child: Column(
        children: [
          // Header with "Next Job" label
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Next Job',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  _getStartsInText(),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
          // Inner card
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildCardContent(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegularCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _buildCardContent(context),
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top row: Icon, Customer name, Address, Status badge
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service icon
            Icon(
              _getServiceIcon(),
              size: 28,
              color: isHighlighted ? AppTheme.primaryBlue : AppTheme.iconSecondary,
            ),
            const SizedBox(width: 16),
            // Customer name and address
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.customerName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.address,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status badge
            if (!isHighlighted) _buildStatusBadge(job.status),
          ],
        ),

        const SizedBox(height: 12),

        // Service name and time
        Row(
          children: [
            Icon(
              _getServiceIcon(),
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                job.serviceName,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Row(
          children: [
            Icon(
              Icons.schedule,
              size: 16,
              color: Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _getFormattedTime(),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),

        // Show date for upcoming/available jobs
        if (showDate) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Colors.grey[600],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  DateFormat('dd MMM yyyy').format(job.scheduledDate),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 12),
        Divider(height: 1, color: AppTheme.dividerColor),
        const SizedBox(height: 12),

        // Earning and action buttons
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Earning',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${job.partnerEarning?.toStringAsFixed(0) ?? job.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            // Action buttons
            if (job.status == AppConstants.jobStatusPending && onAccept != null && onReject != null) ...[
              OutlinedButton(
                onPressed: onReject,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed),
                ),
                child: const Text('Reject'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Accept'),
              ),
            ] else
              OutlinedButton(
                onPressed: onTap,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                ),
                child: const Text('View Details'),
              ),
          ],
        ),

        // Show rating if completed
        if (job.rating != null) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              ...List.generate(5, (index) {
                return Icon(
                  index < job.rating! ? Icons.star : Icons.star_border,
                  size: 16,
                  color: AppTheme.warningYellow,
                );
              }),
              const SizedBox(width: 8),
              if (job.review != null)
                Expanded(
                  child: Text(
                    job.review!,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  IconData _getServiceIcon() {
    final serviceName = job.serviceName.toLowerCase();
    if (serviceName.contains('cleaning')) {
      return Icons.cleaning_services;
    } else if (serviceName.contains('laundry')) {
      return Icons.local_laundry_service;
    } else if (serviceName.contains('cook') || serviceName.contains('chef')) {
      return Icons.soup_kitchen;
    } else if (serviceName.contains('repair') || serviceName.contains('plumb')) {
      return Icons.home_repair_service;
    } else if (serviceName.contains('paint')) {
      return Icons.format_paint;
    } else if (serviceName.contains('electric')) {
      return Icons.electrical_services;
    } else if (serviceName.contains('garden')) {
      return Icons.yard;
    } else {
      return Icons.home;
    }
  }

  String _getFormattedTime() {
    print('🔍 DEBUG _getFormattedTime - scheduledTime: ${job.scheduledTime}');

    if (job.scheduledTime == null) {
      print('⚠️ DEBUG - scheduledTime is null for job ${job.id}');
      return 'Time not set';
    }

    try {
      // Parse time string (format: "HH:mm:ss" or "HH:mm")
      final timeParts = job.scheduledTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Convert to 12-hour format with AM/PM
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      final displayMinute = minute.toString().padLeft(2, '0');

      print('✅ DEBUG - Formatted time: $displayHour:$displayMinute $period');
      return '$displayHour:$displayMinute $period';
    } catch (e) {
      print('❌ DEBUG - Error parsing time: $e');
      // If parsing fails, return the original string
      return job.scheduledTime ?? 'Time not set';
    }
  }

  String _getStartsInText() {
    if (job.scheduledTime == null) return 'Time not set';

    final now = DateTime.now();

    // Parse scheduledTime and combine with scheduledDate
    DateTime scheduledDateTime;
    try {
      // Parse time string (format: "HH:mm:ss" or "HH:mm")
      final timeParts = job.scheduledTime!.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      // Combine date and time
      scheduledDateTime = DateTime(
        job.scheduledDate.year,
        job.scheduledDate.month,
        job.scheduledDate.day,
        hour,
        minute,
      );
    } catch (e) {
      // If parsing fails, return 'Time not set'
      return 'Time not set';
    }

    if (scheduledDateTime.isBefore(now)) {
      return 'Started';
    }

    final difference = scheduledDateTime.difference(now);
    final hours = difference.inHours;
    final minutes = difference.inMinutes % 60;

    if (hours == 0) {
      return '$minutes min from now';
    } else if (minutes == 0) {
      return '$hours hours from now';
    } else {
      return '$hours hours $minutes min from now';
    }
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;

    switch (status) {
      case AppConstants.jobStatusPending:
        color = AppTheme.statusPending;
        label = 'New';
        break;
      case AppConstants.jobStatusAccepted:
      case AppConstants.jobStatusConfirmed:  // Backend uses 'confirmed' for accepted jobs
        color = AppTheme.statusConfirmed;
        label = 'Accepted';
        break;
      case AppConstants.jobStatusInProgress:
        color = AppTheme.statusInProgress;
        label = 'In Progress';
        break;
      case AppConstants.jobStatusCompleted:
        color = AppTheme.statusCompleted;
        label = 'Completed';
        break;
      case AppConstants.jobStatusCancelled:
        color = AppTheme.statusCancelled;
        label = 'Cancelled';
        break;
      default:
        color = AppTheme.textSecondary;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
