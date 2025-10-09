// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: json['id'] as String,
      partnerId: json['partnerId'] as String,
      documentType: json['documentType'] as String,
      documentNumber: json['documentNumber'] as String,
      frontImageUrl: json['frontImageUrl'] as String?,
      backImageUrl: json['backImageUrl'] as String?,
      verificationStatus: json['verificationStatus'] as String,
      rejectionReason: json['rejectionReason'] as String?,
      uploadedAt: DateTime.parse(json['uploadedAt'] as String),
      verifiedAt: json['verifiedAt'] == null
          ? null
          : DateTime.parse(json['verifiedAt'] as String),
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'partnerId': instance.partnerId,
      'documentType': instance.documentType,
      'documentNumber': instance.documentNumber,
      'frontImageUrl': instance.frontImageUrl,
      'backImageUrl': instance.backImageUrl,
      'verificationStatus': instance.verificationStatus,
      'rejectionReason': instance.rejectionReason,
      'uploadedAt': instance.uploadedAt.toIso8601String(),
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
    };
