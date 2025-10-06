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
    print('🔔 [NotificationService] Initializing notification service...');

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

    print('✅ [NotificationService] Notification service initialized');
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

  /// Subscribe to new job alerts via Supabase Realtime
  void subscribeToJobAlerts({
    required String partnerId,
    required Function(Map<String, dynamic>) onNewJob,
  }) {
    print('🔔 [NotificationService] subscribeToJobAlerts called');
    print('   Partner ID: $partnerId');

    _onNewJobCallback = onNewJob;

    // Listen for notifications table inserts for this partner
    print('📡 [NotificationService] Setting up Supabase realtime subscription...');
    _jobAlertsChannel = SupabaseService.instance.subscribeToNotifications(
      partnerId: partnerId,
      onNotification: (notification) async {
        print('🔔 [NotificationService] onNotification callback triggered!');
        print('   Full notification object: $notification');

        // Check if this is a new job offer
        final data = notification['data'] as Map<String, dynamic>?;
        print('   Extracted data: $data');

        final action = data?['action'];
        print('   Action: $action');

        if (action == 'SHOW_JOB_OFFER') {
          print('✅ [NotificationService] Job offer detected! Showing notification...');

          // Show full-screen notification
          await showFullScreenJobNotification(data ?? {});

          // Call callback to trigger full-screen UI
          print('📱 [NotificationService] Triggering onNewJob callback...');
          onNewJob(data ?? {});
        } else {
          print('ℹ️ [NotificationService] Not a job offer notification (action: $action)');
        }
      },
    );

    print('✅ [NotificationService] Subscription setup complete');
  }

  /// Unsubscribe from job alerts
  Future<void> unsubscribeFromJobAlerts() async {
    print('🔕 [NotificationService] Unsubscribing from job alerts...');

    if (_jobAlertsChannel != null) {
      await SupabaseService.instance.unsubscribe(_jobAlertsChannel!);
      _jobAlertsChannel = null;
      print('✅ [NotificationService] Unsubscribed successfully');
    } else {
      print('ℹ️ [NotificationService] No active channel to unsubscribe from');
    }
    _onNewJobCallback = null;
  }

  /// Show full-screen job notification (incoming call style)
  Future<void> showFullScreenJobNotification(Map<String, dynamic> jobData) async {
    const androidDetails = AndroidNotificationDetails(
      'job_offers',
      'Job Offers',
      channelDescription: 'Incoming job offer notifications',
      importance: Importance.max,
      priority: Priority.max,
      ticker: 'New Job Opportunity',
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      playSound: true,
      fullScreenIntent: true, // This triggers full-screen intent
      category: AndroidNotificationCategory.call,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      sound: 'notification_sound.aiff',
      interruptionLevel: InterruptionLevel.critical,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final bookingId = jobData['booking_id'] ?? '';
    final serviceName = jobData['service_name'] ?? 'Service';
    final amount = jobData['amount']?.toString() ?? '0';

    await _notifications.show(
      bookingId.hashCode,
      'New Job Opportunity! 🔔',
      '$serviceName - \$$amount',
      details,
      payload: bookingId,
    );
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
