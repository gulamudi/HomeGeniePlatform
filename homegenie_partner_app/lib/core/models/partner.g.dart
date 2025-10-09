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
      profilePhoto: json['profilePhoto'] as String?,
      verificationStatus: json['verificationStatus'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
      rating: (json['rating'] as num?)?.toDouble(),
      totalJobs: (json['totalJobs'] as num?)?.toInt(),
      serviceTypes: (json['serviceTypes'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredLocations: (json['preferredLocations'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      availability: json['availability'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$PartnerToJson(Partner instance) => <String, dynamic>{
      'id': instance.id,
      'phone': instance.phone,
      'name': instance.name,
      'email': instance.email,
      'profilePhoto': instance.profilePhoto,
      'verificationStatus': instance.verificationStatus,
      'isAvailable': instance.isAvailable,
      'rating': instance.rating,
      'totalJobs': instance.totalJobs,
      'serviceTypes': instance.serviceTypes,
      'preferredLocations': instance.preferredLocations,
      'availability': instance.availability,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
