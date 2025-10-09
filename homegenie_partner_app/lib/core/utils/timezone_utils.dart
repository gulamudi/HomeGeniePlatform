import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Timezone utility for handling India timezone (IST) and UTC conversions
///
/// IMPORTANT:
/// - Booking times are ALWAYS in IST (Asia/Kolkata) timezone
/// - Created/Updated timestamps are stored in UTC and displayed in device local time
class TimezoneUtils {
  static bool _initialized = false;

  /// Initialize timezone database (call this once in main.dart)
  static void initialize() {
    if (!_initialized) {
      tz.initializeTimeZones();
      _initialized = true;
    }
  }

  /// App timezone for bookings (India Standard Time)
  static const String appTimezone = 'Asia/Kolkata';

  /// Get IST timezone location
  static tz.Location get istLocation => tz.getLocation(appTimezone);

  /// Convert a local DateTime to IST, then to UTC for storage
  ///
  /// Example: User selects "2:00 PM" on 2024-10-15
  /// - Creates DateTime(2024, 10, 15, 14, 0) in local time
  /// - This function interprets it as IST: 2024-10-15 14:00 IST
  /// - Converts to UTC: 2024-10-15 08:30 UTC
  ///
  /// This ensures booking times are ALWAYS interpreted as India time
  static DateTime convertBookingTimeToUtc(DateTime localDateTime) {
    initialize();

    // Create a TZDateTime in IST timezone with the same date/time values
    final istDateTime = tz.TZDateTime(
      istLocation,
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
      localDateTime.hour,
      localDateTime.minute,
      localDateTime.second,
    );

    // Convert to UTC
    return istDateTime.toUtc();
  }

  /// Convert UTC booking time to IST for display
  ///
  /// Example: Database has "2024-10-15 08:30 UTC"
  /// - Converts to IST: 2024-10-15 14:00 IST
  /// - Returns DateTime object representing that moment
  static DateTime convertUtcToBookingTime(DateTime utcDateTime) {
    initialize();

    // Convert UTC to IST
    final istDateTime = tz.TZDateTime.from(utcDateTime, istLocation);

    // Return as local DateTime (keeps the IST values but as local DateTime)
    return DateTime(
      istDateTime.year,
      istDateTime.month,
      istDateTime.day,
      istDateTime.hour,
      istDateTime.minute,
      istDateTime.second,
    );
  }

  /// Convert UTC timestamp to device local time for display
  ///
  /// Use this for created_at, updated_at timestamps
  /// Example: Database has "2024-10-15 08:30 UTC"
  /// - If device is in IST: Shows as 2024-10-15 14:00
  /// - If device is in EST: Shows as 2024-10-15 04:30
  static DateTime convertUtcToLocalTime(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Format booking time with IST indicator
  /// Example: "Oct 15, 2024 at 2:00 PM IST"
  static String formatBookingTime(DateTime utcDateTime, {String pattern = 'MMM dd, yyyy \'at\' h:mm a'}) {
    initialize();
    final istDateTime = tz.TZDateTime.from(utcDateTime, istLocation);

    // You can use intl package for formatting if needed
    // For now, return a simple formatted string
    return '${_formatDateTime(istDateTime)} IST';
  }

  /// Format local timestamp for display
  /// Example: "Oct 15, 2024 at 2:00 PM" (in device timezone)
  static String formatLocalTime(DateTime utcDateTime, {String pattern = 'MMM dd, yyyy \'at\' h:mm a'}) {
    final localDateTime = utcDateTime.toLocal();
    return _formatDateTime(localDateTime);
  }

  /// Helper function to format DateTime
  static String _formatDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final year = dateTime.year;

    int hour = dateTime.hour;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final amPm = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) hour -= 12;
    if (hour == 0) hour = 12;

    return '$month $day, $year at $hour:$minute $amPm';
  }

  /// Get IST timezone offset string (e.g., "+05:30")
  static String getISTOffset() {
    return '+05:30';
  }

  /// Check if a DateTime is in the past (compared to current IST time)
  static bool isInPast(DateTime utcDateTime) {
    initialize();
    final istNow = tz.TZDateTime.now(istLocation);
    final istDateTime = tz.TZDateTime.from(utcDateTime, istLocation);
    return istDateTime.isBefore(istNow);
  }

  /// Get current time in IST
  static DateTime getCurrentISTTime() {
    initialize();
    return tz.TZDateTime.now(istLocation);
  }
}
