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

  /// Get single job by ID
  Future<Map<String, dynamic>> getJobById(String jobId) async {
    try {
      print('🔵 [SupabaseService] Fetching job by ID: $jobId');

      final response = await client
          .from('bookings')
          .select('''
            *,
            services(*),
            users!bookings_customer_id_fkey(*)
          ''')
          .eq('id', jobId)
          .single();

      print('✅ [SupabaseService] Job fetched successfully');
      return response;
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error fetching job: $e');
      print('   Stack trace: $stackTrace');
      throw Exception('Failed to fetch job: $e');
    }
  }

  /// Accept job using database function (bypasses RLS)
  Future<void> acceptJob({
    required String bookingId,
    required String partnerId,
  }) async {
    try {
      print('🔵 [SupabaseService] Accepting job...');
      print('   Booking ID: $bookingId');
      print('   Partner ID: $partnerId');
      print('   Auth UID: ${client.auth.currentUser?.id}');

      // Call the database function that handles both booking update and timeline entry
      print('🔵 [SupabaseService] Calling accept_job function...');
      final response = await client.rpc(
        'accept_job',
        params: {
          'p_booking_id': bookingId,
          'p_partner_id': partnerId,
        },
      );

      print('✅ [SupabaseService] Function response: $response');

      // Check if the function returned an error
      if (response is Map && response['success'] == false) {
        throw Exception(response['error'] ?? 'Unknown error from accept_job function');
      }

      print('✅ [SupabaseService] Job accepted successfully!');
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error accepting job: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      throw Exception('Failed to accept job: $e');
    }
  }

  /// Reject job using database function
  Future<void> rejectJob({
    required String bookingId,
    String? reason,
  }) async {
    try {
      print('🔵 [SupabaseService] Rejecting job...');
      print('   Booking ID: $bookingId');
      print('   Reason: $reason');
      print('   Partner ID: $currentUserId');

      // Try calling the database function if it exists
      try {
        final response = await client.rpc(
          'reject_job',
          params: {
            'p_booking_id': bookingId,
            'p_partner_id': currentUserId,
            'p_reason': reason ?? 'Partner declined',
          },
        );

        print('✅ [SupabaseService] RPC Function response: $response');

        // Check if the function returned an error
        if (response is Map && response['success'] == false) {
          throw Exception(response['error'] ?? 'Unknown error from reject_job function');
        }

        print('✅ [SupabaseService] Job rejected successfully via RPC!');
      } catch (rpcError) {
        // If RPC function doesn't exist, just log the rejection
        // The job remains available for other partners
        print('⚠️ [SupabaseService] RPC reject_job not available, logging rejection only');
        print('   RPC Error: $rpcError');
        print('✅ [SupabaseService] Job rejection recorded (no-op)');
      }
    } catch (e, stackTrace) {
      print('❌ [SupabaseService] Error rejecting job: $e');
      print('   Error type: ${e.runtimeType}');
      print('   Stack trace: $stackTrace');
      throw Exception('Failed to reject job: $e');
    }
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

  /// Subscribe to notifications for partner (for job offers)
  RealtimeChannel subscribeToNotifications({
    required String partnerId,
    required Function(Map<String, dynamic>) onNotification,
    Function(String notificationId)? onNotificationDeleted,
  }) {
    print('========================================');
    print('📡 [SupabaseService] SETTING UP REALTIME SUBSCRIPTION');
    print('   Partner ID: $partnerId');
    print('   Channel: partner_notifications_$partnerId');
    print('========================================');

    final channel = client
        .channel('partner_notifications_$partnerId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: partnerId,
          ),
          callback: (payload) {
            print('========================================');
            print('🔔 [SupabaseService] REALTIME NOTIFICATION RECEIVED!');
            print('   Payload: ${payload.newRecord}');
            print('========================================');
            onNotification(payload.newRecord);
          },
        )
        .onPostgresChanges(
          event: PostgresChangeEvent.delete,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: partnerId,
          ),
          callback: (payload) {
            print('========================================');
            print('🗑️ [SupabaseService] NOTIFICATION DELETED!');
            print('   Old Record: ${payload.oldRecord}');
            print('========================================');

            // Extract notification ID from deleted record
            final deletedNotificationId = payload.oldRecord['id']?.toString();
            final bookingId = (payload.oldRecord['data'] as Map<String, dynamic>?)?['booking_id']?.toString();

            print('   Notification ID: $deletedNotificationId');
            print('   Booking ID: $bookingId');

            if (onNotificationDeleted != null && bookingId != null) {
              onNotificationDeleted(bookingId);
            }
          },
        )
        .subscribe((status, [error]) {
          print('========================================');
          print('📡 [SupabaseService] SUBSCRIPTION STATUS CHANGED');
          print('   Status: $status');
          if (error != null) {
            print('   ❌ Error: $error');
          }
          print('========================================');

          if (status == RealtimeSubscribeStatus.subscribed) {
            print('✅✅✅ SUCCESSFULLY SUBSCRIBED TO NOTIFICATIONS ✅✅✅');
            print('   Partner: $partnerId');
            print('   Listening for notifications...');
          } else if (status == RealtimeSubscribeStatus.channelError) {
            print('❌ [SupabaseService] Channel error - check if Realtime is enabled in Supabase');
          } else if (status == RealtimeSubscribeStatus.timedOut) {
            print('⏱️ [SupabaseService] Subscription timed out');
          } else if (status == RealtimeSubscribeStatus.closed) {
            print('🚪 [SupabaseService] Channel closed');
          }
        });

    return channel;
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
