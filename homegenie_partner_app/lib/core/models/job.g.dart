// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Job _$JobFromJson(Map<String, dynamic> json) => Job(
      id: json['id'] as String,
      bookingId: json['booking_id'] as String,
      serviceType: json['service_type'] as String,
      serviceName: json['service_name'] as String,
      status: json['status'] as String,
      scheduledDate: DateTime.parse(json['scheduled_date'] as String),
      scheduledTime: json['scheduled_time'] as String?,
      amount: (json['amount'] as num).toDouble(),
      partnerEarning: (json['partner_earning'] as num?)?.toDouble(),
      customerId: json['customer_id'] as String,
      customerName: json['customer_name'] as String,
      customerPhone: json['customer_phone'] as String?,
      customerPhoto: json['customer_photo'] as String?,
      address: json['address'] as String,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      instructions: json['instructions'] as String?,
      acceptedAt: json['accepted_at'] == null
          ? null
          : DateTime.parse(json['accepted_at'] as String),
      startedAt: json['started_at'] == null
          ? null
          : DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] == null
          ? null
          : DateTime.parse(json['completed_at'] as String),
      cancelledAt: json['cancelled_at'] == null
          ? null
          : DateTime.parse(json['cancelled_at'] as String),
      cancelReason: json['cancel_reason'] as String?,
      rating: json['rating'] as int?,
      review: json['review'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$JobToJson(Job instance) => <String, dynamic>{
      'id': instance.id,
      'booking_id': instance.bookingId,
      'service_type': instance.serviceType,
      'service_name': instance.serviceName,
      'status': instance.status,
      'scheduled_date': instance.scheduledDate.toIso8601String(),
      'scheduled_time': instance.scheduledTime,
      'amount': instance.amount,
      'partner_earning': instance.partnerEarning,
      'customer_id': instance.customerId,
      'customer_name': instance.customerName,
      'customer_phone': instance.customerPhone,
      'customer_photo': instance.customerPhoto,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'instructions': instance.instructions,
      'accepted_at': instance.acceptedAt?.toIso8601String(),
      'started_at': instance.startedAt?.toIso8601String(),
      'completed_at': instance.completedAt?.toIso8601String(),
      'cancelled_at': instance.cancelledAt?.toIso8601String(),
      'cancel_reason': instance.cancelReason,
      'rating': instance.rating,
      'review': instance.review,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt?.toIso8601String(),
    };
