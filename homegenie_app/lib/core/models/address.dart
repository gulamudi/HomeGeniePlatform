import 'package:json_annotation/json_annotation.dart';

part 'address.g.dart';

@JsonSerializable()
class Address {
  @JsonKey(name: 'id')
  final String? id;

  @JsonKey(name: 'flatHouseNo')
  final String flat_house_no;

  @JsonKey(name: 'buildingApartmentName')
  final String? building_apartment_name;

  @JsonKey(name: 'streetName')
  final String street_name;

  @JsonKey(name: 'landmark')
  final String? landmark;

  @JsonKey(name: 'area')
  final String area;

  @JsonKey(name: 'city')
  final String city;

  @JsonKey(name: 'state')
  final String state;

  @JsonKey(name: 'pinCode')
  final String pin_code;

  @JsonKey(name: 'type')
  final String type;

  @JsonKey(name: 'isDefault')
  final bool is_default;

  const Address({
    this.id,
    required this.flat_house_no,
    this.building_apartment_name,
    required this.street_name,
    this.landmark,
    required this.area,
    required this.city,
    required this.state,
    required this.pin_code,
    required this.type,
    required this.is_default,
  });

  factory Address.fromJson(Map<String, dynamic> json) => _$AddressFromJson(json);
  Map<String, dynamic> toJson() => _$AddressToJson(this);
}
