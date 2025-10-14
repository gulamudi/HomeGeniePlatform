// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DashboardStatsImpl _$$DashboardStatsImplFromJson(Map<String, dynamic> json) =>
    _$DashboardStatsImpl(
      activeBookings: (json['active_bookings'] as num?)?.toInt() ?? 0,
      pendingVerifications:
          (json['pending_verifications'] as num?)?.toInt() ?? 0,
      totalClients: (json['total_clients'] as num?)?.toInt() ?? 0,
      activePartners: (json['active_partners'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$DashboardStatsImplToJson(
        _$DashboardStatsImpl instance) =>
    <String, dynamic>{
      'active_bookings': instance.activeBookings,
      'pending_verifications': instance.pendingVerifications,
      'total_clients': instance.totalClients,
      'active_partners': instance.activePartners,
    };
