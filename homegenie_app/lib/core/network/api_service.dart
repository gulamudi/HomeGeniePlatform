import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/service.dart';
import '../models/booking.dart';
import '../models/address.dart';

part 'api_service.g.dart';

// Note: baseUrl is now passed dynamically from DioClient
// No hardcoded URL in annotation
@RestApi()
abstract class ApiService {
  factory ApiService(Dio dio, {String baseUrl}) = _ApiService;

  // Note: Authentication (login, OTP verification) is handled directly via Supabase Auth client
  // See: lib/features/auth/providers/auth_provider.dart

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