import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../providers/services_provider.dart';
import '../../../auth/providers/auth_provider.dart';

class ServiceSelectionPage extends ConsumerWidget {
  const ServiceSelectionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final services = ref.watch(servicesProvider);
    final user = ref.watch(currentUserProvider);

    // Group services by main categories
    final mainCategories = [
      {'name': 'Cleaning', 'icon': Icons.cleaning_services},
      {'name': 'Plumbing', 'icon': Icons.plumbing},
      {'name': 'Electrical', 'icon': Icons.electrical_services},
      {'name': 'Gardening', 'icon': Icons.park_outlined},
      {'name': 'Handyman', 'icon': Icons.handyman},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const Text(
          'HomeGenie',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: GestureDetector(
              onTap: () {
                context.go('/');
                // Navigate to index 2 (Profile) in main navigation
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
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
              itemCount: mainCategories.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final category = mainCategories[index];
                return _ServiceCard(
                  name: category['name'] as String,
                  icon: category['icon'] as IconData,
                  onTap: () {
                    // Find service by category
                    final service = services.firstWhere(
                      (s) => s.category.toLowerCase() == (category['name'] as String).toLowerCase() ||
                             s.name.toLowerCase().contains((category['name'] as String).toLowerCase()),
                      orElse: () => services.first,
                    );
                    context.push('/service/${service.id}');
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor.withOpacity(0.8),
          border: const Border(
            top: BorderSide(color: AppTheme.borderColor, width: 1),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _BottomNavItem(
                  icon: Icons.home,
                  label: 'Home',
                  isActive: true,
                  onTap: () => context.go('/'),
                ),
                _BottomNavItem(
                  icon: Icons.calendar_today,
                  label: 'Bookings',
                  isActive: false,
                  onTap: () => context.go('/'),
                ),
                _BottomNavItem(
                  icon: Icons.person,
                  label: 'Profile',
                  isActive: false,
                  onTap: () => context.go('/'),
                ),
              ],
            ),
          ),
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

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 32,
            child: Icon(
              icon,
              color: isActive ? AppTheme.primaryBlue : AppTheme.iconSecondary,
              size: 24,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              color: isActive ? AppTheme.primaryBlue : AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
