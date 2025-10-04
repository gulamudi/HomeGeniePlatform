import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';

final dioProvider = Provider<DioClient>((ref) {
  return DioClient.instance;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider).dio;
  return ApiService(dio);
});
