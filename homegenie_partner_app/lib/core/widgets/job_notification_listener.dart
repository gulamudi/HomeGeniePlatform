import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/jobs/screens/incoming_job_screen.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../router/app_router.dart';

/// Global widget that listens for new job notifications and shows incoming job screen
class JobNotificationListener extends ConsumerStatefulWidget {
  final Widget child;

  const JobNotificationListener({
    super.key,
    required this.child,
  });

  @override
  ConsumerState<JobNotificationListener> createState() =>
      _JobNotificationListenerState();
}

class _JobNotificationListenerState
    extends ConsumerState<JobNotificationListener> with WidgetsBindingObserver {
  bool _isListening = false;
  StreamSubscription<AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    print('📱 [JobNotificationListener] Widget initialized');
    WidgetsBinding.instance.addObserver(this);

    // Listen to auth state changes
    _authSubscription = SupabaseService.instance.client.auth.onAuthStateChange.listen((data) {
      print('📱 [JobNotificationListener] Auth state changed: ${data.event}');
      print('   User ID: ${data.session?.user.id}');

      if (data.event == AuthChangeEvent.signedIn) {
        print('📱 [JobNotificationListener] User signed in, starting subscription...');
        _isListening = false; // Reset to allow subscription
        _startListening();
      } else if (data.event == AuthChangeEvent.signedOut) {
        print('📱 [JobNotificationListener] User signed out, stopping subscription...');
        NotificationService.instance.unsubscribeFromJobAlerts();
        _isListening = false;
      }
    });

    // Also try immediately in case user is already logged in
    _startListening();
  }

  @override
  void dispose() {
    print('📱 [JobNotificationListener] Widget disposing');
    _authSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    NotificationService.instance.unsubscribeFromJobAlerts();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print('📱 [JobNotificationListener] App lifecycle changed: $state');
    // Resume listening when app comes to foreground
    if (state == AppLifecycleState.resumed && !_isListening) {
      print('📱 [JobNotificationListener] App resumed, restarting listening...');
      _startListening();
    }
  }

  void _startListening() {
    print('📱 [JobNotificationListener] _startListening called');

    final partnerId = SupabaseService.instance.currentUserId;
    print('📱 [JobNotificationListener] Current partner ID: $partnerId');

    if (partnerId == null) {
      print('⚠️ [JobNotificationListener] No user logged in, skipping subscription');
      return;
    }

    if (_isListening) {
      print('ℹ️ [JobNotificationListener] Already listening, skipping');
      return;
    }

    _isListening = true;
    print('✅ [JobNotificationListener] Starting job notification subscription...');

    // Subscribe to job notifications
    NotificationService.instance.subscribeToJobAlerts(
      partnerId: partnerId,
      onNewJob: (jobData) {
        print('📱 [JobNotificationListener] onNewJob callback triggered!');
        print('   Job data: $jobData');
        // Show full-screen incoming job UI
        _showIncomingJobScreen(jobData);
      },
    );
  }

  void _showIncomingJobScreen(Map<String, dynamic> jobData) {
    print('📱 [JobNotificationListener] _showIncomingJobScreen called');

    final navigatorState = AppRouter.navigatorKey.currentState;
    if (navigatorState == null) {
      print('⚠️ [JobNotificationListener] Navigator not available, cannot show screen');
      return;
    }

    print('✅ [JobNotificationListener] Navigating to IncomingJobScreen...');

    // Navigate to incoming job screen using global navigator key
    navigatorState.push(
      MaterialPageRoute(
        builder: (context) => IncomingJobScreen(jobData: jobData),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
