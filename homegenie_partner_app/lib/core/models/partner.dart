import 'package:json_annotation/json_annotation.dart';

part 'partner.g.dart';

@JsonSerializable()
class Partner {
  final String id;
  final String phone;
  final String? name;
  final String? email;
  final String? profilePhoto;
  final String verificationStatus;
  final bool isAvailable;
  final double? rating;
  final int? totalJobs;
  final List<String> serviceTypes;
  final List<String> preferredLocations;
  final Map<String, dynamic>? availability;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Partner({
    required this.id,
    required this.phone,
    this.name,
    this.email,
    this.profilePhoto,
    required this.verificationStatus,
    this.isAvailable = true,
    this.rating,
    this.totalJobs,
    this.serviceTypes = const [],
    this.preferredLocations = const [],
    this.availability,
    required this.createdAt,
    this.updatedAt,
  });

  factory Partner.fromJson(Map<String, dynamic> json) => _$PartnerFromJson(json);
  Map<String, dynamic> toJson() => _$PartnerToJson(this);

  Partner copyWith({
    String? id,
    String? phone,
    String? name,
    String? email,
    String? profilePhoto,
    String? verificationStatus,
    bool? isAvailable,
    double? rating,
    int? totalJobs,
    List<String>? serviceTypes,
    List<String>? preferredLocations,
    Map<String, dynamic>? availability,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Partner(
      id: id ?? this.id,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      email: email ?? this.email,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      isAvailable: isAvailable ?? this.isAvailable,
      rating: rating ?? this.rating,
      totalJobs: totalJobs ?? this.totalJobs,
      serviceTypes: serviceTypes ?? this.serviceTypes,
      preferredLocations: preferredLocations ?? this.preferredLocations,
      availability: availability ?? this.availability,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
