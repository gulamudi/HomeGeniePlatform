import 'package:freezed_annotation/freezed_annotation.dart';

part 'service_area.freezed.dart';
part 'service_area.g.dart';

@freezed
class ServiceArea with _$ServiceArea {
  const factory ServiceArea({
    required String id,
    required String name,
    required String city,
    required String state,
    required double radiusKm,
    @Default(true) bool isActive,
    @Default(0) int displayOrder,
  }) = _ServiceArea;

  factory ServiceArea.fromJson(Map<String, dynamic> json) =>
      _$ServiceAreaFromJson(json);
}

@freezed
class ServiceAreasResponse with _$ServiceAreasResponse {
  const factory ServiceAreasResponse({
    required List<ServiceArea> areas,
    required Map<String, List<ServiceArea>> groupedByCity,
    required int count,
  }) = _ServiceAreasResponse;

  factory ServiceAreasResponse.fromJson(Map<String, dynamic> json) {
    // Parse areas - handle null safely
    final areasList = json['areas'] as List<dynamic>?;
    final areas = areasList != null
        ? areasList
            .map((e) => ServiceArea.fromJson(e as Map<String, dynamic>))
            .toList()
        : <ServiceArea>[];

    // Parse groupedByCity
    final groupedByCity = <String, List<ServiceArea>>{};
    if (json['groupedByCity'] != null) {
      (json['groupedByCity'] as Map<String, dynamic>).forEach((key, value) {
        final valueList = value as List<dynamic>?;
        groupedByCity[key] = valueList != null
            ? valueList
                .map((e) => ServiceArea.fromJson(e as Map<String, dynamic>))
                .toList()
            : <ServiceArea>[];
      });
    }

    return ServiceAreasResponse(
      areas: areas,
      groupedByCity: groupedByCity,
      count: json['count'] as int? ?? 0,
    );
  }
}
