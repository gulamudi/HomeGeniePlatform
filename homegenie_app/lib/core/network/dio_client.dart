import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;

  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  static DioClient get instance {
    _instance ??= DioClient._internal();
    return _instance!;
  }

  Dio get dio => _dio;

  void _setupInterceptors() {
    // Request interceptor for adding auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService.getString(AppConstants.userTokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          if (kDebugMode) {
            print('Request: ${options.method} ${options.uri}');
            print('Headers: ${options.headers}');
            if (options.data != null) {
              print('Body: ${options.data}');
            }
          }

          handler.next(options);
        },
        onResponse: (response, handler) {
          if (kDebugMode) {
            print('Response: ${response.statusCode} ${response.requestOptions.uri}');
            print('Data: ${response.data}');
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          if (kDebugMode) {
            print('Error: ${error.response?.statusCode} ${error.requestOptions.uri}');
            print('Error Data: ${error.response?.data}');
          }

          // Handle token expiry
          if (error.response?.statusCode == 401) {
            final refreshToken = await StorageService.getString(AppConstants.refreshTokenKey);
            if (refreshToken != null) {
              try {
                // Attempt token refresh
                final response = await _refreshToken(refreshToken);
                if (response != null) {
                  // Retry original request with new token
                  final newToken = response['data']['accessToken'];
                  await StorageService.setString(AppConstants.userTokenKey, newToken);

                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);
                  handler.resolve(retryResponse);
                  return;
                }
              } catch (e) {
                if (kDebugMode) {
                  print('Token refresh failed: $e');
                }
              }
            }

            // Clear tokens and redirect to login
            await _clearAuthData();
          }

          handler.next(error);
        },
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
      ));
    }
  }

  Future<Map<String, dynamic>?> _refreshToken(String refreshToken) async {
    try {
      final response = await Dio().post(
        '${AppConstants.baseUrl}/auth-refresh-token',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final newRefreshToken = response.data['data']['refreshToken'];
        await StorageService.setString(AppConstants.refreshTokenKey, newRefreshToken);
        return response.data;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Refresh token error: $e');
      }
    }
    return null;
  }

  Future<void> _clearAuthData() async {
    await StorageService.remove(AppConstants.userTokenKey);
    await StorageService.remove(AppConstants.refreshTokenKey);
    await StorageService.remove(AppConstants.userDataKey);
  }

  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
  }
}