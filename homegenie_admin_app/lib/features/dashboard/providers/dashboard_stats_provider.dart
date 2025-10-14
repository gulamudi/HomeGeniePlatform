import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/dashboard_stats.dart';
import '../../../core/network/admin_api_service.dart';

final dashboardStatsProvider = FutureProvider.autoDispose<DashboardStats>((ref) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getDashboardStats();
});
