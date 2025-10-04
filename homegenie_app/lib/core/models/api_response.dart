import 'package:json_annotation/json_annotation.dart';

part 'api_response.g.dart';

@JsonSerializable()
class ApiResponse {
  @JsonKey(name: 'success')
  final bool success;

  @JsonKey(name: 'data')
  final dynamic data;

  @JsonKey(name: 'error')
  final String? error;

  @JsonKey(name: 'message')
  final String? message;

  const ApiResponse({
    required this.success,
    required this.data,
    this.error,
    this.message,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) => _$ApiResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ApiResponseToJson(this);
}
