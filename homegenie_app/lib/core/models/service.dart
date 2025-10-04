import 'package:json_annotation/json_annotation.dart';

part 'service.g.dart';

@JsonSerializable()
class Service {
  @JsonKey(name: 'id')
  final String id;

  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String description;

  @JsonKey(name: 'category')
  final String category;

  @JsonKey(name: 'basePrice')
  final double base_price;

  @JsonKey(name: 'durationHours')
  final double duration_hours;

  @JsonKey(name: 'isActive')
  final bool is_active;

  @JsonKey(name: 'requirements')
  final List<String> requirements;

  @JsonKey(name: 'includes')
  final List<String> includes;

  @JsonKey(name: 'excludes')
  final List<String> excludes;

  @JsonKey(name: 'imageUrl')
  final String? image_url;

  @JsonKey(name: 'createdAt')
  final DateTime created_at;

  @JsonKey(name: 'updatedAt')
  final DateTime updated_at;

  const Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.base_price,
    required this.duration_hours,
    required this.is_active,
    required this.requirements,
    required this.includes,
    required this.excludes,
    this.image_url,
    required this.created_at,
    required this.updated_at,
  });

  factory Service.fromJson(Map<String, dynamic> json) => _$ServiceFromJson(json);
  Map<String, dynamic> toJson() => _$ServiceToJson(this);
}
