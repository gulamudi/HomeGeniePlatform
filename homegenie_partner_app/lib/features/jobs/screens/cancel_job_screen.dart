import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';

class CancelJobScreen extends StatefulWidget {
  final String jobId;

  const CancelJobScreen({
    super.key,
    required this.jobId,
  });

  @override
  State<CancelJobScreen> createState() => _CancelJobScreenState();
}

class _CancelJobScreenState extends State<CancelJobScreen> {
  String? _selectedReason;

  final List<Map<String, String>> _cancellationReasons = [
    {'value': 'emergency', 'label': 'Emergency'},
    {'value': 'customer_unavailable', 'label': 'Customer not available'},
    {'value': 'job_details_issue', 'label': 'Issue with job details'},
    {'value': 'other', 'label': 'Other'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Cancel Job',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Warning message
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber[200]!,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.amber[700],
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cancellation Warning',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Cancelling this job may affect your partner rating and future job opportunities. Please cancel only if absolutely necessary.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reason section
              Text(
                'Reason for Cancellation',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Cancellation reasons
              ..._cancellationReasons.map((reason) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedReason = reason['value'];
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedReason == reason['value']
                              ? AppTheme.primaryBlue
                              : Colors.grey[300]!,
                          width: _selectedReason == reason['value'] ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: reason['value']!,
                            groupValue: _selectedReason,
                            onChanged: (value) {
                              setState(() {
                                _selectedReason = value;
                              });
                            },
                            activeColor: AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            reason['label']!,
                            style: const TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),

              const SizedBox(height: 24),

              // Contact Support button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to support
                    context.push('/support');
                  },
                  icon: const Icon(Icons.headset_mic),
                  label: const Text('Contact Support'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    backgroundColor: Colors.grey[100],
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Colors.black12),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _selectedReason != null
                  ? () {
                      _showCancellationConfirmation();
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorRed,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Confirm Cancellation',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancellationConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Cancellation'),
        content: const Text(
          'Are you sure you want to cancel this job? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Cancel the job and navigate back
              context.go('/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Yes, Cancel Job'),
          ),
        ],
      ),
    );
  }
}
