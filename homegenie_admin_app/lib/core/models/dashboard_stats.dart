import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_stats.freezed.dart';
part 'dashboard_stats.g.dart';

@freezed
class DashboardStats with _$DashboardStats {
  const factory DashboardStats({
    @JsonKey(name: 'active_bookings') @Default(0) int activeBookings,
    @JsonKey(name: 'pending_verifications') @Default(0) int pendingVerifications,
    @JsonKey(name: 'total_clients') @Default(0) int totalClients,
    @JsonKey(name: 'active_partners') @Default(0) int activePartners,
  }) = _DashboardStats;

  factory DashboardStats.fromJson(Map<String, dynamic> json) =>
      _$DashboardStatsFromJson(json);
}
