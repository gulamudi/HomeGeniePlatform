import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/address.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';
import '../../../core/utils/timezone_utils.dart';

// Booking State for creating a new booking
class BookingState {
  final String? serviceId;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final double? durationHours;
  final Address? selectedAddress;
  final String? paymentMethod;
  final String? specialInstructions;
  final double? totalAmount;
  final String? preferredPartnerId;

  const BookingState({
    this.serviceId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.durationHours,
    this.selectedAddress,
    this.paymentMethod,
    this.specialInstructions,
    this.totalAmount,
    this.preferredPartnerId,
  });

  BookingState copyWith({
    String? serviceId,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    double? durationHours,
    Address? selectedAddress,
    String? paymentMethod,
    String? specialInstructions,
    double? totalAmount,
    String? preferredPartnerId,
  }) {
    return BookingState(
      serviceId: serviceId ?? this.serviceId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      durationHours: durationHours ?? this.durationHours,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      totalAmount: totalAmount ?? this.totalAmount,
      preferredPartnerId: preferredPartnerId ?? this.preferredPartnerId,
    );
  }

  void reset() {
    // Reset all fields
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  final ApiService _apiService;

  BookingNotifier(this._apiService) : super(const BookingState());

  void setService(String serviceId, double amount, {double? duration}) {
    state = state.copyWith(
      serviceId: serviceId,
      totalAmount: amount,
      durationHours: duration ?? state.durationHours,
    );
  }

  void setDateTime(DateTime date, String timeSlot, {double? duration}) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeSlot: timeSlot,
      durationHours: duration ?? state.durationHours,
    );
  }

  void setAddress(Address address) {
    state = state.copyWith(selectedAddress: address);
  }

  void setPaymentMethod(String method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setSpecialInstructions(String instructions) {
    state = state.copyWith(specialInstructions: instructions);
  }

  void setPreferredPartner(String? partnerId) {
    state = state.copyWith(preferredPartnerId: partnerId);
  }

  Future<String?> createBooking(WidgetRef ref) async {
    // Validate required fields
    if (state.serviceId == null ||
        state.selectedDate == null ||
        state.selectedTimeSlot == null ||
        state.selectedAddress == null) {
      throw Exception('Service, date, time, and address are required');
    }

    try {
      // Combine date and time into a single DateTime
      // Parse time slot format: "9:30 am" or "2:00 pm"
      final timeSlotParts = state.selectedTimeSlot!.split(' ');
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

      // Create DateTime with selected date and time
      final scheduledDateTime = DateTime(
        state.selectedDate!.year,
        state.selectedDate!.month,
        state.selectedDate!.day,
        hour,
        minute,
      );

      // IMPORTANT: Convert to UTC treating the time as IST (India timezone)
      // This ensures booking times are always in India timezone regardless of device timezone
      final scheduledDateTimeUtc = TimezoneUtils.convertBookingTimeToUtc(scheduledDateTime);

      // Prepare address data in camelCase format
      final addressData = state.selectedAddress != null
          ? {
              'id': state.selectedAddress!.id,
              'flatHouseNo': state.selectedAddress!.flat_house_no,
              'buildingApartmentName': state.selectedAddress!.building_apartment_name,
              'streetName': state.selectedAddress!.street_name,
              'landmark': state.selectedAddress!.landmark,
              'area': state.selectedAddress!.area,
              'city': state.selectedAddress!.city,
              'state': state.selectedAddress!.state,
              'pinCode': state.selectedAddress!.pin_code,
              'type': state.selectedAddress!.type,
              'isDefault': state.selectedAddress!.is_default,
            }
          : null;

      // Build request payload, excluding null values
      final Map<String, dynamic> requestData = {
        'serviceId': state.serviceId,
        'scheduledDate': scheduledDateTimeUtc.toIso8601String(),
        'durationHours': state.durationHours ?? 1.0, // Default to 1 hour if not set
        'address': addressData,
        'paymentMethod': state.paymentMethod ?? 'cash', // Default to cash if not set
      };

      // Add optional fields only if they have values
      if (state.specialInstructions != null && state.specialInstructions!.isNotEmpty) {
        requestData['specialInstructions'] = state.specialInstructions;
      }

      if (state.preferredPartnerId != null) {
        requestData['preferredPartnerId'] = state.preferredPartnerId;
      }

      print('📤 Creating booking with data: $requestData');

      final response = await _apiService.createBooking(requestData);

      if (response.success && response.data != null) {
        final bookingData = response.data as Map<String, dynamic>;

        // Parse the booking from response
        final newBooking = Booking.fromJson(bookingData);

        // Add to local state
        ref.read(bookingsProvider.notifier).addBooking(newBooking);

        print('✓ Booking created successfully: ${newBooking.id}');
        return newBooking.id;
      }

      throw Exception('Failed to create booking: ${response.error ?? 'Unknown error'}');
    } catch (e) {
      print('❌ Error creating booking: $e');
      rethrow;
    }
  }

  void reset() {
    state = const BookingState();
  }
}

