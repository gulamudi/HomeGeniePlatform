import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/address.dart';

part 'api_service.g.dart';

@RestApi(baseUrl: 'http://127.0.0.1:54321/functions/v1')
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Authentication APIs
  @POST('/auth-login')
  Future<ApiResponse> login(@Body() Map<String, dynamic> request);

  @POST('/auth-verify-otp')
  Future<ApiResponse> verifyOtp(@Body() Map<String, dynamic> request);

  @POST('/auth-refresh-token')
  Future<ApiResponse> refreshToken(@Body() Map<String, dynamic> request);

  @POST('/auth-logout')
  Future<ApiResponse> logout(@Body() Map<String, dynamic> request);

  @GET('/auth-profile')
  Future<ApiResponse> getProfile();

  @PUT('/auth-profile')
  Future<ApiResponse> updateProfile(@Body() Map<String, dynamic> request);

  // Customer APIs
  @GET('/customer-profile')
  Future<ApiResponse> getCustomerProfile();

  @PUT('/customer-profile')
  Future<ApiResponse> updateCustomerProfile(@Body() Map<String, dynamic> request);

  @GET('/customer-addresses')
  Future<ApiResponse> getAddresses();

  @POST('/customer-addresses')
  Future<ApiResponse> addAddress(@Body() Map<String, dynamic> request);

  @PUT('/customer-addresses')
  Future<ApiResponse> updateAddress(@Body() Map<String, dynamic> request);

  @DELETE('/customer-addresses')
  Future<ApiResponse> deleteAddress(@Body() Map<String, dynamic> request);

  @GET('/customer-services')
  Future<ApiResponse> getServices(
    @Query('category') String? category,
    @Query('search') String? search,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @GET('/customer-services/{serviceId}')
  Future<ApiResponse> getServiceDetails(@Path('serviceId') String serviceId);

  @GET('/customer-bookings')
  Future<ApiResponse> getBookings(
    @Query('status') String? status,
    @Query('fromDate') String? fromDate,
    @Query('toDate') String? toDate,
    @Query('page') int? page,
    @Query('limit') int? limit,
  );

  @POST('/customer-bookings')
  Future<ApiResponse> createBooking(@Body() Map<String, dynamic> request);

  @GET('/customer-bookings/{bookingId}')
  Future<ApiResponse> getBookingDetails(@Path('bookingId') String bookingId);

  @PUT('/customer-bookings/{bookingId}/cancel')
  Future<ApiResponse> cancelBooking(
    @Path('bookingId') String bookingId,
    @Body() Map<String, dynamic> request,
  );

  @PUT('/customer-bookings/{bookingId}/reschedule')
  Future<ApiResponse> rescheduleBooking(
    @Path('bookingId') String bookingId,
    @Body() Map<String, dynamic> request,
  );

  @POST('/customer-bookings/ratings')
  Future<ApiResponse> rateService(@Body() Map<String, dynamic> request);
}