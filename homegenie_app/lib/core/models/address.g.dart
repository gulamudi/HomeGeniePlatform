// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Address _$AddressFromJson(Map<String, dynamic> json) => Address(
      id: json['id'] as String?,
      flat_house_no: json['flatHouseNo'] as String,
      building_apartment_name: json['buildingApartmentName'] as String?,
      street_name: json['streetName'] as String,
      landmark: json['landmark'] as String?,
      area: json['area'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      pin_code: json['pinCode'] as String,
      type: json['type'] as String,
      is_default: json['isDefault'] as bool,
    );

Map<String, dynamic> _$AddressToJson(Address instance) => <String, dynamic>{
      'id': instance.id,
      'flatHouseNo': instance.flat_house_no,
      'buildingApartmentName': instance.building_apartment_name,
      'streetName': instance.street_name,
      'landmark': instance.landmark,
      'area': instance.area,
      'city': instance.city,
      'state': instance.state,
      'pinCode': instance.pin_code,
      'type': instance.type,
      'isDefault': instance.is_default,
    };
