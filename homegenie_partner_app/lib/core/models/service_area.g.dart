// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service_area.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ServiceAreaImpl _$$ServiceAreaImplFromJson(Map<String, dynamic> json) =>
    _$ServiceAreaImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      radiusKm: (json['radiusKm'] as num).toDouble(),
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: (json['displayOrder'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$ServiceAreaImplToJson(_$ServiceAreaImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'city': instance.city,
      'state': instance.state,
      'radiusKm': instance.radiusKm,
      'isActive': instance.isActive,
      'displayOrder': instance.displayOrder,
    };
