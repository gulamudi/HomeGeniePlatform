import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/admin_api_service.dart';

final bookingsProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String?>((ref, status) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getBookings(status: status);
});

final bookingDetailsProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, bookingId) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getBookingById(bookingId);
});

// Provider for available partners with filters
final availablePartnersProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, PartnerFilters>((ref, filters) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getAvailablePartners(
    search: filters.search,
    verificationStatus: filters.verificationStatus,
    onlyVerified: filters.onlyVerified,
  );
});

// Filter class for available partners
class PartnerFilters {
  final String? search;
  final String? verificationStatus;
  final bool onlyVerified;

  const PartnerFilters({
    this.search,
    this.verificationStatus,
    this.onlyVerified = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PartnerFilters &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          verificationStatus == other.verificationStatus &&
          onlyVerified == other.onlyVerified;

  @override
  int get hashCode =>
      search.hashCode ^ verificationStatus.hashCode ^ onlyVerified.hashCode;
}
