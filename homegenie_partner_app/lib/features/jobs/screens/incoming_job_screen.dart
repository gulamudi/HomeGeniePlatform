import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared/theme/app_theme.dart';
import '../providers/job_alerts_provider.dart';
import '../../../core/services/supabase_service.dart';
import '../../home/providers/jobs_provider.dart';
import '../../../core/constants/app_constants.dart';

/// Full-screen incoming call-like UI for job offers
/// Triggered when partner receives a new job notification via Supabase Realtime
class IncomingJobScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> jobData;

  const IncomingJobScreen({
    super.key,
    required this.jobData,
  });

  @override
  ConsumerState<IncomingJobScreen> createState() => _IncomingJobScreenState();
}

class _IncomingJobScreenState extends ConsumerState<IncomingJobScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();

    // Create pulsing animation for the accept button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final serviceName = widget.jobData['service_name'] ?? 'Service';
    final amount = widget.jobData['amount']?.toString() ?? '0';
    final address = widget.jobData['address'] ?? 'Address not provided';
    final scheduledDate = widget.jobData['scheduled_date'] != null
        ? DateTime.parse(widget.jobData['scheduled_date'])
        : DateTime.now();
    final customerName = widget.jobData['customer_name'] ?? 'Customer';
    final instructions = widget.jobData['instructions'] ?? '';

    return Scaffold(
      backgroundColor: AppTheme.primaryBlue,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Incoming call icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: const Icon(
                      Icons.work_outline,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'New Job Opportunity',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Job details card
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Service name - prominent
                      Text(
                        serviceName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 8),

                      // Amount - highlighted
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '\$$amount',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Location
                      _buildInfoRow(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: address,
                      ),

                      const SizedBox(height: 16),

                      // Time
                      _buildInfoRow(
                        icon: Icons.access_time,
                        label: 'Scheduled',
                        value: _formatDateTime(scheduledDate),
                      ),

                      if (instructions.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildInfoRow(
                          icon: Icons.notes,
                          label: 'Instructions',
                          value: instructions,
                        ),
                      ],

                      const SizedBox(height: 40),

                      // Action buttons
                      Row(
                        children: [
                          // Reject button
                          Expanded(
                            child: _buildRejectButton(),
                          ),

                          const SizedBox(width: 16),

                          // Accept button with pulse animation
                          Expanded(
                            flex: 2,
                            child: _buildAcceptButton(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Dismissive message
                      Text(
                        'Tap reject if you cannot take this job',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary.withOpacity(0.7),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppTheme.textPrimary,
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

  Widget _buildRejectButton() {
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : _onReject,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red[50],
          foregroundColor: Colors.red[700],
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.red[200]!),
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.close, size: 24),
            SizedBox(height: 2),
            Text(
              'Reject',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAcceptButton() {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: SizedBox(
        height: 60,
        child: ElevatedButton(
          onPressed: _isProcessing ? null : _onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            foregroundColor: Colors.white,
            elevation: 4,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shadowColor: Colors.green[600]!.withOpacity(0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: _isProcessing
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, size: 24),
                    SizedBox(height: 2),
                    Text(
                      'Accept',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final jobDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    String dayText;
    if (jobDate == today) {
      dayText = 'Today';
    } else if (jobDate == today.add(const Duration(days: 1))) {
      dayText = 'Tomorrow';
    } else {
      dayText = DateFormat('MMM d, yyyy').format(dateTime);
    }

    final timeText = DateFormat('h:mm a').format(dateTime);
    return '$dayText at $timeText';
  }

  Future<void> _onAccept() async {
    setState(() => _isProcessing = true);

    try {
      final bookingId = widget.jobData['booking_id'];
      final partnerId = SupabaseService.instance.currentUserId;

      print('🔵 [IncomingJobScreen] Accepting job...');
      print('   Booking ID: $bookingId');
      print('   Partner ID: $partnerId');
      print('   Job data: ${widget.jobData}');

      if (partnerId == null) {
        throw Exception('Partner not authenticated');
      }

      await ref.read(jobAlertsProvider.notifier).acceptJob(
            bookingId,
            partnerId,
          );

      print('✅ [IncomingJobScreen] Job accepted successfully!');

      // Refresh job lists
      ref.invalidate(jobsProvider(AppConstants.tabToday));
      ref.invalidate(jobsProvider(AppConstants.tabUpcoming));
      ref.invalidate(jobsProvider(AppConstants.tabAvailable));

      if (mounted) {
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Job accepted successfully!'),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('❌ [IncomingJobScreen] Failed to accept job: $e');
      print('   Stack trace: $stackTrace');

      if (mounted) {
        // Show error dialog with full details
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Failed to Accept Job'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Error Details:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    e.toString(),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
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
      final bookingId = widget.jobData['booking_id'];
      await ref.read(jobAlertsProvider.notifier).rejectJob(bookingId);

      // Refresh job lists
      ref.invalidate(jobsProvider(AppConstants.tabToday));
      ref.invalidate(jobsProvider(AppConstants.tabUpcoming));
      ref.invalidate(jobsProvider(AppConstants.tabAvailable));

      if (mounted) {
        Navigator.of(context).pop(false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.info, color: Colors.white),
                SizedBox(width: 12),
                Text('Job declined'),
              ],
            ),
            backgroundColor: Colors.grey[700],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Failed to reject job',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