// Bookings List Provider
class BookingsNotifier extends StateNotifier<List<Booking>> {
  final ApiService _apiService;

  BookingsNotifier(this._apiService) : super([]);

  Future<void> loadBookings() async {
    try {
      final response = await _apiService.getBookings(null, null, null, null, null);
      if (response.success && response.data != null) {
        // Handle the wrapped response structure: { bookings: [...], pagination: {...} }
        final responseData = response.data;
        final bookingsData = responseData is Map<String, dynamic>
            ? (responseData['bookings'] as List?) ?? []
            : (responseData as List? ?? []);

        final bookingsList = bookingsData
            .map((json) => Booking.fromJson(json as Map<String, dynamic>))
            .toList();
        state = bookingsList;
        print('✓ Successfully loaded ${bookingsList.length} bookings from database');
      } else {
        print('⚠️ Failed to load bookings: ${response.error ?? 'Unknown error'}');
        state = [];
      }
    } catch (e) {
      print('❌ Error loading bookings: $e');
      state = [];
    }
  }

  void addBooking(Booking booking) {
    state = [booking, ...state];
  }

  Future<void> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final response = await _apiService.cancelBooking(
        bookingId,
        {
          'bookingId': bookingId,
          'reason': reason ?? 'Customer requested cancellation',
        },
      );

      if (response.success) {
        print('✓ Successfully cancelled booking in database: $bookingId');
        state = state.map((booking) {
          if (booking.id == bookingId) {
            return Booking(
              id: booking.id,
              customer_id: booking.customer_id,
              partner_id: booking.partner_id,
              service_id: booking.service_id,
              status: 'cancelled',
              scheduled_date: booking.scheduled_date,
              duration_hours: booking.duration_hours,
              address: booking.address,
              total_amount: booking.total_amount,
              payment_method: booking.payment_method,
              payment_status: booking.payment_status,
              created_at: booking.created_at,
              updated_at: DateTime.now(),
              partner: booking.partner,
            );
          }
          return booking;
        }).toList();
      } else {
        throw Exception('Failed to cancel booking: ${response.error}');
      }
    } catch (e) {
      print('❌ Error cancelling booking: $e');
      rethrow;
    }
  }
}

// Providers
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return BookingNotifier(apiService);
});

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notifier = BookingsNotifier(apiService);
  notifier.loadBookings();
  return notifier;
});

final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == 'pending' || b.status == 'confirmed' || b.status == 'in_progress').toList();
});

final pastBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == 'completed' || b.status == 'cancelled' || b.status == 'no_show' || b.status == 'disputed').toList();
});

final bookingByIdProvider = Provider.family<Booking?, String>((ref, id) {
  final bookings = ref.watch(bookingsProvider);
  try {
    return bookings.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
});
