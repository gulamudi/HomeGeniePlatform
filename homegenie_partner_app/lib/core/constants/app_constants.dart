class AppConstants {
  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeOtp = '/otp';
  static const String routeOnboarding = '/onboarding';
  static const String routeDocumentVerification = '/document-verification';
  static const String routeProfileSetup = '/profile-setup';
  static const String routeHome = '/home';
  static const String routeJobDetails = '/job-details';
  static const String routeJobStarted = '/job-started';
  static const String routeJobCompleted = '/job-completed';
  static const String routeCancelJob = '/cancel-job';
  static const String routeProfile = '/profile';
  static const String routeJobHistory = '/job-history';
  static const String routeSupport = '/support';
  static const String routePaymentGuide = '/payment-guide';

  // Job Status - these match the database enum values
  static const String jobStatusPending = 'pending';
  static const String jobStatusConfirmed = 'confirmed';  // Used for accepted jobs
  static const String jobStatusInProgress = 'in_progress';
  static const String jobStatusCompleted = 'completed';
  static const String jobStatusCancelled = 'cancelled';
  static const String jobStatusNoShow = 'no_show';
  static const String jobStatusDisputed = 'disputed';

  // Job Actions
  static const String actionAccept = 'accept';
  static const String actionReject = 'reject';
  static const String actionStart = 'start';
  static const String actionComplete = 'complete';
  static const String actionCancel = 'cancel';

  // Verification Status
  static const String verificationPending = 'pending';
  static const String verificationApproved = 'approved';
  static const String verificationRejected = 'rejected';

  // Document Types
  static const String docTypeAadhar = 'aadhar';
  static const String docTypePan = 'pan';
  static const String docTypePoliceVerification = 'police_verification';

  // Storage Keys
  static const String keyAccessToken = 'access_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyPartnerId = 'partner_id';
  static const String keyPartnerPhone = 'partner_phone';
  static const String keyIsOnboarded = 'is_onboarded';

  // Job Tabs
  static const String tabToday = 'today';
  static const String tabUpcoming = 'upcoming';
  static const String tabHistory = 'history';
  static const String tabAvailable = 'available';

  // Cancel Reasons
  static const List<String> cancelReasons = [
    'Customer not available',
    'Location too far',
    'Emergency came up',
    'Another booking conflict',
    'Health issues',
    'Other',
  ];
}
