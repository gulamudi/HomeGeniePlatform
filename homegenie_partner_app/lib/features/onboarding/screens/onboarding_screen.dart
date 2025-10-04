import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Icon
              Icon(
                Icons.handshake,
                size: 100,
                color: AppTheme.primaryBlue,
              ),

              const SizedBox(height: 32),

              // Welcome Title
              Text(
                'Welcome to\nHomeGenie Partner!',
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              Text(
                'Start earning by providing quality home services',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Features
              _buildFeatureItem(
                context,
                Icons.work,
                'Get Jobs',
                'Receive job requests based on your skills and location',
              ),

              const SizedBox(height: 20),

              _buildFeatureItem(
                context,
                Icons.attach_money,
                'Earn Money',
                'Complete jobs and get paid directly to your account',
              ),

              const SizedBox(height: 20),

              _buildFeatureItem(
                context,
                Icons.schedule,
                'Flexible Hours',
                'Work on your own schedule and availability',
              ),

              const Spacer(),

              // Continue button
              ElevatedButton(
                onPressed: () => context.go(AppConstants.routeDocumentVerification),
                child: const Text('Get Started'),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryBlue,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
