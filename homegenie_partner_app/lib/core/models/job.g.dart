// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String,
      bookingId: json['bookingId'] as String,
      serviceType: json['serviceType'] as String,
      serviceName: json['serviceName'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime: json['scheduledTime'] as String?,
      amount: (json['amount'] as num).toDouble(),
      partnerEarning: (json['partnerEarning'] as num?)?.toDouble(),
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerPhone: json['customerPhone'] as String?,
      customerPhoto: json['customerPhoto'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      instructions: json['instructions'] as String?,
      acceptedAt: json['acceptedAt'] == null
          ? null
          : DateTime.parse(json['acceptedAt'] as String),
      startedAt: json['startedAt'] == null
          ? null
          : DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      cancelledAt: json['cancelledAt'] == null
          ? null
          : DateTime.parse(json['cancelledAt'] as String),
      cancelReason: json['cancelReason'] as String?,
      rating: (json['rating'] as num?)?.toInt(),
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'bookingId': instance.bookingId,
      'serviceType': instance.serviceType,
      'serviceName': instance.serviceName,
      'status': instance.status,
      'scheduledDate': instance.scheduledDate.toIso8601String(),
      'scheduledTime': instance.scheduledTime,
      'amount': instance.amount,
      'partnerEarning': instance.partnerEarning,
      'customerId': instance.customerId,
      'customerName': instance.customerName,
      'customerPhone': instance.customerPhone,
      'customerPhoto': instance.customerPhoto,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instructions': instance.instructions,
      'acceptedAt': instance.acceptedAt?.toIso8601String(),
      'startedAt': instance.startedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'cancelledAt': instance.cancelledAt?.toIso8601String(),
      'cancelReason': instance.cancelReason,
      'rating': instance.rating,
      'review': instance.review,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
