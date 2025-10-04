import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/theme/app_theme.dart';
import '../providers/job_alerts_provider.dart';

class JobAlertDialog extends ConsumerStatefulWidget {
  final JobAlert alert;

  const JobAlertDialog({
    super.key,
    required this.alert,
  });

  @override
  ConsumerState<JobAlertDialog> createState() => _JobAlertDialogState();
}

class _JobAlertDialogState extends ConsumerState<JobAlertDialog> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Text(
                  'New Job Available',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please review the details below.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Job details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _buildDetailItem(
                  icon: Icons.home_repair_service,
                  label: 'Service',
                  value: widget.alert.serviceName,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  icon: Icons.location_on,
                  label: 'Location',
                  value: widget.alert.address,
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  icon: Icons.attach_money,
                  label: 'Estimated Pay',
                  value: '₹${widget.alert.amount.toStringAsFixed(2)}',
                ),
                const SizedBox(height: 16),
                _buildDetailItem(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: _formatTime(widget.alert.scheduledDate),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.black12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isProcessing ? null : _onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryBlue,
                      side: BorderSide(
                        color: AppTheme.primaryBlue.withOpacity(0.3),
                      ),
                      backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Reject',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _onAccept,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Accept',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayText;
    if (jobDate == today) {
      dayText = 'Today';
    } else if (jobDate == today.add(const Duration(days: 1))) {
      dayText = 'Tomorrow';
    } else {
      dayText = DateFormat('MMM d').format(dateTime);
    }

    final timeText = DateFormat('h:mm a').format(dateTime);
    return '$dayText, $timeText';
  }

  Future<void> _onAccept() async {
    setState(() => _isProcessing = true);

    try {
      await ref.read(jobAlertsProvider.notifier).acceptJob(
            widget.alert.id,
            'partner-id', // This should come from auth
          );

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job accepted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _onReject() async {
    setState(() => _isProcessing = true);

    try {
      await ref.read(jobAlertsProvider.notifier).rejectJob(widget.alert.id);

      if (mounted) {
        Navigator.of(context).pop(false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject job: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
