// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartnerImpl _$$PartnerImplFromJson(Map<String, dynamic> json) =>
    _$PartnerImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      rating: (json['rating'] as num).toDouble(),
      totalJobs: (json['totalJobs'] as num).toInt(),
      lastServiceDate: json['lastServiceDate'] as String?,
      servicesCount: (json['servicesCount'] as num?)?.toInt(),
      lastServiceName: json['lastServiceName'] as String?,
      workedWithYou: json['workedWithYou'] as bool? ?? false,
    );

Map<String, dynamic> _$$PartnerImplToJson(_$PartnerImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'phone': instance.phone,
      'avatarUrl': instance.avatarUrl,
      'rating': instance.rating,
      'totalJobs': instance.totalJobs,
      'lastServiceDate': instance.lastServiceDate,
      'servicesCount': instance.servicesCount,
      'lastServiceName': instance.lastServiceName,
      'workedWithYou': instance.workedWithYou,
    };
