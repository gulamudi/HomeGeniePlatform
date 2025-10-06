/// Global application configuration
/// This file controls feature flags and environment settings
class AppConfig {
  // Environment
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'development',
  );

  static bool get isDevelopment => environment == 'development';
  static bool get isProduction => environment == 'production';

  // API Configuration
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://127.0.0.1:54321',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
  );

  // Feature Flags

  /// Set to false to bypass OTP verification during development/testing
  /// When false, any OTP will be accepted
  static const bool enableOtpVerification = false; // Set to true for production

  /// Default OTP for testing (only used when enableOtpVerification = false)
  static const String testOtp = '123456';

  /// Enable real-time notifications
  static const bool enableNotifications = true;

  /// Enable location services
  static const bool enableLocationServices = true;

  /// Enable payment integration
  static const bool enablePayments = false; // Set to true when payment gateway is configured

  /// Enable analytics
  static const bool enableAnalytics = false;

  // App Constants
  static const String appName = 'HomeGenie';
  static const String partnerAppName = 'HomeGenie Partner';

  // Timeouts
  static const int apiTimeoutSeconds = 30;
  static const int otpExpiryMinutes = 10;
  static const int sessionTimeoutMinutes = 60;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Booking
  static const int minBookingHoursAdvance = 2;
  static const int maxBookingDaysAdvance = 90;
  static const int cancellationWindowHours = 24;

  // Partner
  static const int jobAcceptanceTimeoutMinutes = 15;
  static const double partnerCommissionRate = 0.20; // 20%
  static const double minPayoutAmount = 100.0;

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxAddressLength = 500;

  // File Upload
  static const int maxImageSizeMB = 5;
  static const int maxDocumentSizeMB = 10;
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png'];
  static const List<String> allowedDocumentTypes = ['pdf', 'jpg', 'jpeg', 'png'];
}
