// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: json['id'] as String,
      partnerId: json['partner_id'] as String,
      documentType: json['document_type'] as String,
      documentNumber: json['document_number'] as String,
      frontImageUrl: json['front_image_url'] as String?,
      backImageUrl: json['back_image_url'] as String?,
      verificationStatus: json['verification_status'] as String,
      rejectionReason: json['rejection_reason'] as String?,
      uploadedAt: DateTime.parse(json['uploaded_at'] as String),
      verifiedAt: json['verified_at'] == null
          ? null
          : DateTime.parse(json['verified_at'] as String),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'partner_id': instance.partnerId,
      'document_type': instance.documentType,
      'document_number': instance.documentNumber,
      'front_image_url': instance.frontImageUrl,
      'back_image_url': instance.backImageUrl,
      'verification_status': instance.verificationStatus,
      'rejection_reason': instance.rejectionReason,
      'uploaded_at': instance.uploadedAt.toIso8601String(),
      'verified_at': instance.verifiedAt?.toIso8601String(),
    };
