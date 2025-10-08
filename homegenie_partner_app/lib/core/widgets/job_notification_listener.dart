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
  String? _currentlyShownBookingId;

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
      onJobDismissed: (bookingId) {
        print('📱 [JobNotificationListener] onJobDismissed callback triggered!');
        print('   Booking ID: $bookingId');
        print('   Currently shown booking: $_currentlyShownBookingId');

        // If the dismissed booking is currently being shown, dismiss the screen
        if (_currentlyShownBookingId == bookingId) {
          print('✅ [JobNotificationListener] Dismissing currently shown job screen');
          _dismissIncomingJobScreen();
        } else {
          print('ℹ️ [JobNotificationListener] Dismissed booking is not currently shown');
        }
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

    // Track the currently shown booking ID
    _currentlyShownBookingId = jobData['booking_id'];
    print('✅ [JobNotificationListener] Navigating to IncomingJobScreen...');
    print('   Tracking booking ID: $_currentlyShownBookingId');

    // Navigate to incoming job screen using global navigator key
    navigatorState.push(
      MaterialPageRoute(
        builder: (context) => IncomingJobScreen(jobData: jobData),
        fullscreenDialog: true,
      ),
    ).then((_) {
      // Clear tracking when screen is dismissed
      print('📱 [JobNotificationListener] IncomingJobScreen dismissed');
      _currentlyShownBookingId = null;
    });
  }

  void _dismissIncomingJobScreen() {
    print('📱 [JobNotificationListener] _dismissIncomingJobScreen called');

    final navigatorState = AppRouter.navigatorKey.currentState;
    if (navigatorState == null) {
      print('⚠️ [JobNotificationListener] Navigator not available');
      return;
    }

    print('✅ [JobNotificationListener] Popping IncomingJobScreen');
    _currentlyShownBookingId = null;
    navigatorState.pop();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
