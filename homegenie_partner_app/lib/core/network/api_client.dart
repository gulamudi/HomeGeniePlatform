import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiClient {
  late final Dio _dio;
  final SupabaseClient _supabase = Supabase.instance.client;

  ApiClient({String? baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://127.0.0.1:54321',
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
          // Get token from Supabase session (same as consumer app)
          String? token = _supabase.auth.currentSession?.accessToken;

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          print('\n🔵 PARTNER APP REQUEST 🔵');
          print('Method: ${options.method}');
          print('URI: ${options.uri}');
          print('Has Auth Token: ${token != null}');
          print('Headers: ${options.headers}');
          print('🔵 END REQUEST 🔵\n');

          handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ Response: ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('❌ API Error: ${error.response?.statusCode} - ${error.message}');
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
  Future<Response> getAvailableJobs({int page = 1, int limit = 20}) {
    return _dio.get('/functions/v1/partner-jobs/available', queryParameters: {
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  Future<Response> getAssignedJobs({String? status, String? fromDate, String? toDate, int page = 1, int limit = 20}) {
    return _dio.get('/functions/v1/partner-jobs/assigned', queryParameters: {
      if (status != null) 'status': status,
      if (fromDate != null) 'fromDate': fromDate,
      if (toDate != null) 'toDate': toDate,
      'page': page.toString(),
      'limit': limit.toString(),
    });
  }

  Future<Response> getJobDetails(String jobId) {
    return _dio.get('/functions/v1/partner-jobs/$jobId');
  }

  Future<Response> acceptJob(String jobId) {
    return _dio.post('/functions/v1/partner-jobs/$jobId/accept');
  }

  Future<Response> rejectJob(String jobId, String reason) {
    return _dio.post('/functions/v1/partner-jobs/$jobId/reject', data: {
      'reason': reason,
    });
  }

  Future<Response> startJob(String jobId) {
    return _dio.post('/functions/v1/partner-jobs/$jobId/start');
  }

  Future<Response> completeJob(String jobId) {
    return _dio.post('/functions/v1/partner-jobs/$jobId/complete');
  }

  Future<Response> cancelJob(String jobId, String reason) {
    return _dio.post('/functions/v1/partner-jobs/$jobId/cancel', data: {
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
}
