import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/config/app_config.dart';
import '../storage/storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SupabaseClient _supabase = Supabase.instance.client;
  final StorageService _storage = StorageService();
  bool _isRefreshingToken = false;
  final List<ErrorInterceptorHandler> _requestsWaitingForToken = [];

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      // Use AppConfig for dynamic environment configuration
      baseUrl: baseUrl ?? AppConfig.functionsBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _setupInterceptors();
  }

  void _setupInterceptors() {
    // Request interceptor for adding auth token from Supabase session
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Try to get token from Supabase session first (most reliable)
          String? token = _supabase.auth.currentSession?.accessToken;

          // Fallback to storage if no active session
          token ??= _storage.getAccessToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('\n🔵 PARTNER APP REQUEST 🔵');
          print('Method: ${options.method}');
          print('URI: ${options.uri}');
          print('Token Source: ${_supabase.auth.currentSession?.accessToken != null ? 'Supabase Session' : (token != null ? 'Storage' : 'None')}');
          print('Has Auth Token: ${token != null}');
          print('🔵 END REQUEST 🔵\n');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ API Error: ${error.response?.statusCode} - ${error.message}');

          // Handle 401 Unauthorized errors
          if (error.response?.statusCode == 401) {
            print('🔄 Attempting token refresh...');

            if (_isRefreshingToken) {
              // Token is already being refreshed, queue this request
              print('⏳ Token refresh in progress, queueing request...');
              _requestsWaitingForToken.add(handler);
              return;
            }

            _isRefreshingToken = true;

            try {
              // Attempt to refresh token via Supabase
              final session = _supabase.auth.currentSession;
              if (session?.refreshToken != null) {
                final response = await _supabase.auth.refreshSession();
                if (response.session?.accessToken != null) {
                  // Save new token to storage
                  await _storage.saveAccessToken(response.session!.accessToken);
                  print('✅ Token refreshed successfully');

                  // Retry the original request with new token
                  final newToken = response.session!.accessToken;
                  error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
                  final retryResponse = await _dio.fetch(error.requestOptions);

                  _isRefreshingToken = false;

                  // Retry original request
                  handler.resolve(retryResponse);

                  // Retry queued requests
                  for (var queuedHandler in _requestsWaitingForToken) {
                    queuedHandler.next(error);
                  }
                  _requestsWaitingForToken.clear();
                  return;
                }
              }
            } catch (e) {
              print('❌ Token refresh failed: $e');
            }

            _isRefreshingToken = false;
            _requestsWaitingForToken.clear();

            // Token refresh failed, clear auth data and let error propagate
            print('❌ Authentication failed. Clearing stored credentials.');
            await _storage.clearAll();
          }

          handler.next(error);
        },
      ),
    );

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  void setAuthToken(String token) {
    // Deprecated: Token is now automatically retrieved from Supabase session
    // Kept for backward compatibility but does nothing
  }

  void clearAuthToken() {
    // Deprecated: Token is now automatically retrieved from Supabase session
    // Kept for backward compatibility but does nothing
  }

  // Auth endpoints
  Future<Response> sendOtp(String phone) {
    return _dio.post('/auth/partner/send-otp', data: {'phone': phone});
  }

  Future<Response> verifyOtp(String phone, String otp) {
    return _dio.post('/auth/partner/verify-otp', data: {
      'phone': phone,
      'otp': otp,
    });
  }

  // Partner endpoints
  Future<Response> getPartnerProfile(String partnerId) {
    return _dio.get('/partners/$partnerId');
  }

  Future<Response> updatePartnerProfile(String partnerId, Map<String, dynamic> data) {
    return _dio.put('/partners/$partnerId', data: data);
  }

  Future<Response> updateAvailability(String partnerId, bool isAvailable) {
    return _dio.patch('/partners/$partnerId/availability', data: {
      'is_available': isAvailable,
    });
  }

  // Job endpoints
  // Note: baseUrl already includes /functions/v1, so paths should not duplicate it
  Future<Response> getAvailableJobs({int page = 1, int limit = 20}) {
    return _dio.get('/partner-jobs/available', queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  Future<Response> getAssignedJobs({String? status, String? fromDate, String? toDate, int page = 1, int limit = 20}) {
    return _dio.get('/partner-jobs/assigned', queryParameters: {
      if (status != null) 'status': status,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  Future<Response> getJobDetails(String jobId) {
    return _dio.get('/partner-jobs/$jobId');
  }

  Future<Response> acceptJob(String jobId) {
    return _dio.post('/partner-jobs/$jobId/accept');
  }

  Future<Response> rejectJob(String jobId, String reason) {
    return _dio.post('/partner-jobs/$jobId/reject', data: {
      'reason': reason,
    });
  }

  Future<Response> startJob(String jobId) {
    return _dio.post('/partner-jobs/$jobId/start');
  }

  Future<Response> completeJob(String jobId) {
    return _dio.post('/partner-jobs/$jobId/complete');
  }

  Future<Response> cancelJob(String jobId, String reason) {
    return _dio.post('/partner-jobs/$jobId/cancel', data: {
      'reason': reason,
    });
  }

  // Document endpoints
  Future<Response> uploadDocument(String partnerId, String documentType, FormData formData) {
    return _dio.post('/partners/$partnerId/documents/$documentType', data: formData);
  }

  Future<Response> getDocuments(String partnerId) {
    return _dio.get('/partners/$partnerId/documents');
  }

  // Generic HTTP methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data, dynamic body}) {
    return _dio.put(path, data: data ?? body);
  }

  Future<Response> delete(String path) {
    return _dio.delete(path);
  }
}
