import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/models/job.dart';
import '../../../core/constants/app_constants.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with status
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.serviceName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  _buildStatusBadge(job.status),
                ],
              ),

              const SizedBox(height: 12),

              // Customer info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Text(
                      job.customerName[0].toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.customerName,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Booking ID: ${job.bookingId}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: AppTheme.dividerColor),
              const SizedBox(height: 12),

              // Details grid
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.calendar_today,
                      DateFormat('dd MMM yyyy').format(job.scheduledDate),
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      Icons.access_time,
                      job.scheduledTime ?? 'Not set',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              _buildInfoItem(
                context,
                Icons.location_on,
                job.address,
              ),

              const SizedBox(height: 12),
              Divider(height: 1, color: AppTheme.dividerColor),
              const SizedBox(height: 12),

              // Amount and action
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Earning',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${job.partnerEarning?.toStringAsFixed(0) ?? job.amount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (job.status == AppConstants.jobStatusPending)
                    OutlinedButton(
                      onPressed: onTap,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('View Details'),
                    ),
                  if (job.status == AppConstants.jobStatusAccepted)
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Start Job'),
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
                        index < job.rating!
                            ? Icons.star
                            : Icons.star_border,
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
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppTheme.iconSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
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
