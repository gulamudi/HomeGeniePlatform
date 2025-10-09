import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner.g.dart';
part 'partner.freezed.dart';

@freezed
class Partner with _$Partner {
  const factory Partner({
    required String id,
    required String name,
    String? phone,
    String? avatarUrl,
    required double rating,
    required int totalJobs,
    String? lastServiceDate,
    int? servicesCount,
    String? lastServiceName,
    @Default(false) bool workedWithYou,
  }) = _Partner;

  factory Partner.fromJson(Map<String, dynamic> json) => _$PartnerFromJson(json);
}
