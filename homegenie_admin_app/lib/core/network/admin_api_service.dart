import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/dashboard_stats.dart';

final adminApiServiceProvider = Provider<AdminApiService>((ref) {
  return AdminApiService();
});

class AdminApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Dashboard
  Future<DashboardStats> getDashboardStats() async {
    try {
      final result = await _supabase.rpc('get_dashboard_stats').single();
      return DashboardStats.fromJson(result as Map<String, dynamic>);
    } catch (e) {
      print('Error fetching dashboard stats: $e');
      return const DashboardStats();
    }
  }

  // Customers
  Future<List<Map<String, dynamic>>> getCustomers({String? search}) async {
    try {
      var query = _supabase
          .from('users')
          .select('*, customer_profiles!customer_profiles_user_id_fkey!inner(*)')
          .eq('user_type', 'customer');

      if (search != null && search.isNotEmpty) {
        query = query.or(
            'full_name.ilike.%$search%,phone.ilike.%$search%,email.ilike.%$search%');
      }

      final result = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching customers: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCustomerById(String customerId) async {
    try {
      final result = await _supabase
          .from('users')
          .select('*, customer_profiles!customer_profiles_user_id_fkey!inner(*)')
          .eq('id', customerId)
          .single();
      return result as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching customer: $e');
      return null;
    }
  }

  Future<String?> createCustomer({
    required String phone,
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    try {
      final result = await _supabase.rpc('admin_create_customer_profile',
          params: {
            'p_phone': phone,
            'p_first_name': firstName,
            'p_last_name': lastName,
            'p_email': email,
          });
      return result.toString();
    } catch (e) {
      print('Error creating customer: $e');
      rethrow;
    }
  }

  Future<void> updateCustomer({
    required String customerId,
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    try {
      await _supabase.from('users').update({
        'full_name': '$firstName $lastName',
        'email': email,
      }).eq('id', customerId);
    } catch (e) {
      print('Error updating customer: $e');
      rethrow;
    }
  }

  // Partners
  Future<List<Map<String, dynamic>>> getPartners({String? search}) async {
    try {
      var query = _supabase
          .from('users')
          .select('*, partner_profiles!partner_profiles_user_id_fkey!inner(*)')
          .eq('user_type', 'partner');

      if (search != null && search.isNotEmpty) {
        query = query.or(
            'full_name.ilike.%$search%,phone.ilike.%$search%,email.ilike.%$search%');
      }

      final result = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching partners: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getPartnerById(String partnerId) async {
    try {
      final result = await _supabase
          .from('users')
          .select('*, partner_profiles!partner_profiles_user_id_fkey!inner(*)')
          .eq('id', partnerId)
          .single();
      return result as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching partner: $e');
      return null;
    }
  }

  Future<String?> createPartner({
    required String phone,
    required String firstName,
    required String lastName,
    String? email,
    List<String> services = const [],
  }) async {
    try {
      final result = await _supabase.rpc('admin_create_partner_profile',
          params: {
            'p_phone': phone,
            'p_first_name': firstName,
            'p_last_name': lastName,
            'p_email': email,
            'p_services': services,
          });
      return result.toString();
    } catch (e) {
      print('Error creating partner: $e');
      rethrow;
    }
  }

  Future<void> updatePartner({
    required String partnerId,
    required String firstName,
    required String lastName,
    String? email,
  }) async {
    try {
      await _supabase.from('users').update({
        'full_name': '$firstName $lastName',
        'email': email,
      }).eq('id', partnerId);
    } catch (e) {
      print('Error updating partner: $e');
      rethrow;
    }
  }

  // Bookings
  Future<List<Map<String, dynamic>>> getBookings({
    String? status,
    String? search,
  }) async {
    try {
      var query = _supabase.from('bookings').select(
          '*, customer:users!customer_id(id, full_name, phone), partner:users!partner_id(id, full_name, phone), service:services(*)');

      if (status != null && status.isNotEmpty) {
        query = query.eq('status', status);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('id.ilike.%$search%');
      }

      final result = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching bookings: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getBookingById(String bookingId) async {
    try {
      final result = await _supabase
          .from('bookings')
          .select(
              '*, customer:users!customer_id(id, full_name, phone, email), partner:users!partner_id(id, full_name, phone, email), service:services(*)')
          .eq('id', bookingId)
          .single();
      return result as Map<String, dynamic>;
    } catch (e) {
      print('Error fetching booking: $e');
      return null;
    }
  }

  Future<void> assignPartnerToBooking({
    required String bookingId,
    required String partnerId,
  }) async {
    try {
      await _supabase.rpc('admin_assign_partner_to_booking', params: {
        'p_booking_id': bookingId,
        'p_partner_id': partnerId,
      });
    } catch (e) {
      print('Error assigning partner: $e');
      rethrow;
    }
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
    String? notes,
  }) async {
    try {
      await _supabase.rpc('admin_update_booking_status', params: {
        'p_booking_id': bookingId,
        'p_new_status': status,
        'p_notes': notes,
      });
    } catch (e) {
      print('Error updating booking status: $e');
      rethrow;
    }
  }

  Future<void> rescheduleBooking({
    required String bookingId,
    required DateTime newDate,
  }) async {
    try {
      await _supabase.rpc('admin_reschedule_booking', params: {
        'p_booking_id': bookingId,
        'p_new_date': newDate.toIso8601String(),
      });
    } catch (e) {
      print('Error rescheduling booking: $e');
      rethrow;
    }
  }

  Future<void> cancelBooking({
    required String bookingId,
    String? reason,
  }) async {
    try {
      await _supabase.from('bookings').update({
        'status': 'cancelled',
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', bookingId);

      // Log the admin action
      await _supabase.from('admin_actions_log').insert({
        'admin_id': _supabase.auth.currentUser?.id,
        'action_type': 'CANCEL',
        'target_type': 'booking',
        'target_id': bookingId,
        'description': 'Cancelled booking${reason != null ? ": $reason" : ""}',
      });
    } catch (e) {
      print('Error cancelling booking: $e');
      rethrow;
    }
  }

  // Get available partners for assignment
  Future<List<Map<String, dynamic>>> getAvailablePartners({
    String? serviceId,
    String? search,
    String? verificationStatus,
    bool onlyVerified = false,
  }) async {
    try {
      var query = _supabase
          .from('users')
          .select('*, partner_profiles!partner_profiles_user_id_fkey!inner(*)')
          .eq('user_type', 'partner');

      // Only filter by verification if explicitly requested
      if (onlyVerified) {
        query = query.eq('partner_profiles.verification_status', 'verified');
      } else if (verificationStatus != null && verificationStatus.isNotEmpty) {
        query = query.eq('partner_profiles.verification_status', verificationStatus);
      }

      if (search != null && search.isNotEmpty) {
        query = query.or('full_name.ilike.%$search%,phone.ilike.%$search%');
      }

      final result = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching available partners: $e');
      return [];
    }
  }

  // Update partner verification status
  Future<void> updatePartnerVerificationStatus({
    required String partnerId,
    required String status,
  }) async {
    try {
      await _supabase
          .from('partner_profiles')
          .update({'verification_status': status})
          .eq('user_id', partnerId);

      // Log the admin action
      await _supabase.from('admin_actions_log').insert({
        'admin_id': _supabase.auth.currentUser?.id,
        'action_type': status.toUpperCase(),
        'target_type': 'partner',
        'target_id': partnerId,
        'description': 'Updated partner verification status to $status',
      });
    } catch (e) {
      print('Error updating partner verification: $e');
      rethrow;
    }
  }

  // Update partner services
  Future<void> updatePartnerServices({
    required String partnerId,
    required List<String> services,
  }) async {
    try {
      await _supabase
          .from('partner_profiles')
          .update({'services': services})
          .eq('user_id', partnerId);
    } catch (e) {
      print('Error updating partner services: $e');
      rethrow;
    }
  }

  // Get all services
  Future<List<Map<String, dynamic>>> getServices() async {
    try {
      final result = await _supabase
          .from('services')
          .select('*')
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(result);
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  // Create booking from admin
  Future<String?> createBooking({
    required String customerId,
    required String serviceId,
    required DateTime scheduledDate,
    required String address,
    String? notes,
  }) async {
    try {
      final result = await _supabase.rpc('admin_create_booking', params: {
        'p_customer_id': customerId,
        'p_service_id': serviceId,
        'p_scheduled_date': scheduledDate.toIso8601String(),
        'p_address': address,
        'p_notes': notes,
      });
      return result.toString();
    } catch (e) {
      print('Error creating booking: $e');
      rethrow;
    }
  }
}
