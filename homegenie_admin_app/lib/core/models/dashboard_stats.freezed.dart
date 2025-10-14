// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

DashboardStats _$DashboardStatsFromJson(Map<String, dynamic> json) {
  return _DashboardStats.fromJson(json);
}

/// @nodoc
mixin _$DashboardStats {
  @JsonKey(name: 'active_bookings')
  int get activeBookings => throw _privateConstructorUsedError;
  @JsonKey(name: 'pending_verifications')
  int get pendingVerifications => throw _privateConstructorUsedError;
  @JsonKey(name: 'total_clients')
  int get totalClients => throw _privateConstructorUsedError;
  @JsonKey(name: 'active_partners')
  int get activePartners => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $DashboardStatsCopyWith<DashboardStats> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DashboardStatsCopyWith<$Res> {
  factory $DashboardStatsCopyWith(
          DashboardStats value, $Res Function(DashboardStats) then) =
      _$DashboardStatsCopyWithImpl<$Res, DashboardStats>;
  @useResult
  $Res call(
      {@JsonKey(name: 'active_bookings') int activeBookings,
      @JsonKey(name: 'pending_verifications') int pendingVerifications,
      @JsonKey(name: 'total_clients') int totalClients,
      @JsonKey(name: 'active_partners') int activePartners});
}

/// @nodoc
class _$DashboardStatsCopyWithImpl<$Res, $Val extends DashboardStats>
    implements $DashboardStatsCopyWith<$Res> {
  _$DashboardStatsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBookings = null,
    Object? pendingVerifications = null,
    Object? totalClients = null,
    Object? activePartners = null,
  }) {
    return _then(_value.copyWith(
      activeBookings: null == activeBookings
          ? _value.activeBookings
          : activeBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingVerifications: null == pendingVerifications
          ? _value.pendingVerifications
          : pendingVerifications // ignore: cast_nullable_to_non_nullable
              as int,
      totalClients: null == totalClients
          ? _value.totalClients
          : totalClients // ignore: cast_nullable_to_non_nullable
              as int,
      activePartners: null == activePartners
          ? _value.activePartners
          : activePartners // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$DashboardStatsImplCopyWith<$Res>
    implements $DashboardStatsCopyWith<$Res> {
  factory _$$DashboardStatsImplCopyWith(_$DashboardStatsImpl value,
          $Res Function(_$DashboardStatsImpl) then) =
      __$$DashboardStatsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'active_bookings') int activeBookings,
      @JsonKey(name: 'pending_verifications') int pendingVerifications,
      @JsonKey(name: 'total_clients') int totalClients,
      @JsonKey(name: 'active_partners') int activePartners});
}

/// @nodoc
class __$$DashboardStatsImplCopyWithImpl<$Res>
    extends _$DashboardStatsCopyWithImpl<$Res, _$DashboardStatsImpl>
    implements _$$DashboardStatsImplCopyWith<$Res> {
  __$$DashboardStatsImplCopyWithImpl(
      _$DashboardStatsImpl _value, $Res Function(_$DashboardStatsImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? activeBookings = null,
    Object? pendingVerifications = null,
    Object? totalClients = null,
    Object? activePartners = null,
  }) {
    return _then(_$DashboardStatsImpl(
      activeBookings: null == activeBookings
          ? _value.activeBookings
          : activeBookings // ignore: cast_nullable_to_non_nullable
              as int,
      pendingVerifications: null == pendingVerifications
          ? _value.pendingVerifications
          : pendingVerifications // ignore: cast_nullable_to_non_nullable
              as int,
      totalClients: null == totalClients
          ? _value.totalClients
          : totalClients // ignore: cast_nullable_to_non_nullable
              as int,
      activePartners: null == activePartners
          ? _value.activePartners
          : activePartners // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$DashboardStatsImpl implements _DashboardStats {
  const _$DashboardStatsImpl(
      {@JsonKey(name: 'active_bookings') this.activeBookings = 0,
      @JsonKey(name: 'pending_verifications') this.pendingVerifications = 0,
      @JsonKey(name: 'total_clients') this.totalClients = 0,
      @JsonKey(name: 'active_partners') this.activePartners = 0});

  factory _$DashboardStatsImpl.fromJson(Map<String, dynamic> json) =>
      _$$DashboardStatsImplFromJson(json);

  @override
  @JsonKey(name: 'active_bookings')
  final int activeBookings;
  @override
  @JsonKey(name: 'pending_verifications')
  final int pendingVerifications;
  @override
  @JsonKey(name: 'total_clients')
  final int totalClients;
  @override
  @JsonKey(name: 'active_partners')
  final int activePartners;

  @override
  String toString() {
    return 'DashboardStats(activeBookings: $activeBookings, pendingVerifications: $pendingVerifications, totalClients: $totalClients, activePartners: $activePartners)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DashboardStatsImpl &&
            (identical(other.activeBookings, activeBookings) ||
                other.activeBookings == activeBookings) &&
            (identical(other.pendingVerifications, pendingVerifications) ||
                other.pendingVerifications == pendingVerifications) &&
            (identical(other.totalClients, totalClients) ||
                other.totalClients == totalClients) &&
            (identical(other.activePartners, activePartners) ||
                other.activePartners == activePartners));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, activeBookings,
      pendingVerifications, totalClients, activePartners);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      __$$DashboardStatsImplCopyWithImpl<_$DashboardStatsImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DashboardStatsImplToJson(
      this,
    );
  }
}

abstract class _DashboardStats implements DashboardStats {
  const factory _DashboardStats(
      {@JsonKey(name: 'active_bookings') final int activeBookings,
      @JsonKey(name: 'pending_verifications') final int pendingVerifications,
      @JsonKey(name: 'total_clients') final int totalClients,
      @JsonKey(name: 'active_partners')
      final int activePartners}) = _$DashboardStatsImpl;

  factory _DashboardStats.fromJson(Map<String, dynamic> json) =
      _$DashboardStatsImpl.fromJson;

  @override
  @JsonKey(name: 'active_bookings')
  int get activeBookings;
  @override
  @JsonKey(name: 'pending_verifications')
  int get pendingVerifications;
  @override
  @JsonKey(name: 'total_clients')
  int get totalClients;
  @override
  @JsonKey(name: 'active_partners')
  int get activePartners;
  @override
  @JsonKey(ignore: true)
  _$$DashboardStatsImplCopyWith<_$DashboardStatsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
