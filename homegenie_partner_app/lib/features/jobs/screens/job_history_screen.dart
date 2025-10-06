import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../home/providers/jobs_provider.dart';
import '../widgets/job_card.dart';

class JobHistoryScreen extends ConsumerWidget {
  const JobHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsProvider(AppConstants.tabHistory));

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Job History'),
      ),
      body: jobsAsync.when(
        data: (jobs) {
          if (jobs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 64,
                    color: AppTheme.iconSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No job history yet',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(jobsProvider(AppConstants.tabHistory));
            },
            child: ListView.separated(
              padding: const EdgeInsets.all(AppTheme.paddingMedium),
              itemCount: jobs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final job = jobs[index];
                return JobCard(
                  job: job,
                  onTap: () => context.push(
                    '${AppConstants.routeJobDetails}?jobId=${job.id}',
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppTheme.errorRed,
              ),
              const SizedBox(height: 16),
              Text('Error loading job history: ${error.toString()}'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.invalidate(jobsProvider(AppConstants.tabHistory)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
