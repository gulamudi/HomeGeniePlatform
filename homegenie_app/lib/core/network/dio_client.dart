import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';
import '../storage/storage_service.dart';

class DioClient {
  static DioClient? _instance;
  late Dio _dio;
  final SupabaseClient _supabase = Supabase.instance.client;

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
          // Try to get token from Supabase session first (most reliable)
          String? token = _supabase.auth.currentSession?.accessToken;

          // Fallback to storage if no active session
          if (token == null) {
            token = await StorageService.getString(AppConstants.userTokenKey);
          }

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
            print('\n❌ API ERROR OCCURRED ❌');
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            _logDetailedError(error);
            print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
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

  void _logDetailedError(DioException error) {
    print('Request: ${error.requestOptions.method} ${error.requestOptions.uri}');

    // Categorize the error
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        print('Error Type: ⏱️  TIMEOUT');
        print('Issue: Request timed out after ${_dio.options.connectTimeout?.inSeconds}s');
        print('Possible causes:');
        print('  1. Supabase edge functions not running');
        print('  2. Network connectivity issues');
        print('  3. Server is overloaded');
        print('Fix: Run "supabase start" in your project directory');
        break;

      case DioExceptionType.connectionError:
        print('Error Type: 🔌 CONNECTION ERROR');
        print('Issue: Cannot connect to ${error.requestOptions.baseUrl}');
        print('Possible causes:');
        print('  1. Supabase is not running locally');
        print('  2. Wrong base URL configured');
        print('  3. Network/firewall blocking connection');
        print('Fix: Run "supabase start" and verify URL is http://127.0.0.1:54321/functions/v1');
        break;

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        print('Error Type: 📡 HTTP ${statusCode ?? "UNKNOWN"}');

        if (statusCode == 401) {
          print('Issue: Authentication failed');
          print('Possible causes:');
          print('  1. Invalid or expired auth token');
          print('  2. User not logged in');
          print('Fix: Re-authenticate the user');
        } else if (statusCode == 404) {
          print('Issue: Endpoint not found');
          print('Possible causes:');
          print('  1. Edge function not deployed');
          print('  2. Wrong endpoint path');
          print('Fix: Verify edge function exists and is running');
        } else if (statusCode == 500) {
          print('Issue: Server error');
          print('Possible causes:');
          print('  1. Database not initialized');
          print('  2. Edge function crashed');
          print('  3. Missing environment variables');
          print('Fix: Check edge function logs for details');
        }

        if (error.response?.data != null) {
          print('Response Data: ${error.response?.data}');
        }
        break;

      case DioExceptionType.cancel:
        print('Error Type: 🚫 REQUEST CANCELLED');
        break;

      case DioExceptionType.unknown:
        print('Error Type: ❓ UNKNOWN ERROR');
        print('Issue: ${error.message ?? "Unknown error occurred"}');
        print('Possible causes:');
        print('  1. Network completely unavailable');
        print('  2. Unexpected exception in request');
        break;

      default:
        print('Error Type: ${error.type}');
        print('Message: ${error.message}');
    }
  }
}