import 'package:dio/dio.dart';

class ApiClient {
  late final Dio _dio;

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

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
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
  Future<Response> getJobs({String? status, String? date}) {
    return _dio.get('/partners/jobs', queryParameters: {
      if (status != null) 'status': status,
      if (date != null) 'date': date,
    });
  }

  Future<Response> getJobDetails(String jobId) {
    return _dio.get('/partners/jobs/$jobId');
  }

  Future<Response> acceptJob(String jobId) {
    return _dio.post('/partners/jobs/$jobId/accept');
  }

  Future<Response> rejectJob(String jobId, String reason) {
    return _dio.post('/partners/jobs/$jobId/reject', data: {
      'reason': reason,
    });
  }

  Future<Response> startJob(String jobId) {
    return _dio.post('/partners/jobs/$jobId/start');
  }

  Future<Response> completeJob(String jobId) {
    return _dio.post('/partners/jobs/$jobId/complete');
  }

  Future<Response> cancelJob(String jobId, String reason) {
    return _dio.post('/partners/jobs/$jobId/cancel', data: {
      'reason': reason,
    });
  }

  // Earnings endpoints
  Future<Response> getEarningsSummary(String partnerId) {
    return _dio.get('/partners/$partnerId/earnings/summary');
  }

  Future<Response> getEarningsTransactions(String partnerId) {
    return _dio.get('/partners/$partnerId/earnings/transactions');
  }

  Future<Response> requestWithdrawal(String partnerId, Map<String, dynamic> data) {
    return _dio.post('/partners/$partnerId/earnings/withdraw', data: data);
  }

  // Document endpoints
  Future<Response> uploadDocument(String partnerId, String documentType, FormData formData) {
    return _dio.post('/partners/$partnerId/documents/$documentType', data: formData);
  }

  Future<Response> getDocuments(String partnerId) {
    return _dio.get('/partners/$partnerId/documents');
  }
}
