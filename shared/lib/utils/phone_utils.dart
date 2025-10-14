/// Phone number utilities for consistent formatting across the app
class PhoneUtils {
  /// Normalizes a phone number to E.164 format (+91XXXXXXXXXX)
  ///
  /// Examples:
  /// - "9999999999" -> "+919999999999"
  /// - "+919999999999" -> "+919999999999"
  /// - "919999999999" -> "+919999999999"
  /// - "+91 9999999999" -> "+919999999999"
  /// - "9999 999 999" -> "+919999999999"
  static String normalize(String phone, {String defaultCountryCode = '91'}) {
    if (phone.isEmpty) {
      throw ArgumentError('Phone number cannot be empty');
    }

    // Remove all whitespace, dashes, parentheses, and other formatting
    String cleaned = phone.replaceAll(RegExp(r'[\s\-\(\)\.]'), '');

    // Remove any leading zeros
    cleaned = cleaned.replaceFirst(RegExp(r'^0+'), '');

    // If it already has a +, remove it temporarily
    if (cleaned.startsWith('+')) {
      cleaned = cleaned.substring(1);
    }

    // If it starts with country code (e.g., 91), keep it as is
    // If it doesn't, add the default country code
    if (!cleaned.startsWith(defaultCountryCode)) {
      cleaned = '$defaultCountryCode$cleaned';
    }

    // Add the + prefix
    final normalized = '+$cleaned';

    // Validate the final format for Indian numbers
    // Should be +91 followed by 10 digits
    if (defaultCountryCode == '91') {
      final regex = RegExp(r'^\+91\d{10}$');
      if (!regex.hasMatch(normalized)) {
        throw ArgumentError(
          'Invalid Indian phone number format. Expected +91XXXXXXXXXX (10 digits after +91), got: $normalized'
        );
      }
    }

    return normalized;
  }

  /// Formats a phone number for display (e.g., +91 99999 99999)
  static String formatForDisplay(String phone) {
    final normalized = normalize(phone);

    // For Indian numbers: +91 XXXXX XXXXX
    if (normalized.startsWith('+91') && normalized.length == 13) {
      return '+91 ${normalized.substring(3, 8)} ${normalized.substring(8)}';
    }

    return normalized;
  }

  /// Validates if a phone number is valid
  static bool isValid(String phone) {
    try {
      normalize(phone);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Extracts just the digits (without country code) for display
  /// Example: "+919999999999" -> "9999999999"
  static String getDigitsOnly(String phone, {String countryCode = '91'}) {
    final normalized = normalize(phone);
    if (normalized.startsWith('+$countryCode')) {
      return normalized.substring(countryCode.length + 1);
    }
    return normalized.substring(1); // Remove just the +
  }
}
