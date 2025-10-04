import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/supabase_service.dart';
import '../../../core/services/notification_service.dart';

// Job alert state
class JobAlert {
  final String id;
  final String serviceId;
  final String serviceName;
  final String serviceCategory;
  final double amount;
  final String address;
  final DateTime scheduledDate;
  final String? instructions;
  final String customerId;
  final String customerName;

  JobAlert({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.serviceCategory,
    required this.amount,
    required this.address,
    required this.scheduledDate,
    this.instructions,
    required this.customerId,
    required this.customerName,
  });

  factory JobAlert.fromMap(Map<String, dynamic> map) {
    final service = map['services'] as Map<String, dynamic>?;
    final customer = map['users'] as Map<String, dynamic>?;
    final address = map['address'] as Map<String, dynamic>? ?? {};

    return JobAlert(
      id: map['id'] as String,
      serviceId: map['service_id'] as String,
      serviceName: service?['name'] ?? 'Unknown Service',
      serviceCategory: service?['category'] ?? 'general',
      amount: (map['total_amount'] as num).toDouble(),
      address: address['formatted_address'] ?? address['line1'] ?? 'Unknown Address',
      scheduledDate: DateTime.parse(map['scheduled_date'] as String),
      instructions: map['special_instructions'] as String?,
      customerId: map['customer_id'] as String,
      customerName: customer?['full_name'] ?? 'Customer',
    );
  }
}

// Job alerts notifier
class JobAlertsNotifier extends StateNotifier<List<JobAlert>> {
  JobAlertsNotifier() : super([]);

  final _supabase = SupabaseService.instance;
  final _notifications = NotificationService.instance;

  void startListening(String partnerId) {
    _notifications.subscribeToJobAlerts(
      partnerId: partnerId,
      onNewJob: (booking) {
        final alert = JobAlert.fromMap(booking);
        state = [...state, alert];
      },
    );
  }

  void stopListening() {
    _notifications.unsubscribeFromJobAlerts();
  }

  void removeAlert(String alertId) {
    state = state.where((alert) => alert.id != alertId).toList();
  }

  Future<void> acceptJob(String bookingId, String partnerId) async {
    try {
      await _supabase.acceptJob(
        bookingId: bookingId,
        partnerId: partnerId,
      );
      removeAlert(bookingId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectJob(String bookingId) async {
    try {
      await _supabase.rejectJob(bookingId: bookingId);
      removeAlert(bookingId);
    } catch (e) {
      rethrow;
    }
  }
}

// Provider
final jobAlertsProvider =
    StateNotifierProvider<JobAlertsNotifier, List<JobAlert>>((ref) {
  return JobAlertsNotifier();
});
