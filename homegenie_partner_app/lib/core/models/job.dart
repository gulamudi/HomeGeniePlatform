import 'package:json_annotation/json_annotation.dart';

part 'job.g.dart';

@JsonSerializable()
class Job {
  final String id;
  final String bookingId;
  final String serviceType;
  final String serviceName;
  final String status;
  final DateTime scheduledDate;
  final String? scheduledTime;
  final double amount;
  final double? partnerEarning;
  final String customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerPhoto;
  final String address;
  final double? latitude;
  final double? longitude;
  final String? instructions;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final int? rating;
  final String? review;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Job({
    required this.id,
    required this.bookingId,
    required this.serviceType,
    required this.serviceName,
    required this.status,
    required this.scheduledDate,
    this.scheduledTime,
    required this.amount,
    this.partnerEarning,
    required this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerPhoto,
    required this.address,
    this.latitude,
    this.longitude,
    this.instructions,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    this.rating,
    this.review,
    required this.createdAt,
    this.updatedAt,
  });

  factory Job.fromJson(Map<String, dynamic> json) => _$JobFromJson(json);
  Map<String, dynamic> toJson() => _$JobToJson(this);

  Job copyWith({
    String? id,
    String? bookingId,
    String? serviceType,
    String? serviceName,
    String? status,
    DateTime? scheduledDate,
    String? scheduledTime,
    double? amount,
    double? partnerEarning,
    String? customerId,
    String? customerName,
    String? customerPhone,
    String? customerPhoto,
    String? address,
    double? latitude,
    double? longitude,
    String? instructions,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
    String? cancelReason,
    int? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Job(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      serviceType: serviceType ?? this.serviceType,
      serviceName: serviceName ?? this.serviceName,
      status: status ?? this.status,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      amount: amount ?? this.amount,
      partnerEarning: partnerEarning ?? this.partnerEarning,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerPhoto: customerPhoto ?? this.customerPhoto,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      instructions: instructions ?? this.instructions,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      cancelReason: cancelReason ?? this.cancelReason,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  bool get isUpcoming {
    return scheduledDate.isAfter(DateTime.now()) && !isToday;
  }

  bool get isPast {
    return scheduledDate.isBefore(DateTime.now()) && !isToday;
  }

  Duration? get elapsedTime {
    if (startedAt == null) return null;
    final endTime = completedAt ?? DateTime.now();
    return endTime.difference(startedAt!);
  }
}
