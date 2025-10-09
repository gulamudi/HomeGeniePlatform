// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'service_area.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ServiceArea _$ServiceAreaFromJson(Map<String, dynamic> json) {
  return _ServiceArea.fromJson(json);
}

/// @nodoc
mixin _$ServiceArea {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get city => throw _privateConstructorUsedError;
  String get state => throw _privateConstructorUsedError;
  double get radiusKm => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  int get displayOrder => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ServiceAreaCopyWith<ServiceArea> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceAreaCopyWith<$Res> {
  factory $ServiceAreaCopyWith(
          ServiceArea value, $Res Function(ServiceArea) then) =
      _$ServiceAreaCopyWithImpl<$Res, ServiceArea>;
  @useResult
  $Res call(
      {String id,
      String name,
      String city,
      String state,
      double radiusKm,
      bool isActive,
      int displayOrder});
}

/// @nodoc
class _$ServiceAreaCopyWithImpl<$Res, $Val extends ServiceArea>
    implements $ServiceAreaCopyWith<$Res> {
  _$ServiceAreaCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? state = null,
    Object? radiusKm = null,
    Object? isActive = null,
    Object? displayOrder = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      radiusKm: null == radiusKm
          ? _value.radiusKm
          : radiusKm // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceAreaImplCopyWith<$Res>
    implements $ServiceAreaCopyWith<$Res> {
  factory _$$ServiceAreaImplCopyWith(
          _$ServiceAreaImpl value, $Res Function(_$ServiceAreaImpl) then) =
      __$$ServiceAreaImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String city,
      String state,
      double radiusKm,
      bool isActive,
      int displayOrder});
}

/// @nodoc
class __$$ServiceAreaImplCopyWithImpl<$Res>
    extends _$ServiceAreaCopyWithImpl<$Res, _$ServiceAreaImpl>
    implements _$$ServiceAreaImplCopyWith<$Res> {
  __$$ServiceAreaImplCopyWithImpl(
      _$ServiceAreaImpl _value, $Res Function(_$ServiceAreaImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? city = null,
    Object? state = null,
    Object? radiusKm = null,
    Object? isActive = null,
    Object? displayOrder = null,
  }) {
    return _then(_$ServiceAreaImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      city: null == city
          ? _value.city
          : city // ignore: cast_nullable_to_non_nullable
              as String,
      state: null == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String,
      radiusKm: null == radiusKm
          ? _value.radiusKm
          : radiusKm // ignore: cast_nullable_to_non_nullable
              as double,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      displayOrder: null == displayOrder
          ? _value.displayOrder
          : displayOrder // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ServiceAreaImpl implements _ServiceArea {
  const _$ServiceAreaImpl(
      {required this.id,
      required this.name,
      required this.city,
      required this.state,
      required this.radiusKm,
      this.isActive = true,
      this.displayOrder = 0});

  factory _$ServiceAreaImpl.fromJson(Map<String, dynamic> json) =>
      _$$ServiceAreaImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String city;
  @override
  final String state;
  @override
  final double radiusKm;
  @override
  @JsonKey()
  final bool isActive;
  @override
  @JsonKey()
  final int displayOrder;

  @override
  String toString() {
    return 'ServiceArea(id: $id, name: $name, city: $city, state: $state, radiusKm: $radiusKm, isActive: $isActive, displayOrder: $displayOrder)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceAreaImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.city, city) || other.city == city) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.radiusKm, radiusKm) ||
                other.radiusKm == radiusKm) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.displayOrder, displayOrder) ||
                other.displayOrder == displayOrder));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, name, city, state, radiusKm, isActive, displayOrder);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceAreaImplCopyWith<_$ServiceAreaImpl> get copyWith =>
      __$$ServiceAreaImplCopyWithImpl<_$ServiceAreaImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ServiceAreaImplToJson(
      this,
    );
  }
}

abstract class _ServiceArea implements ServiceArea {
  const factory _ServiceArea(
      {required final String id,
      required final String name,
      required final String city,
      required final String state,
      required final double radiusKm,
      final bool isActive,
      final int displayOrder}) = _$ServiceAreaImpl;

