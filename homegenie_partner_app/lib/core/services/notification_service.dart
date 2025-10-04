import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_service.dart';

class NotificationService {
  static NotificationService? _instance;
  static NotificationService get instance => _instance ??= NotificationService._();

  NotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  RealtimeChannel? _jobAlertsChannel;
  Function(Map<String, dynamic>)? _onNewJobCallback;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap
    // You can navigate to specific screens based on response.payload
    if (_onNewJobCallback != null && response.payload != null) {
      // Parse payload and call callback
    }
  }

  /// Subscribe to new job alerts
  void subscribeToJobAlerts({
    required String partnerId,
    required Function(Map<String, dynamic>) onNewJob,
  }) {
    _onNewJobCallback = onNewJob;

    _jobAlertsChannel = SupabaseService.instance.subscribeToNewBookings(
      onNewBooking: (booking) async {
        // Show notification
        await showJobNotification(booking);

        // Call callback
        onNewJob(booking);
      },
    );
  }

  /// Unsubscribe from job alerts
  Future<void> unsubscribeFromJobAlerts() async {
    if (_jobAlertsChannel != null) {
      await SupabaseService.instance.unsubscribe(_jobAlertsChannel!);
      _jobAlertsChannel = null;
    }
    _onNewJobCallback = null;
  }

  /// Show job notification
  Future<void> showJobNotification(Map<String, dynamic> booking) async {
    const androidDetails = AndroidNotificationDetails(
      'job_alerts',
      'Job Alerts',
      channelDescription: 'Notifications for new job opportunities',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New Job Available',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      playSound: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      booking['id'].hashCode,
      'New Job Available',
      '${booking['services']?['name'] ?? 'Service'} - ₹${booking['total_amount']}',
      details,
      payload: booking['id'],
    );
  }

  /// Show custom notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'general',
      'General',
      channelDescription: 'General notifications',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const iosDetails = DarwinNotificationDetails();

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details, payload: payload);
  }

  /// Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
