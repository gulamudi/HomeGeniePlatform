import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../services/providers/services_provider.dart';
import '../../../booking/providers/booking_provider.dart';

class ServiceDetailsPage extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

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
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(service.name),
              background: Container(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                child: const Icon(
                  Icons.home_repair_service_outlined,
                  size: 80,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPriceCard(context, service),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildSection(context, 'Description', service.description),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildListSection(context, 'What\'s Included', service.includes),
                  const SizedBox(height: AppTheme.paddingMedium),
                  _buildListSection(context, 'What\'s Excluded', service.excludes),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                ref.read(bookingProvider.notifier).setService(serviceId, service.base_price);
                context.push('/booking/select-date-time?serviceId=$serviceId');
              },
              child: const Text('Book Now'),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPriceCard(BuildContext context, service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.paddingMedium),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Icon(
                Icons.currency_rupee,
                color: AppTheme.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Starting from',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '₹${service.base_price.toStringAsFixed(0)}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Duration',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  '${service.duration_hours} hrs',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildListSection(BuildContext context, String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppTheme.successGreen,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
}
