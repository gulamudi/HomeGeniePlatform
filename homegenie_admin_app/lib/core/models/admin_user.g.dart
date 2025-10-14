// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdminUserImpl _$$AdminUserImplFromJson(Map<String, dynamic> json) =>
    _$AdminUserImpl(
      userId: json['userId'] as String,
      role: json['role'] as String,
      permissions: json['permissions'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fullName: json['fullName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$$AdminUserImplToJson(_$AdminUserImpl instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': instance.role,
      'permissions': instance.permissions,
      'createdAt': instance.createdAt.toIso8601String(),
      'fullName': instance.fullName,
      'phone': instance.phone,
      'email': instance.email,
    };
