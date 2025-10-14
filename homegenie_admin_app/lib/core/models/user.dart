import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'email')
  final String? email;

  @JsonKey(name: 'phone')
  final String phone;

  @JsonKey(name: 'fullName')
  final String full_name;

  @JsonKey(name: 'avatarUrl')
  final String? avatar_url;

  @JsonKey(name: 'userType')
  final String user_type;

  @JsonKey(name: 'createdAt')
  final DateTime created_at;

  @JsonKey(name: 'updatedAt')
  final DateTime updated_at;

  const User({
    required this.id,
    this.email,
    required this.phone,
    required this.full_name,
    this.avatar_url,
    required this.user_type,
    required this.created_at,
    required this.updated_at,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
