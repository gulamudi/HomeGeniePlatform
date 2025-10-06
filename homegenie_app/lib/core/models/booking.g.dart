// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'booking.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Booking _$BookingFromJson(Map<String, dynamic> json) => Booking(
      id: json['id'] as String,
      customer_id: json['customerId'] as String,
      partner_id: json['partnerId'] as String?,
      service_id: json['serviceId'] as String,
      status: json['status'] as String,
      scheduled_date: DateTime.parse(json['scheduledDate'] as String),
      duration_hours: (json['durationHours'] as num).toDouble(),
      address: json['address'],
      total_amount: (json['totalAmount'] as num).toDouble(),
      payment_method: json['paymentMethod'] as String,
      payment_status: json['paymentStatus'] as String,
      special_instructions: json['specialInstructions'] as String?,
      preferred_partner_id: json['preferredPartnerId'] as String?,
      created_at: DateTime.parse(json['createdAt'] as String),
      updated_at: DateTime.parse(json['updatedAt'] as String),
      partner: json['partner'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$BookingToJson(Booking instance) => <String, dynamic>{
      'id': instance.id,
      'customerId': instance.customer_id,
      'partnerId': instance.partner_id,
      'serviceId': instance.service_id,
      'status': instance.status,
      'scheduledDate': instance.scheduled_date.toIso8601String(),
      'durationHours': instance.duration_hours,
      'address': instance.address,
      'totalAmount': instance.total_amount,
      'paymentMethod': instance.payment_method,
      'paymentStatus': instance.payment_status,
      'specialInstructions': instance.special_instructions,
      'preferredPartnerId': instance.preferred_partner_id,
      'createdAt': instance.created_at.toIso8601String(),
      'updatedAt': instance.updated_at.toIso8601String(),
      'partner': instance.partner,
    };
