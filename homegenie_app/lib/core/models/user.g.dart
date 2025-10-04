// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['id'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String,
      full_name: json['fullName'] as String,
      avatar_url: json['avatarUrl'] as String?,
      user_type: json['userType'] as String,
      created_at: DateTime.parse(json['createdAt'] as String),
      updated_at: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'phone': instance.phone,
      'fullName': instance.full_name,
      'avatarUrl': instance.avatar_url,
      'userType': instance.user_type,
      'createdAt': instance.created_at.toIso8601String(),
      'updatedAt': instance.updated_at.toIso8601String(),
    };
