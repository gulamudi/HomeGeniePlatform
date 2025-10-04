import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../providers/jobs_provider.dart';
import '../../jobs/widgets/job_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomNavIndex = 0;

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
      appBar: _currentBottomNavIndex == 0 ? _buildAppBar() : null,
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
              'https://via.placeholder.com/150',
            ),
          ),
          Expanded(
            child: Text(
              'HomeGenie Partner',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const SizedBox(width: 32),
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
    switch (_currentBottomNavIndex) {
      case 0:
        return _buildJobsTab();
      case 1:
        return _buildEarningsPlaceholder();
      case 2:
        return _buildPreferencesPlaceholder();
      default:
        return _buildJobsTab();
    }
  }

  Widget _buildJobsTab() {
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

  Widget _buildEarningsPlaceholder() {
    return const Center(child: Text('Earnings Screen'));
  }

  Widget _buildPreferencesPlaceholder() {
    return const Center(child: Text('Preferences Screen'));
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.black12, width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() => _currentBottomNavIndex = index);
          if (index == 1) {
            context.push(AppConstants.routeEarnings);
          } else if (index == 3) {
            context.push(AppConstants.routeProfile);
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryBlue,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: 'Jobs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
