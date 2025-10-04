// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Partner _$PartnerFromJson(Map<String, dynamic> json) => Partner(
      id: json['id'] as String,
      phone: json['phone'] as String,
      name: json['name'] as String?,
      email: json['email'] as String?,
      profilePhoto: json['profile_photo'] as String?,
      verificationStatus: json['verification_status'] as String,
      isAvailable: json['is_available'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble(),
      totalJobs: json['total_jobs'] as int?,
      serviceTypes: (json['service_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredLocations: (json['preferred_locations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      availability: json['availability'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$PartnerToJson(Partner instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'profile_photo': instance.profilePhoto,
      'verification_status': instance.verificationStatus,
      'is_available': instance.isAvailable,
      'rating': instance.rating,
      'total_jobs': instance.totalJobs,
      'service_types': instance.serviceTypes,
      'preferred_locations': instance.preferredLocations,
      'availability': instance.availability,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
