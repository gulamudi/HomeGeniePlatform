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
        return Icons.home_outlined;
      case 'plumbing':
        return Icons.plumbing;
      case 'electrical':
        return Icons.bolt;
      case 'gardening':
        return Icons.eco_outlined;
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

  String _getCategorySubtitle(String category) {
    switch (category.toLowerCase()) {
      case 'cleaning':
        return 'Home & Office';
      case 'plumbing':
        return 'Fix leaks';
      case 'electrical':
        return 'Wiring & more';
      case 'gardening':
        return 'Lawn & garden';
      case 'handyman':
        return 'Repairs';
      case 'beauty':
        return 'Services';
      case 'appliance_repair':
        return 'Fix & repair';
      case 'painting':
        return 'Interior & exterior';
      case 'pest_control':
        return 'Safe removal';
      case 'home_security':
        return 'Installation';
      default:
        return 'Professional service';
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
      backgroundColor: const Color(0xFFF6F7F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                'What do you need help with today?',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemCount: uniqueCategories.length,
                  itemBuilder: (context, index) {
                    final category = uniqueCategories[index];
                    // Capitalize first letter of each word
                    final displayName = category.split('_').map((word) =>
                      word[0].toUpperCase() + word.substring(1)
                    ).join(' ');

                    return _ServiceCard(
                      name: displayName,
                      subtitle: _getCategorySubtitle(category),
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
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              offset: const Offset(0, 1),
              blurRadius: 3,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xFF1173D4).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1173D4),
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
