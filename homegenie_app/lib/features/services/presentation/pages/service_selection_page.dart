import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class ServiceSelectionPage extends ConsumerWidget {
  const ServiceSelectionPage({super.key});

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return Icons.cleaning_services;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.electrical_services;
      case 'gardening':
        return Icons.park_outlined;
      case 'handyman':
        return Icons.handyman;
      case 'beauty':
        return Icons.face;
      case 'appliance_repair':
        return Icons.build;
      case 'painting':
        return Icons.format_paint;
      case 'pest_control':
        return Icons.pest_control;
      case 'home_security':
        return Icons.security;
      default:
        return Icons.home_repair_service;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final user = ref.watch(currentUserProvider);

    // Group services by category
    final uniqueCategories = services
        .map((s) => s.category)
        .toSet()
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'What service do you need?',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: uniqueCategories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = uniqueCategories[index];
                // Capitalize first letter of each word
                final displayName = category.split('_').map((word) =>
                  word[0].toUpperCase() + word.substring(1)
                ).join(' ');

                return _ServiceCard(
                  name: displayName,
                  icon: _getCategoryIcon(category),
                  onTap: () {
                    // Find first service in this category
                    final service = services.firstWhere(
                      (s) => s.category == category,
                    );
                    context.push('/service/${service.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 1),
              blurRadius: 3,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
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
              child: Text(
                name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppTheme.iconSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