  factory _ServiceArea.fromJson(Map<String, dynamic> json) =
      _$ServiceAreaImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get city;
  @override
  String get state;
  @override
  double get radiusKm;
  @override
  bool get isActive;
  @override
  int get displayOrder;
  @override
  @JsonKey(ignore: true)
  _$$ServiceAreaImplCopyWith<_$ServiceAreaImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$ServiceAreasResponse {
  List<ServiceArea> get areas => throw _privateConstructorUsedError;
  Map<String, List<ServiceArea>> get groupedByCity =>
      throw _privateConstructorUsedError;
  int get count => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ServiceAreasResponseCopyWith<ServiceAreasResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ServiceAreasResponseCopyWith<$Res> {
  factory $ServiceAreasResponseCopyWith(ServiceAreasResponse value,
          $Res Function(ServiceAreasResponse) then) =
      _$ServiceAreasResponseCopyWithImpl<$Res, ServiceAreasResponse>;
  @useResult
  $Res call(
      {List<ServiceArea> areas,
      Map<String, List<ServiceArea>> groupedByCity,
      int count});
}

/// @nodoc
class _$ServiceAreasResponseCopyWithImpl<$Res,
        $Val extends ServiceAreasResponse>
    implements $ServiceAreasResponseCopyWith<$Res> {
  _$ServiceAreasResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areas = null,
    Object? groupedByCity = null,
    Object? count = null,
  }) {
    return _then(_value.copyWith(
      areas: null == areas
          ? _value.areas
          : areas // ignore: cast_nullable_to_non_nullable
              as List<ServiceArea>,
      groupedByCity: null == groupedByCity
          ? _value.groupedByCity
          : groupedByCity // ignore: cast_nullable_to_non_nullable
              as Map<String, List<ServiceArea>>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ServiceAreasResponseImplCopyWith<$Res>
    implements $ServiceAreasResponseCopyWith<$Res> {
  factory _$$ServiceAreasResponseImplCopyWith(_$ServiceAreasResponseImpl value,
          $Res Function(_$ServiceAreasResponseImpl) then) =
      __$$ServiceAreasResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<ServiceArea> areas,
      Map<String, List<ServiceArea>> groupedByCity,
      int count});
}

/// @nodoc
class __$$ServiceAreasResponseImplCopyWithImpl<$Res>
    extends _$ServiceAreasResponseCopyWithImpl<$Res, _$ServiceAreasResponseImpl>
    implements _$$ServiceAreasResponseImplCopyWith<$Res> {
  __$$ServiceAreasResponseImplCopyWithImpl(_$ServiceAreasResponseImpl _value,
      $Res Function(_$ServiceAreasResponseImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? areas = null,
    Object? groupedByCity = null,
    Object? count = null,
  }) {
    return _then(_$ServiceAreasResponseImpl(
      areas: null == areas
          ? _value._areas
          : areas // ignore: cast_nullable_to_non_nullable
              as List<ServiceArea>,
      groupedByCity: null == groupedByCity
          ? _value._groupedByCity
          : groupedByCity // ignore: cast_nullable_to_non_nullable
              as Map<String, List<ServiceArea>>,
      count: null == count
          ? _value.count
          : count // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ServiceAreasResponseImpl implements _ServiceAreasResponse {
  const _$ServiceAreasResponseImpl(
      {required final List<ServiceArea> areas,
      required final Map<String, List<ServiceArea>> groupedByCity,
      required this.count})
      : _areas = areas,
        _groupedByCity = groupedByCity;

  final List<ServiceArea> _areas;
  @override
  List<ServiceArea> get areas {
    if (_areas is EqualUnmodifiableListView) return _areas;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_areas);
  }

  final Map<String, List<ServiceArea>> _groupedByCity;
  @override
  Map<String, List<ServiceArea>> get groupedByCity {
    if (_groupedByCity is EqualUnmodifiableMapView) return _groupedByCity;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_groupedByCity);
  }

  @override
  final int count;

  @override
  String toString() {
    return 'ServiceAreasResponse(areas: $areas, groupedByCity: $groupedByCity, count: $count)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ServiceAreasResponseImpl &&
            const DeepCollectionEquality().equals(other._areas, _areas) &&
            const DeepCollectionEquality()
                .equals(other._groupedByCity, _groupedByCity) &&
            (identical(other.count, count) || other.count == count));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_areas),
      const DeepCollectionEquality().hash(_groupedByCity),
      count);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ServiceAreasResponseImplCopyWith<_$ServiceAreasResponseImpl>
      get copyWith =>
          __$$ServiceAreasResponseImplCopyWithImpl<_$ServiceAreasResponseImpl>(
              this, _$identity);
}

abstract class _ServiceAreasResponse implements ServiceAreasResponse {
  const factory _ServiceAreasResponse(
      {required final List<ServiceArea> areas,
      required final Map<String, List<ServiceArea>> groupedByCity,
      required final int count}) = _$ServiceAreasResponseImpl;

  @override
  List<ServiceArea> get areas;
  @override
  Map<String, List<ServiceArea>> get groupedByCity;
  @override
  int get count;
  @override
  @JsonKey(ignore: true)
  _$$ServiceAreasResponseImplCopyWith<_$ServiceAreasResponseImpl>
      get copyWith => throw _privateConstructorUsedError;
}
