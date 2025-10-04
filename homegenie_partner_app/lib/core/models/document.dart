import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

@JsonSerializable()
class Document {
  final String id;
  final String partnerId;
  final String documentType; // 'aadhar', 'pan', 'police_verification'
  final String documentNumber;
  final String? frontImageUrl;
  final String? backImageUrl;
  final String verificationStatus; // 'pending', 'approved', 'rejected'
  final String? rejectionReason;
  final DateTime uploadedAt;
  final DateTime? verifiedAt;

  Document({
    required this.id,
    required this.partnerId,
    required this.documentType,
    required this.documentNumber,
    this.frontImageUrl,
    this.backImageUrl,
    required this.verificationStatus,
    this.rejectionReason,
    required this.uploadedAt,
    this.verifiedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  Document copyWith({
    String? id,
    String? partnerId,
    String? documentType,
    String? documentNumber,
    String? frontImageUrl,
    String? backImageUrl,
    String? verificationStatus,
    String? rejectionReason,
    DateTime? uploadedAt,
    DateTime? verifiedAt,
  }) {
    return Document(
      id: id ?? this.id,
      partnerId: partnerId ?? this.partnerId,
      documentType: documentType ?? this.documentType,
      documentNumber: documentNumber ?? this.documentNumber,
      frontImageUrl: frontImageUrl ?? this.frontImageUrl,
      backImageUrl: backImageUrl ?? this.backImageUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
    );
  }
}
