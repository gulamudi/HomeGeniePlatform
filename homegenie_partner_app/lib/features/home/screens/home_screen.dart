import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/jobs_provider.dart';
import '../../jobs/widgets/job_card.dart';
import '../../auth/providers/auth_provider.dart';
import '../../jobs/providers/job_actions_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Invalidate providers to ensure fresh data on login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(jobsProvider(AppConstants.tabToday));
      ref.invalidate(jobsProvider(AppConstants.tabUpcoming));
      ref.invalidate(jobsProvider(AppConstants.tabAvailable));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final authState = ref.watch(authProvider);
    final profilePhoto = authState.partner?.profilePhoto;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => context.push(AppConstants.routeProfile),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: profilePhoto != null
                  ? NetworkImage(profilePhoto)
                  : null,
              backgroundColor: AppTheme.primaryBlue,
              child: profilePhoto == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Today's Jobs"),
                Tab(text: 'Upcoming'),
                Tab(text: 'Available'),
              ],
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              indicator: BoxDecoration(
                color: AppTheme.primaryBlue,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildJobsList(AppConstants.tabToday),
        _buildJobsList(AppConstants.tabUpcoming),
        _buildJobsList(AppConstants.tabAvailable),
      ],
    );
  }

  Widget _buildJobsList(String tab) {
    final jobsAsync = ref.watch(jobsProvider(tab));
    final jobActions = ref.watch(jobActionsProvider);

    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(jobsProvider(tab));
            },
            child: ListView(
              children: [
                const SizedBox(height: 80),
                _buildEmptyState(tab),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(jobsProvider(tab));
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
                onAccept: tab == AppConstants.tabAvailable
                    ? () => _handleAcceptJob(job.id)
                    : null,
                onReject: tab == AppConstants.tabAvailable
                    ? () => _handleRejectJob(job.id)
                    : null,
                isHighlighted: tab == AppConstants.tabToday && index == 0,
                showDate: tab == AppConstants.tabUpcoming || tab == AppConstants.tabAvailable,
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
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text('Error loading jobs: ${error.toString()}'),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => ref.invalidate(jobsProvider(tab)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAcceptJob(String jobId) async {
    final jobActions = ref.read(jobActionsProvider);
    try {
      await jobActions.acceptJob(jobId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job accepted successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        // Refresh all job lists
        ref.invalidate(jobsProvider(AppConstants.tabAvailable));
        ref.invalidate(jobsProvider(AppConstants.tabToday));
        ref.invalidate(jobsProvider(AppConstants.tabUpcoming));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept job: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _handleRejectJob(String jobId) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Job'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Why are you rejecting this job?'),
            const SizedBox(height: 16),
            ...AppConstants.cancelReasons.map((reason) {
              return ListTile(
                title: Text(reason),
                onTap: () => Navigator.pop(context, reason),
              );
            }).toList(),
          ],
        ),
      ),
    );

    if (result != null) {
      final jobActions = ref.read(jobActionsProvider);
      try {
        await jobActions.rejectJob(jobId, result);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Job rejected'),
              backgroundColor: AppTheme.textSecondary,
            ),
          );
          // Refresh all job lists
          ref.invalidate(jobsProvider(AppConstants.tabAvailable));
          ref.invalidate(jobsProvider(AppConstants.tabToday));
          ref.invalidate(jobsProvider(AppConstants.tabUpcoming));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject job: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  Widget _buildEmptyState(String tab) {
    String title;
    String subtitle;
    IconData icon;
    String imageName;

    switch (tab) {
      case AppConstants.tabToday:
        title = "No jobs scheduled for today";
        subtitle = "Check back later for new job opportunities";
        icon = Icons.event_available;
        imageName = 'empty_today';
        break;
      case AppConstants.tabUpcoming:
        title = "No upcoming jobs";
        subtitle = "Your accepted jobs will appear here";
        icon = Icons.calendar_today;
        imageName = 'empty_upcoming';
        break;
      case AppConstants.tabHistory:
        title = "No job history yet";
        subtitle = "Completed jobs will show up here";
        icon = Icons.history;
        imageName = 'empty_history';
        break;
      case AppConstants.tabAvailable:
        title = "No available jobs at the moment";
        subtitle = "New jobs matching your skills will appear here";
        icon = Icons.work_outline;
        imageName = 'empty_available';
        break;
      default:
        title = "No jobs found";
        subtitle = "Check back later";
        icon = Icons.work_outline;
        imageName = 'empty_jobs';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEmptyStateImage(imageName, icon),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyStateImage(String imageName, IconData fallbackIcon) {
    return Image.asset(
      'assets/images/$imageName.png',
      width: 200,
      height: 200,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(fallbackIcon, size: 64, color: AppTheme.iconSecondary);
      },
    );
  }
}
