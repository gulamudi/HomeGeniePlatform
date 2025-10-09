import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/partner.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';
import 'booking_provider.dart';

// Provider to fetch preferred partners based on current booking details
final preferredPartnersProvider = FutureProvider<List<Partner>>((ref) async {
  final bookingState = ref.watch(bookingProvider);
  final apiService = ref.watch(apiServiceProvider);

  // Check if we have the required booking details
  if (bookingState.serviceId == null ||
      bookingState.selectedDate == null ||
      bookingState.selectedTimeSlot == null ||
      bookingState.durationHours == null) {
    return [];
  }

  try {
    // Combine date and time into a single DateTime
    final timeSlotParts = bookingState.selectedTimeSlot!.split(' ');
    final timeParts = timeSlotParts[0].split(':');
    int hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Adjust hour based on AM/PM
    if (timeSlotParts.length > 1) {
      final isPM = timeSlotParts[1].toLowerCase() == 'pm';
      if (isPM && hour != 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }
    }

    final scheduledDateTime = DateTime(
      bookingState.selectedDate!.year,
      bookingState.selectedDate!.month,
      bookingState.selectedDate!.day,
      hour,
      minute,
    );

    final scheduledDateTimeUtc = scheduledDateTime.toUtc();

    final response = await apiService.getPreferredPartners(
      bookingState.serviceId!,
      scheduledDateTimeUtc.toIso8601String(),
      bookingState.durationHours!,
      3, // Limit to 3 preferred partners
    );

    if (response.success && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      final partnersData = data['partners'] as List<dynamic>? ?? [];

      return partnersData
          .map((json) => Partner.fromJson(json as Map<String, dynamic>))
          .toList();
    }

    return [];
  } catch (e) {
    print('❌ Error fetching preferred partners: $e');
    return [];
  }
});

// Provider to fetch featured partners (for now, same as preferred)
final featuredPartnersProvider = FutureProvider<List<Partner>>((ref) async {
  // For now, return the same as preferred partners
  // In the future, this could fetch top-rated partners
  final preferred = await ref.watch(preferredPartnersProvider.future);
  return preferred;
});
