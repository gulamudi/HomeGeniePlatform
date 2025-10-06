import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/dio_client.dart';
import '../network/api_service.dart';
import '../constants/app_constants.dart';

final dioProvider = Provider<DioClient>((ref) {
  return DioClient.instance;
});

final apiServiceProvider = Provider<ApiService>((ref) {
  final dio = ref.watch(dioProvider).dio;
  // Explicitly pass baseUrl from AppConstants (which reads from AppConfig)
  return ApiService(dio, baseUrl: AppConstants.baseUrl);
});
