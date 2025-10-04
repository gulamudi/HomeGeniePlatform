import 'package:json_annotation/json_annotation.dart';

part 'booking.g.dart';

@JsonSerializable()
class Booking {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'customerId')
  final String customer_id;

  @JsonKey(name: 'partnerId')
  final String? partner_id;

  @JsonKey(name: 'serviceId')
  final String service_id;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'scheduledDate')
  final DateTime scheduled_date;

  @JsonKey(name: 'durationHours')
  final double duration_hours;

  @JsonKey(name: 'address')
  final dynamic address;

  @JsonKey(name: 'totalAmount')
  final double total_amount;

  @JsonKey(name: 'paymentMethod')
  final String payment_method;

  @JsonKey(name: 'paymentStatus')
  final String payment_status;

  @JsonKey(name: 'specialInstructions')
  final String? special_instructions;

  @JsonKey(name: 'preferredPartnerId')
  final String? preferred_partner_id;

  @JsonKey(name: 'createdAt')
  final DateTime created_at;

  @JsonKey(name: 'updatedAt')
  final DateTime updated_at;

  const Booking({
    required this.id,
    required this.customer_id,
    this.partner_id,
    required this.service_id,
    required this.status,
    required this.scheduled_date,
    required this.duration_hours,
    required this.address,
    required this.total_amount,
    required this.payment_method,
    required this.payment_status,
    this.special_instructions,
    this.preferred_partner_id,
    required this.created_at,
    required this.updated_at,
  });

  factory Booking.fromJson(Map<String, dynamic> json) => _$BookingFromJson(json);
  Map<String, dynamic> toJson() => _$BookingToJson(this);
}
