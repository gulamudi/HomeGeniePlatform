// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'service.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Service _$ServiceFromJson(Map<String, dynamic> json) => Service(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      base_price: (json['basePrice'] as num).toDouble(),
      duration_hours: (json['durationHours'] as num).toDouble(),
      is_active: json['isActive'] as bool,
      requirements: (json['requirements'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      includes:
          (json['includes'] as List<dynamic>).map((e) => e as String).toList(),
      excludes:
          (json['excludes'] as List<dynamic>).map((e) => e as String).toList(),
      image_url: json['imageUrl'] as String?,
      created_at: DateTime.parse(json['createdAt'] as String),
      updated_at: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ServiceToJson(Service instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'category': instance.category,
      'basePrice': instance.base_price,
      'durationHours': instance.duration_hours,
      'isActive': instance.is_active,
      'requirements': instance.requirements,
      'includes': instance.includes,
      'excludes': instance.excludes,
      'imageUrl': instance.image_url,
      'createdAt': instance.created_at.toIso8601String(),
      'updatedAt': instance.updated_at.toIso8601String(),
    };
