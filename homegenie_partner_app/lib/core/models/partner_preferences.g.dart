// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$PartnerAvailabilityImpl _$$PartnerAvailabilityImplFromJson(
        Map<String, dynamic> json) =>
    _$PartnerAvailabilityImpl(
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6],
      workingHours:
          WorkingHours.fromJson(json['workingHours'] as Map<String, dynamic>),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$PartnerAvailabilityImplToJson(
        _$PartnerAvailabilityImpl instance) =>
    <String, dynamic>{
      'weekdays': instance.weekdays,
      'workingHours': instance.workingHours,
      'isAvailable': instance.isAvailable,
    };

_$WorkingHoursImpl _$$WorkingHoursImplFromJson(Map<String, dynamic> json) =>
    _$WorkingHoursImpl(
      start: json['start'] as String,
      end: json['end'] as String,
    );

Map<String, dynamic> _$$WorkingHoursImplToJson(_$WorkingHoursImpl instance) =>
    <String, dynamic>{
      'start': instance.start,
      'end': instance.end,
    };

_$JobPreferencesImpl _$$JobPreferencesImplFromJson(Map<String, dynamic> json) =>
    _$JobPreferencesImpl(
      maxDistance: (json['maxDistance'] as num?)?.toDouble() ?? 10.0,
      preferredAreas: (json['preferredAreas'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredServices: (json['preferredServices'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      minJobValue: (json['minJobValue'] as num?)?.toDouble() ?? 0.0,
      autoAccept: json['autoAccept'] as bool? ?? false,
    );

Map<String, dynamic> _$$JobPreferencesImplToJson(
        _$JobPreferencesImpl instance) =>
    <String, dynamic>{
      'maxDistance': instance.maxDistance,
      'preferredAreas': instance.preferredAreas,
      'preferredServices': instance.preferredServices,
      'minJobValue': instance.minJobValue,
      'autoAccept': instance.autoAccept,
    };

_$PartnerPreferencesImpl _$$PartnerPreferencesImplFromJson(
        Map<String, dynamic> json) =>
    _$PartnerPreferencesImpl(
      services: (json['services'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      availability: json['availability'] == null
          ? null
          : PartnerAvailability.fromJson(
              json['availability'] as Map<String, dynamic>),
      jobPreferences: json['jobPreferences'] == null
          ? null
          : JobPreferences.fromJson(
              json['jobPreferences'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$PartnerPreferencesImplToJson(
        _$PartnerPreferencesImpl instance) =>
    <String, dynamic>{
      'services': instance.services,
      'availability': instance.availability,
      'jobPreferences': instance.jobPreferences,
    };
