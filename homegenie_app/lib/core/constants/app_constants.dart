class AppConstants {
  // API Configuration
  static const String baseUrl = 'http://127.0.0.1:54321/functions/v1';
  static const String supabaseUrl = 'http://127.0.0.1:54321';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0';

  // App Info
  static const String appName = 'HomeGenie';
  static const String customerAppId = 'com.homegenie.customer';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String isFirstLaunchKey = 'is_first_launch';

  // Validation
  static const int otpLength = 6;
  static const int minNameLength = 2;
  static const int maxNameLength = 100;
  static const int maxDescriptionLength = 500;
  static const int pinCodeLength = 6;

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // UI Constants
  static const double defaultPadding = 16.0;
  static const double defaultRadius = 8.0;
  static const double defaultElevation = 2.0;

  // Colors
  static const int primaryColorValue = 0xFF2196F3;
  static const int secondaryColorValue = 0xFF03DAC6;
  static const int errorColorValue = 0xFFB00020;
  static const int successColorValue = 0xFF4CAF50;
  static const int warningColorValue = 0xFFFF9800;

  // Service Categories
  static const Map<String, String> serviceCategories = {
    'cleaning': 'House Cleaning',
    'plumbing': 'Plumbing',
    'electrical': 'Electrical',
    'gardening': 'Gardening',
    'handyman': 'Handyman',
    'beauty': 'Beauty & Wellness',
    'appliance_repair': 'Appliance Repair',
    'painting': 'Painting',
    'pest_control': 'Pest Control',
    'home_security': 'Home Security',
  };

  // Payment Methods
  static const Map<String, String> paymentMethods = {
    'cash': 'Cash',
    'card': 'Credit/Debit Card',
    'upi': 'UPI',
    'wallet': 'Digital Wallet',
    'net_banking': 'Net Banking',
  };

  // Booking Statuses
  static const Map<String, String> bookingStatuses = {
    'pending': 'Pending',
    'confirmed': 'Confirmed',
    'in_progress': 'In Progress',
    'completed': 'Completed',
    'cancelled': 'Cancelled',
    'no_show': 'No Show',
    'disputed': 'Disputed',
  };
}