// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'partner_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

PartnerAvailability _$PartnerAvailabilityFromJson(Map<String, dynamic> json) {
  return _PartnerAvailability.fromJson(json);
}

/// @nodoc
mixin _$PartnerAvailability {
  List<int> get weekdays => throw _privateConstructorUsedError;
  WorkingHours get workingHours => throw _privateConstructorUsedError;
  bool get isAvailable => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PartnerAvailabilityCopyWith<PartnerAvailability> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerAvailabilityCopyWith<$Res> {
  factory $PartnerAvailabilityCopyWith(
          PartnerAvailability value, $Res Function(PartnerAvailability) then) =
      _$PartnerAvailabilityCopyWithImpl<$Res, PartnerAvailability>;
  @useResult
  $Res call({List<int> weekdays, WorkingHours workingHours, bool isAvailable});

  $WorkingHoursCopyWith<$Res> get workingHours;
}

/// @nodoc
class _$PartnerAvailabilityCopyWithImpl<$Res, $Val extends PartnerAvailability>
    implements $PartnerAvailabilityCopyWith<$Res> {
  _$PartnerAvailabilityCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekdays = null,
    Object? workingHours = null,
    Object? isAvailable = null,
  }) {
    return _then(_value.copyWith(
      weekdays: null == weekdays
          ? _value.weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      workingHours: null == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as WorkingHours,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WorkingHoursCopyWith<$Res> get workingHours {
    return $WorkingHoursCopyWith<$Res>(_value.workingHours, (value) {
      return _then(_value.copyWith(workingHours: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PartnerAvailabilityImplCopyWith<$Res>
    implements $PartnerAvailabilityCopyWith<$Res> {
  factory _$$PartnerAvailabilityImplCopyWith(_$PartnerAvailabilityImpl value,
          $Res Function(_$PartnerAvailabilityImpl) then) =
      __$$PartnerAvailabilityImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<int> weekdays, WorkingHours workingHours, bool isAvailable});

  @override
  $WorkingHoursCopyWith<$Res> get workingHours;
}

/// @nodoc
class __$$PartnerAvailabilityImplCopyWithImpl<$Res>
    extends _$PartnerAvailabilityCopyWithImpl<$Res, _$PartnerAvailabilityImpl>
    implements _$$PartnerAvailabilityImplCopyWith<$Res> {
  __$$PartnerAvailabilityImplCopyWithImpl(_$PartnerAvailabilityImpl _value,
      $Res Function(_$PartnerAvailabilityImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? weekdays = null,
    Object? workingHours = null,
    Object? isAvailable = null,
  }) {
    return _then(_$PartnerAvailabilityImpl(
      weekdays: null == weekdays
          ? _value._weekdays
          : weekdays // ignore: cast_nullable_to_non_nullable
              as List<int>,
      workingHours: null == workingHours
          ? _value.workingHours
          : workingHours // ignore: cast_nullable_to_non_nullable
              as WorkingHours,
      isAvailable: null == isAvailable
          ? _value.isAvailable
          : isAvailable // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PartnerAvailabilityImpl implements _PartnerAvailability {
  const _$PartnerAvailabilityImpl(
      {final List<int> weekdays = const [1, 2, 3, 4, 5, 6],
      required this.workingHours,
      this.isAvailable = true})
      : _weekdays = weekdays;

  factory _$PartnerAvailabilityImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartnerAvailabilityImplFromJson(json);

  final List<int> _weekdays;
  @override
  @JsonKey()
  List<int> get weekdays {
    if (_weekdays is EqualUnmodifiableListView) return _weekdays;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weekdays);
  }

  @override
  final WorkingHours workingHours;
  @override
  @JsonKey()
  final bool isAvailable;

  @override
  String toString() {
    return 'PartnerAvailability(weekdays: $weekdays, workingHours: $workingHours, isAvailable: $isAvailable)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerAvailabilityImpl &&
            const DeepCollectionEquality().equals(other._weekdays, _weekdays) &&
            (identical(other.workingHours, workingHours) ||
                other.workingHours == workingHours) &&
            (identical(other.isAvailable, isAvailable) ||
                other.isAvailable == isAvailable));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_weekdays),
      workingHours,
      isAvailable);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerAvailabilityImplCopyWith<_$PartnerAvailabilityImpl> get copyWith =>
      __$$PartnerAvailabilityImplCopyWithImpl<_$PartnerAvailabilityImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartnerAvailabilityImplToJson(
      this,
    );
  }
}

abstract class _PartnerAvailability implements PartnerAvailability {
  const factory _PartnerAvailability(
      {final List<int> weekdays,
      required final WorkingHours workingHours,
      final bool isAvailable}) = _$PartnerAvailabilityImpl;

  factory _PartnerAvailability.fromJson(Map<String, dynamic> json) =
      _$PartnerAvailabilityImpl.fromJson;

  @override
  List<int> get weekdays;
  @override
  WorkingHours get workingHours;
  @override
  bool get isAvailable;
  @override
  @JsonKey(ignore: true)
  _$$PartnerAvailabilityImplCopyWith<_$PartnerAvailabilityImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

WorkingHours _$WorkingHoursFromJson(Map<String, dynamic> json) {
  return _WorkingHours.fromJson(json);
}

/// @nodoc
mixin _$WorkingHours {
  String get start => throw _privateConstructorUsedError;
  String get end => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $WorkingHoursCopyWith<WorkingHours> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkingHoursCopyWith<$Res> {
  factory $WorkingHoursCopyWith(
          WorkingHours value, $Res Function(WorkingHours) then) =
      _$WorkingHoursCopyWithImpl<$Res, WorkingHours>;
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class _$WorkingHoursCopyWithImpl<$Res, $Val extends WorkingHours>
    implements $WorkingHoursCopyWith<$Res> {
  _$WorkingHoursCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_value.copyWith(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$WorkingHoursImplCopyWith<$Res>
    implements $WorkingHoursCopyWith<$Res> {
  factory _$$WorkingHoursImplCopyWith(
          _$WorkingHoursImpl value, $Res Function(_$WorkingHoursImpl) then) =
      __$$WorkingHoursImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String start, String end});
}

/// @nodoc
class __$$WorkingHoursImplCopyWithImpl<$Res>
    extends _$WorkingHoursCopyWithImpl<$Res, _$WorkingHoursImpl>
    implements _$$WorkingHoursImplCopyWith<$Res> {
  __$$WorkingHoursImplCopyWithImpl(
      _$WorkingHoursImpl _value, $Res Function(_$WorkingHoursImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? start = null,
    Object? end = null,
  }) {
    return _then(_$WorkingHoursImpl(
      start: null == start
          ? _value.start
          : start // ignore: cast_nullable_to_non_nullable
              as String,
      end: null == end
          ? _value.end
          : end // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkingHoursImpl implements _WorkingHours {
  const _$WorkingHoursImpl({required this.start, required this.end});

  factory _$WorkingHoursImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkingHoursImplFromJson(json);

  @override
  final String start;
  @override
  final String end;

  @override
  String toString() {
    return 'WorkingHours(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkingHoursImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      __$$WorkingHoursImplCopyWithImpl<_$WorkingHoursImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkingHoursImplToJson(
      this,
    );
  }
}

abstract class _WorkingHours implements WorkingHours {
  const factory _WorkingHours(
      {required final String start,
      required final String end}) = _$WorkingHoursImpl;

  factory _WorkingHours.fromJson(Map<String, dynamic> json) =
      _$WorkingHoursImpl.fromJson;

  @override
  String get start;
  @override
  String get end;
  @override
  @JsonKey(ignore: true)
  _$$WorkingHoursImplCopyWith<_$WorkingHoursImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

JobPreferences _$JobPreferencesFromJson(Map<String, dynamic> json) {
  return _JobPreferences.fromJson(json);
}

/// @nodoc
mixin _$JobPreferences {
  double get maxDistance => throw _privateConstructorUsedError;
  List<String> get preferredAreas => throw _privateConstructorUsedError;
  List<String> get preferredServices => throw _privateConstructorUsedError;
  double get minJobValue => throw _privateConstructorUsedError;
  bool get autoAccept => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $JobPreferencesCopyWith<JobPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $JobPreferencesCopyWith<$Res> {
  factory $JobPreferencesCopyWith(
          JobPreferences value, $Res Function(JobPreferences) then) =
      _$JobPreferencesCopyWithImpl<$Res, JobPreferences>;
  @useResult
  $Res call(
      {double maxDistance,
      List<String> preferredAreas,
      List<String> preferredServices,
      double minJobValue,
      bool autoAccept});
}

/// @nodoc
class _$JobPreferencesCopyWithImpl<$Res, $Val extends JobPreferences>
    implements $JobPreferencesCopyWith<$Res> {
  _$JobPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxDistance = null,
    Object? preferredAreas = null,
    Object? preferredServices = null,
    Object? minJobValue = null,
    Object? autoAccept = null,
  }) {
    return _then(_value.copyWith(
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      preferredAreas: null == preferredAreas
          ? _value.preferredAreas
          : preferredAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredServices: null == preferredServices
          ? _value.preferredServices
          : preferredServices // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minJobValue: null == minJobValue
          ? _value.minJobValue
          : minJobValue // ignore: cast_nullable_to_non_nullable
              as double,
      autoAccept: null == autoAccept
          ? _value.autoAccept
          : autoAccept // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$JobPreferencesImplCopyWith<$Res>
    implements $JobPreferencesCopyWith<$Res> {
  factory _$$JobPreferencesImplCopyWith(_$JobPreferencesImpl value,
          $Res Function(_$JobPreferencesImpl) then) =
      __$$JobPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double maxDistance,
      List<String> preferredAreas,
      List<String> preferredServices,
      double minJobValue,
      bool autoAccept});
}

/// @nodoc
class __$$JobPreferencesImplCopyWithImpl<$Res>
    extends _$JobPreferencesCopyWithImpl<$Res, _$JobPreferencesImpl>
    implements _$$JobPreferencesImplCopyWith<$Res> {
  __$$JobPreferencesImplCopyWithImpl(
      _$JobPreferencesImpl _value, $Res Function(_$JobPreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? maxDistance = null,
    Object? preferredAreas = null,
    Object? preferredServices = null,
    Object? minJobValue = null,
    Object? autoAccept = null,
  }) {
    return _then(_$JobPreferencesImpl(
      maxDistance: null == maxDistance
          ? _value.maxDistance
          : maxDistance // ignore: cast_nullable_to_non_nullable
              as double,
      preferredAreas: null == preferredAreas
          ? _value._preferredAreas
          : preferredAreas // ignore: cast_nullable_to_non_nullable
              as List<String>,
      preferredServices: null == preferredServices
          ? _value._preferredServices
          : preferredServices // ignore: cast_nullable_to_non_nullable
              as List<String>,
      minJobValue: null == minJobValue
          ? _value.minJobValue
          : minJobValue // ignore: cast_nullable_to_non_nullable
              as double,
      autoAccept: null == autoAccept
          ? _value.autoAccept
          : autoAccept // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$JobPreferencesImpl implements _JobPreferences {
  const _$JobPreferencesImpl(
      {this.maxDistance = 10.0,
      final List<String> preferredAreas = const [],
      final List<String> preferredServices = const [],
      this.minJobValue = 0.0,
      this.autoAccept = false})
      : _preferredAreas = preferredAreas,
        _preferredServices = preferredServices;

  factory _$JobPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$JobPreferencesImplFromJson(json);

  @override
  @JsonKey()
  final double maxDistance;
  final List<String> _preferredAreas;
  @override
  @JsonKey()
  List<String> get preferredAreas {
    if (_preferredAreas is EqualUnmodifiableListView) return _preferredAreas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredAreas);
  }

  final List<String> _preferredServices;
  @override
  @JsonKey()
  List<String> get preferredServices {
    if (_preferredServices is EqualUnmodifiableListView)
      return _preferredServices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_preferredServices);
  }

  @override
  @JsonKey()
  final double minJobValue;
  @override
  @JsonKey()
  final bool autoAccept;

  @override
  String toString() {
    return 'JobPreferences(maxDistance: $maxDistance, preferredAreas: $preferredAreas, preferredServices: $preferredServices, minJobValue: $minJobValue, autoAccept: $autoAccept)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$JobPreferencesImpl &&
            (identical(other.maxDistance, maxDistance) ||
                other.maxDistance == maxDistance) &&
            const DeepCollectionEquality()
                .equals(other._preferredAreas, _preferredAreas) &&
            const DeepCollectionEquality()
                .equals(other._preferredServices, _preferredServices) &&
            (identical(other.minJobValue, minJobValue) ||
                other.minJobValue == minJobValue) &&
            (identical(other.autoAccept, autoAccept) ||
                other.autoAccept == autoAccept));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      maxDistance,
      const DeepCollectionEquality().hash(_preferredAreas),
      const DeepCollectionEquality().hash(_preferredServices),
      minJobValue,
      autoAccept);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$JobPreferencesImplCopyWith<_$JobPreferencesImpl> get copyWith =>
      __$$JobPreferencesImplCopyWithImpl<_$JobPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$JobPreferencesImplToJson(
      this,
    );
  }
}

abstract class _JobPreferences implements JobPreferences {
  const factory _JobPreferences(
      {final double maxDistance,
      final List<String> preferredAreas,
      final List<String> preferredServices,
      final double minJobValue,
      final bool autoAccept}) = _$JobPreferencesImpl;

  factory _JobPreferences.fromJson(Map<String, dynamic> json) =
      _$JobPreferencesImpl.fromJson;

  @override
  double get maxDistance;
  @override
  List<String> get preferredAreas;
  @override
  List<String> get preferredServices;
  @override
  double get minJobValue;
  @override
  bool get autoAccept;
  @override
  @JsonKey(ignore: true)
  _$$JobPreferencesImplCopyWith<_$JobPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

PartnerPreferences _$PartnerPreferencesFromJson(Map<String, dynamic> json) {
  return _PartnerPreferences.fromJson(json);
}

/// @nodoc
mixin _$PartnerPreferences {
  List<String> get services => throw _privateConstructorUsedError;
  PartnerAvailability? get availability => throw _privateConstructorUsedError;
  JobPreferences? get jobPreferences => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PartnerPreferencesCopyWith<PartnerPreferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PartnerPreferencesCopyWith<$Res> {
  factory $PartnerPreferencesCopyWith(
          PartnerPreferences value, $Res Function(PartnerPreferences) then) =
      _$PartnerPreferencesCopyWithImpl<$Res, PartnerPreferences>;
  @useResult
  $Res call(
      {List<String> services,
      PartnerAvailability? availability,
      JobPreferences? jobPreferences});

  $PartnerAvailabilityCopyWith<$Res>? get availability;
  $JobPreferencesCopyWith<$Res>? get jobPreferences;
}

/// @nodoc
class _$PartnerPreferencesCopyWithImpl<$Res, $Val extends PartnerPreferences>
    implements $PartnerPreferencesCopyWith<$Res> {
  _$PartnerPreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? services = null,
    Object? availability = freezed,
    Object? jobPreferences = freezed,
  }) {
    return _then(_value.copyWith(
      services: null == services
          ? _value.services
          : services // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availability: freezed == availability
          ? _value.availability
          : availability // ignore: cast_nullable_to_non_nullable
              as PartnerAvailability?,
      jobPreferences: freezed == jobPreferences
          ? _value.jobPreferences
          : jobPreferences // ignore: cast_nullable_to_non_nullable
              as JobPreferences?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $PartnerAvailabilityCopyWith<$Res>? get availability {
    if (_value.availability == null) {
      return null;
    }

    return $PartnerAvailabilityCopyWith<$Res>(_value.availability!, (value) {
      return _then(_value.copyWith(availability: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $JobPreferencesCopyWith<$Res>? get jobPreferences {
    if (_value.jobPreferences == null) {
      return null;
    }

    return $JobPreferencesCopyWith<$Res>(_value.jobPreferences!, (value) {
      return _then(_value.copyWith(jobPreferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$PartnerPreferencesImplCopyWith<$Res>
    implements $PartnerPreferencesCopyWith<$Res> {
  factory _$$PartnerPreferencesImplCopyWith(_$PartnerPreferencesImpl value,
          $Res Function(_$PartnerPreferencesImpl) then) =
      __$$PartnerPreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> services,
      PartnerAvailability? availability,
      JobPreferences? jobPreferences});

  @override
  $PartnerAvailabilityCopyWith<$Res>? get availability;
  @override
  $JobPreferencesCopyWith<$Res>? get jobPreferences;
}

/// @nodoc
class __$$PartnerPreferencesImplCopyWithImpl<$Res>
    extends _$PartnerPreferencesCopyWithImpl<$Res, _$PartnerPreferencesImpl>
    implements _$$PartnerPreferencesImplCopyWith<$Res> {
  __$$PartnerPreferencesImplCopyWithImpl(_$PartnerPreferencesImpl _value,
      $Res Function(_$PartnerPreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? services = null,
    Object? availability = freezed,
    Object? jobPreferences = freezed,
  }) {
    return _then(_$PartnerPreferencesImpl(
      services: null == services
          ? _value._services
          : services // ignore: cast_nullable_to_non_nullable
              as List<String>,
      availability: freezed == availability
          ? _value.availability
          : availability // ignore: cast_nullable_to_non_nullable
              as PartnerAvailability?,
      jobPreferences: freezed == jobPreferences
          ? _value.jobPreferences
          : jobPreferences // ignore: cast_nullable_to_non_nullable
              as JobPreferences?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PartnerPreferencesImpl implements _PartnerPreferences {
  const _$PartnerPreferencesImpl(
      {final List<String> services = const [],
      this.availability,
      this.jobPreferences})
      : _services = services;

  factory _$PartnerPreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PartnerPreferencesImplFromJson(json);

  final List<String> _services;
  @override
  @JsonKey()
  List<String> get services {
    if (_services is EqualUnmodifiableListView) return _services;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_services);
  }

  @override
  final PartnerAvailability? availability;
  @override
  final JobPreferences? jobPreferences;

  @override
  String toString() {
    return 'PartnerPreferences(services: $services, availability: $availability, jobPreferences: $jobPreferences)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PartnerPreferencesImpl &&
            const DeepCollectionEquality().equals(other._services, _services) &&
            (identical(other.availability, availability) ||
                other.availability == availability) &&
            (identical(other.jobPreferences, jobPreferences) ||
                other.jobPreferences == jobPreferences));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_services),
      availability,
      jobPreferences);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PartnerPreferencesImplCopyWith<_$PartnerPreferencesImpl> get copyWith =>
      __$$PartnerPreferencesImplCopyWithImpl<_$PartnerPreferencesImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PartnerPreferencesImplToJson(
      this,
    );
  }
}

abstract class _PartnerPreferences implements PartnerPreferences {
  const factory _PartnerPreferences(
      {final List<String> services,
      final PartnerAvailability? availability,
      final JobPreferences? jobPreferences}) = _$PartnerPreferencesImpl;

  factory _PartnerPreferences.fromJson(Map<String, dynamic> json) =
      _$PartnerPreferencesImpl.fromJson;

  @override
  List<String> get services;
  @override
  PartnerAvailability? get availability;
  @override
  JobPreferences? get jobPreferences;
  @override
  @JsonKey(ignore: true)
  _$$PartnerPreferencesImplCopyWith<_$PartnerPreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
