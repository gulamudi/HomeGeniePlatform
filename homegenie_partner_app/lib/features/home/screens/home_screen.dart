import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/jobs_provider.dart';
import '../../jobs/widgets/job_card.dart';
import '../../auth/providers/auth_provider.dart';

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
        preferredSize: const Size.fromHeight(48),
        child: Column(
          children: [
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.black12,
                    width: 1,
                  ),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: "Today's Jobs"),
                  Tab(text: 'Upcoming'),
                  Tab(text: 'History'),
                ],
                labelColor: AppTheme.primaryBlue,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                indicatorColor: AppTheme.primaryBlue,
                indicatorWeight: 2,
              ),
            ),
          ],
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
        _buildJobsList(AppConstants.tabHistory),
      ],
    );
  }

  Widget _buildJobsList(String tab) {
    final jobsAsync = ref.watch(jobsProvider(tab));

    return jobsAsync.when(
      data: (jobs) {
        if (jobs.isEmpty) {
          return _buildEmptyState(tab);
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
              return JobCard(
                job: jobs[index],
                onTap: () => context.push(
                  '${AppConstants.routeJobDetails}?jobId=${jobs[index].id}',
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
            const Icon(Icons.error_outline, size: 48, color: AppTheme.errorRed),
            const SizedBox(height: 16),
            Text('Error loading jobs'),
            TextButton(
              onPressed: () => ref.invalidate(jobsProvider(tab)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String tab) {
    String message;
    IconData icon;

    switch (tab) {
      case AppConstants.tabToday:
        message = "No jobs scheduled for today";
        icon = Icons.event_available;
        break;
      case AppConstants.tabUpcoming:
        message = "No upcoming jobs";
        icon = Icons.calendar_today;
        break;
      case AppConstants.tabHistory:
        message = "No job history yet";
        icon = Icons.history;
        break;
      default:
        message = "No jobs found";
        icon = Icons.work_outline;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppTheme.iconSecondary),
          const SizedBox(height: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
