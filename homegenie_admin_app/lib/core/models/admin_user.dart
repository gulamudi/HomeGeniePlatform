import 'package:freezed_annotation/freezed_annotation.dart';

part 'admin_user.freezed.dart';
part 'admin_user.g.dart';

@freezed
class AdminUser with _$AdminUser {
  const factory AdminUser({
    required String userId,
    required String role,
    required Map<String, dynamic> permissions,
    required DateTime createdAt,
    String? fullName,
    String? phone,
    String? email,
  }) = _AdminUser;

  factory AdminUser.fromJson(Map<String, dynamic> json) =>
      _$AdminUserFromJson(json);
}
