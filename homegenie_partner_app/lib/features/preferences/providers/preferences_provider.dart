import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/partner_preferences.dart';
import '../../../core/models/service_area.dart';
import '../../../core/services/preferences_service.dart';
import '../../../core/network/api_client.dart';

// Service provider
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  final apiClient = ApiClient();
  return PreferencesService(apiClient);
});

// Partner preferences state provider
final partnerPreferencesProvider =
    StateNotifierProvider<PartnerPreferencesNotifier, AsyncValue<PartnerPreferences>>(
  (ref) => PartnerPreferencesNotifier(ref.watch(preferencesServiceProvider)),
);

class PartnerPreferencesNotifier
    extends StateNotifier<AsyncValue<PartnerPreferences>> {
  final PreferencesService _preferencesService;

  PartnerPreferencesNotifier(this._preferencesService)
      : super(const AsyncValue.loading()) {
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    state = const AsyncValue.loading();
    try {
      final preferences = await _preferencesService.getPreferences();
      state = AsyncValue.data(preferences);
    } catch (error, stackTrace) {
      print('Error loading preferences: $error');
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updatePreferences(PartnerPreferences preferences) async {
    try {
      state = const AsyncValue.loading();
      final updated = await _preferencesService.updatePreferences(preferences);
      state = AsyncValue.data(updated);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow;
    }
  }

  Future<void> updateServices(List<String> services) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(services: services);
    await updatePreferences(updated);
  }

  Future<void> updateAvailability(PartnerAvailability availability) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(availability: availability);
    await updatePreferences(updated);
  }

  Future<void> updateJobPreferences(JobPreferences jobPreferences) async {
    final current = state.value;
    if (current == null) return;

    final updated = current.copyWith(jobPreferences: jobPreferences);
    await updatePreferences(updated);
  }
}

// Service areas provider
final serviceAreasProvider =
    FutureProvider.family<ServiceAreasResponse, String?>((ref, city) async {
  final service = ref.watch(preferencesServiceProvider);
  return service.getServiceAreas(city: city);
});

// Helper provider to check if setup is complete
final setupCompletedProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(preferencesServiceProvider);
  return service.hasCompletedSetup();
});
