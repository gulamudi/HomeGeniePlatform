import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared/config/app_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();

  SupabaseService._();

  SupabaseClient? _client;
  SupabaseClient get client {
    if (_client == null) {
      throw Exception('Supabase not initialized. Call init() first.');
    }
    return _client!;
  }

  Future<void> init() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
    );
    _client = Supabase.instance.client;
  }

  // Auth helpers
  User? get currentUser => _client?.auth.currentUser;
  String? get currentUserId => currentUser?.id;
  bool get isAuthenticated => currentUser != null;

  // Sign in with phone
  Future<void> signInWithPhone(String phone) async {
    await client.auth.signInWithOtp(
      phone: phone,
    );
  }

  // Verify OTP
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String token,
  }) async {
    return await client.auth.verifyOTP(
      phone: phone,
      token: token,
      type: OtpType.sms,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Database helpers

  /// Get partner profile
  Future<Map<String, dynamic>?> getPartnerProfile(String userId) async {
    final response = await client
        .from('partner_profiles')
        .select('*, users!inner(*)')
        .eq('user_id', userId)
        .single();
    return response;
  }

  /// Update partner availability
  Future<void> updatePartnerAvailability({
    required String userId,
    required bool isAvailable,
  }) async {
    await client
        .from('partner_profiles')
        .update({
          'availability': {
            'isAvailable': isAvailable,
          }
        })
        .eq('user_id', userId);
  }

  /// Get available jobs for partner
  Future<List<Map<String, dynamic>>> getAvailableJobs({
    required String partnerId,
  }) async {
    final response = await client
        .from('bookings')
        .select('''
          *,
          services(*),
          users!bookings_customer_id_fkey(*)
        ''')
        .eq('status', 'pending')
        .not('partner_id', 'eq', null)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Get partner jobs
  Future<List<Map<String, dynamic>>> getPartnerJobs({
    required String partnerId,
    String? status,
  }) async {
    var query = client
        .from('bookings')
        .select('''
          *,
          services(*),
          users!bookings_customer_id_fkey(*)
        ''')
        .eq('partner_id', partnerId);

    if (status != null) {
      query = query.eq('status', status);
    }

    final response = await query.order('scheduled_date', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  /// Accept job
  Future<void> acceptJob({
    required String bookingId,
    required String partnerId,
  }) async {
    await client
        .from('bookings')
        .update({
          'partner_id': partnerId,
          'status': 'confirmed',
        })
        .eq('id', bookingId);

    // Add timeline entry
    await client.from('booking_timeline').insert({
      'booking_id': bookingId,
      'status': 'confirmed',
      'updated_by': partnerId,
      'updated_by_type': 'partner',
    });
  }

  /// Reject job
  Future<void> rejectJob({
    required String bookingId,
  }) async {
    // Just leave it for other partners
    // No action needed
  }

  /// Update booking status
  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    required String partnerId,
    String? notes,
  }) async {
    await client
        .from('bookings')
        .update({
          'status': status,
        })
        .eq('id', bookingId);

    // Add timeline entry
    await client.from('booking_timeline').insert({
      'booking_id': bookingId,
      'status': status,
      'updated_by': partnerId,
      'updated_by_type': 'partner',
      'notes': notes,
    });
  }

  /// Get partner earnings
  Future<Map<String, dynamic>> getPartnerEarnings(String partnerId) async {
    final response = await client
        .from('partner_profiles')
        .select('total_earnings, total_jobs')
        .eq('user_id', partnerId)
        .single();
    return response;
  }

  /// Get earnings history
  Future<List<Map<String, dynamic>>> getEarningsHistory(String partnerId) async {
    final response = await client
        .from('bookings')
        .select('*, services(*)')
        .eq('partner_id', partnerId)
        .eq('status', 'completed')
        .order('completed_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  /// Subscribe to new bookings (for job alerts)
  RealtimeChannel subscribeToNewBookings({
    required Function(Map<String, dynamic>) onNewBooking,
  }) {
    return client
        .channel('new_bookings')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            if (payload.newRecord['status'] == 'pending' &&
                payload.newRecord['partner_id'] == null) {
              onNewBooking(payload.newRecord);
            }
          },
        )
        .subscribe();
  }

  /// Subscribe to job status changes
  RealtimeChannel subscribeToJobUpdates({
    required String bookingId,
    required Function(Map<String, dynamic>) onUpdate,
  }) {
    return client
        .channel('booking_$bookingId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'bookings',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id',
            value: bookingId,
          ),
          callback: (payload) {
            onUpdate(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Unsubscribe from channel
  Future<void> unsubscribe(RealtimeChannel channel) async {
    await client.removeChannel(channel);
  }
}
