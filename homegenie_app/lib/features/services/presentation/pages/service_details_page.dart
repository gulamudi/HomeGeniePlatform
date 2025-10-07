import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../services/providers/services_provider.dart';
import '../../../booking/providers/booking_provider.dart';

class ServiceDetailsPage extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

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
      default:
        return Icons.home_repair_service;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(serviceByIdProvider(serviceId));

    if (service == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Service not found')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header section
                  Row(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1173D4).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getCategoryIcon(service.category),
                          color: const Color(0xFF1173D4),
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'For a spotless home',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Service Description
                  _buildSection(context, 'Service Description', service.description),
                  const SizedBox(height: 24),

                  // Pricing
                  _buildPricingSection(context, service),
                  const SizedBox(height: 24),

                  // What's Included
                  _buildIncludedSection(context, service.includes),
                  const SizedBox(height: 24),

                  // What's Excluded
                  _buildExcludedSection(context, service.excludes),
                  const SizedBox(height: 24),

                  // Terms & Conditions
                  _buildTermsSection(context),
                ],
              ),
            ),
          ),

          // Bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              decoration: const BoxDecoration(
                color: Color(0xFFF6F7F8),
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(bookingProvider.notifier).setService(serviceId, service.base_price);
                      context.push('/booking/select-date-time?serviceId=$serviceId&basePrice=${service.base_price}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173D4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Book Now',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF475569),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection(BuildContext context, service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pricing',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Base Price',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  Text(
                    '\$${service.base_price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Price may vary based on home size and specific requirements.',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIncludedSection(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s Included',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                size: 24,
                color: Color(0xFF22C55E),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildExcludedSection(BuildContext context, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What\'s Excluded',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.cancel,
                size: 24,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildTermsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Terms & Conditions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Cancellations must be made at least 24 hours in advance. We are not liable for any pre-existing damage. Our team will arrive within a 1-hour window of your scheduled appointment time.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: Color(0xFF64748B),
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
