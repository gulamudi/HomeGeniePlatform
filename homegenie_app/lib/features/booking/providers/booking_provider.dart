import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/booking.dart';
import '../../../core/models/address.dart';

// Booking State for creating a new booking
class BookingState {
  final String? serviceId;
  final DateTime? selectedDate;
  final String? selectedTimeSlot;
  final Address? selectedAddress;
  final String? paymentMethod;
  final String? specialInstructions;
  final double? totalAmount;

  const BookingState({
    this.serviceId,
    this.selectedDate,
    this.selectedTimeSlot,
    this.selectedAddress,
    this.paymentMethod,
    this.specialInstructions,
    this.totalAmount,
  });

  BookingState copyWith({
    String? serviceId,
    DateTime? selectedDate,
    String? selectedTimeSlot,
    Address? selectedAddress,
    String? paymentMethod,
    String? specialInstructions,
    double? totalAmount,
  }) {
    return BookingState(
      serviceId: serviceId ?? this.serviceId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTimeSlot: selectedTimeSlot ?? this.selectedTimeSlot,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  void reset() {
    // Reset all fields
  }
}

class BookingNotifier extends StateNotifier<BookingState> {
  BookingNotifier() : super(const BookingState());

  void setService(String serviceId, double amount) {
    state = state.copyWith(
      serviceId: serviceId,
      totalAmount: amount,
    );
  }

  void setDateTime(DateTime date, String timeSlot) {
    state = state.copyWith(
      selectedDate: date,
      selectedTimeSlot: timeSlot,
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

  Future<String?> createBooking() async {
    // In a real app, this would call the API to create booking
    // For now, return a mock booking ID
    await Future.delayed(const Duration(seconds: 1));
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  void reset() {
    state = const BookingState();
  }
}

// Bookings List Provider (mock data)
class BookingsNotifier extends StateNotifier<List<Booking>> {
  BookingsNotifier() : super([]);

  void loadBookings() {
    // Mock bookings data
    state = [
      Booking(
        id: '1',
        customer_id: 'customer1',
        service_id: '1',
        status: 'upcoming',
        scheduled_date: DateTime.now().add(const Duration(days: 2)),
        duration_hours: 1.5,
        address: {
          'flat_house_no': '101',
          'street_name': 'MG Road',
          'area': 'Whitefield',
          'city': 'Bangalore',
          'pin_code': '560066',
        },
        total_amount: 499.0,
        payment_method: 'online',
        payment_status: 'paid',
        created_at: DateTime.now().subtract(const Duration(days: 1)),
        updated_at: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Booking(
        id: '2',
        customer_id: 'customer1',
        service_id: '2',
        status: 'completed',
        scheduled_date: DateTime.now().subtract(const Duration(days: 5)),
        duration_hours: 1.0,
        address: {
          'flat_house_no': '101',
          'street_name': 'MG Road',
          'area': 'Whitefield',
          'city': 'Bangalore',
          'pin_code': '560066',
        },
        total_amount: 349.0,
        payment_method: 'cash',
        payment_status: 'paid',
        created_at: DateTime.now().subtract(const Duration(days: 6)),
        updated_at: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Booking(
        id: '3',
        customer_id: 'customer1',
        service_id: '4',
        status: 'upcoming',
        scheduled_date: DateTime.now().add(const Duration(days: 5)),
        duration_hours: 3.0,
        address: {
          'flat_house_no': '101',
          'street_name': 'MG Road',
          'area': 'Whitefield',
          'city': 'Bangalore',
          'pin_code': '560066',
        },
        total_amount: 599.0,
        payment_method: 'online',
        payment_status: 'paid',
        created_at: DateTime.now().subtract(const Duration(hours: 12)),
        updated_at: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ];
  }

  Future<void> cancelBooking(String bookingId) async {
    // Mock API call
    await Future.delayed(const Duration(seconds: 1));
    state = state.map((booking) {
      if (booking.id == bookingId) {
        return Booking(
          id: booking.id,
          customer_id: booking.customer_id,
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
        );
      }
      return booking;
    }).toList();
  }
}

// Providers
final bookingProvider = StateNotifierProvider<BookingNotifier, BookingState>((ref) {
  return BookingNotifier();
});

final bookingsProvider = StateNotifierProvider<BookingsNotifier, List<Booking>>((ref) {
  final notifier = BookingsNotifier();
  notifier.loadBookings();
  return notifier;
});

final upcomingBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == 'upcoming' || b.status == 'confirmed').toList();
});

final pastBookingsProvider = Provider<List<Booking>>((ref) {
  final bookings = ref.watch(bookingsProvider);
  return bookings.where((b) => b.status == 'completed' || b.status == 'cancelled').toList();
});

final bookingByIdProvider = Provider.family<Booking?, String>((ref, id) {
  final bookings = ref.watch(bookingsProvider);
  try {
    return bookings.firstWhere((b) => b.id == id);
  } catch (e) {
    return null;
  }
});
