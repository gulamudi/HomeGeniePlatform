import 'package:freezed_annotation/freezed_annotation.dart';

part 'partner_preferences.freezed.dart';
part 'partner_preferences.g.dart';

@freezed
class PartnerAvailability with _$PartnerAvailability {
  const factory PartnerAvailability({
    @Default([1, 2, 3, 4, 5, 6]) List<int> weekdays,
    required WorkingHours workingHours,
    @Default(true) bool isAvailable,
  }) = _PartnerAvailability;

  factory PartnerAvailability.fromJson(Map<String, dynamic> json) =>
      _$PartnerAvailabilityFromJson(json);
}

@freezed
class WorkingHours with _$WorkingHours {
  const factory WorkingHours({
    required String start,
    required String end,
  }) = _WorkingHours;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
}

@freezed
class JobPreferences with _$JobPreferences {
  const factory JobPreferences({
    @Default(10.0) double maxDistance,
    @Default([]) List<String> preferredAreas,
    @Default([]) List<String> preferredServices,
    @Default(0.0) double minJobValue,
    @Default(false) bool autoAccept,
  }) = _JobPreferences;

  factory JobPreferences.fromJson(Map<String, dynamic> json) =>
      _$JobPreferencesFromJson(json);
}

@freezed
class PartnerPreferences with _$PartnerPreferences {
  const factory PartnerPreferences({
    @Default([]) List<String> services,
    PartnerAvailability? availability,
    JobPreferences? jobPreferences,
  }) = _PartnerPreferences;

  factory PartnerPreferences.fromJson(Map<String, dynamic> json) =>
      _$PartnerPreferencesFromJson(json);
}

// Extension methods for PartnerPreferences
extension PartnerPreferencesX on PartnerPreferences {
  // Helper to get availability with defaults
  PartnerAvailability get safeAvailability => availability ?? const PartnerAvailability(
    weekdays: [1, 2, 3, 4, 5, 6],
    workingHours: WorkingHours(start: '08:00', end: '18:00'),
    isAvailable: true,
  );

  // Helper to get job preferences with defaults
  JobPreferences get safeJobPreferences => jobPreferences ?? const JobPreferences();

  // Helper to convert to API format
  Map<String, dynamic> toApiJson() {
    return {
      'services': services,
      'availability': safeAvailability.toJson(),
      'jobPreferences': safeJobPreferences.toJson(),
    };
  }
}

/// Available service categories (should match database enum)
enum ServiceCategory {
  cleaning,
  plumbing,
  electrical,
  gardening,
  handyman,
  beauty,
  @JsonValue('appliance_repair')
  applianceRepair,
  painting,
  @JsonValue('pest_control')
  pestControl,
  @JsonValue('home_security')
  homeSecurity;

  String get displayName {
    switch (this) {
      case ServiceCategory.cleaning:
        return 'Cleaning';
      case ServiceCategory.plumbing:
        return 'Plumbing';
      case ServiceCategory.electrical:
        return 'Electrical';
      case ServiceCategory.gardening:
        return 'Gardening';
      case ServiceCategory.handyman:
        return 'Handyman';
      case ServiceCategory.beauty:
        return 'Beauty & Wellness';
      case ServiceCategory.applianceRepair:
        return 'Appliance Repair';
      case ServiceCategory.painting:
        return 'Painting';
      case ServiceCategory.pestControl:
        return 'Pest Control';
      case ServiceCategory.homeSecurity:
        return 'Home Security';
    }
  }

  String get value {
    switch (this) {
      case ServiceCategory.applianceRepair:
        return 'appliance_repair';
      case ServiceCategory.pestControl:
        return 'pest_control';
      case ServiceCategory.homeSecurity:
        return 'home_security';
      default:
        return name;
    }
  }

  static ServiceCategory fromString(String value) {
    switch (value) {
      case 'appliance_repair':
        return ServiceCategory.applianceRepair;
      case 'pest_control':
        return ServiceCategory.pestControl;
      case 'home_security':
        return ServiceCategory.homeSecurity;
      default:
        return ServiceCategory.values.firstWhere(
          (e) => e.name == value,
          orElse: () => ServiceCategory.cleaning,
        );
    }
  }
}

/// Days of the week (1 = Monday, 7 = Sunday)
enum Weekday {
  monday(1, 'Mon'),
  tuesday(2, 'Tue'),
  wednesday(3, 'Wed'),
  thursday(4, 'Thu'),
  friday(5, 'Fri'),
  saturday(6, 'Sat'),
  sunday(7, 'Sun');

  const Weekday(this.value, this.shortName);
  final int value;
  final String shortName;

  static Weekday fromValue(int value) {
    return Weekday.values.firstWhere((e) => e.value == value);
  }
}
