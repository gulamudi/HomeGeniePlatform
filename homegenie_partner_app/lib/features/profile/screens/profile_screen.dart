import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(AppTheme.paddingLarge),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    authState.partner?.name ?? 'Partner Name',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    authState.partner?.phone ?? '+91 **********',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStatItem(
                        context,
                        '4.5',
                        'Rating',
                        Icons.star,
                      ),
                      const SizedBox(width: 32),
                      _buildStatItem(
                        context,
                        '20',
                        'Jobs',
                        Icons.work,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Menu items
            _buildMenuItem(
              context,
              Icons.person_outline,
              'Personal Information',
              () {
                // Navigate to edit profile
              },
            ),
            _buildMenuItem(
              context,
              Icons.verified_user_outlined,
              'Documents',
              () => context.push(AppConstants.routeDocumentVerification),
            ),
            _buildMenuItem(
              context,
              Icons.payment,
              'Payment Methods',
              () {
                // Navigate to payment methods
              },
            ),
            _buildMenuItem(
              context,
              Icons.history,
              'Job History',
              () {
                // Navigate to job history
              },
            ),

            const SizedBox(height: 16),

            _buildMenuItem(
              context,
              Icons.help_outline,
              'Help & Support',
              () => context.push(AppConstants.routeSupport),
            ),
            _buildMenuItem(
              context,
              Icons.info_outline,
              'How to Manage Payments',
              () => context.push(AppConstants.routePaymentGuide),
            ),
            _buildMenuItem(
              context,
              Icons.privacy_tip_outlined,
              'Privacy Policy',
              () {
                // Show privacy policy
              },
            ),
            _buildMenuItem(
              context,
              Icons.description_outlined,
              'Terms & Conditions',
              () {
                // Show terms
              },
            ),

            const SizedBox(height: 16),

            // Logout button
            Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context, ref);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.errorRed,
                  side: const BorderSide(color: AppTheme.errorRed),
                  padding: const EdgeInsets.all(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // App version
            Text(
              'Version 1.0.0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textHint,
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.warningYellow),
            const SizedBox(width: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: AppTheme.iconSecondary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.iconSecondary),
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                context.go(AppConstants.routeLogin);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
