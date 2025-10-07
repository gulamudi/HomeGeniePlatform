/// Global application configuration
/// This file controls feature flags and environment settings
///
/// 🔧 TO SWITCH ENVIRONMENT: Change the value of [currentEnvironment] below
enum Environment { local, production }

class EnvironmentConfig {
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String functionsBaseUrl;

  const EnvironmentConfig({
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    required this.functionsBaseUrl,
  });
}

class AppConfig {
  // ==========================================
  // 🔧 CHANGE THIS TO SWITCH ENVIRONMENT
  // ==========================================
  static const Environment currentEnvironment = Environment.production;
  // ==========================================

  // Environment configurations
  static const Map<Environment, EnvironmentConfig> _configs = {
    Environment.local: EnvironmentConfig(
      supabaseUrl: 'http://127.0.0.1:54321',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0',
      functionsBaseUrl: 'http://127.0.0.1:54321/functions/v1',
    ),
    Environment.production: EnvironmentConfig(
      // TODO: Replace with your production Supabase project details
      supabaseUrl: 'https://mxdxexbbrwjxbrdbrnzt.supabase.co',
      supabaseAnonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im14ZHhleGJicndqeGJyZGJybnp0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk3ODY3MzQsImV4cCI6MjA3NTM2MjczNH0.pMAsw0SBXDy_4u9om3wcsAMPYR03m5kbdg-9bosErkI',
      functionsBaseUrl: 'https://mxdxexbbrwjxbrdbrnzt.supabase.co/functions/v1',
    ),
  };

  // Get current configuration
  static EnvironmentConfig get _currentConfig => _configs[currentEnvironment]!;

  // Environment helpers
  static bool get isDevelopment => currentEnvironment == Environment.local;
  static bool get isProduction => currentEnvironment == Environment.production;
  static String get environmentName => currentEnvironment.name;

  // API Configuration - dynamically retrieved based on current environment
  static String get supabaseUrl => _currentConfig.supabaseUrl;
  static String get supabaseAnonKey => _currentConfig.supabaseAnonKey;
  static String get functionsBaseUrl => _currentConfig.functionsBaseUrl;

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
