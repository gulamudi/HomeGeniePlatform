import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/service.dart';
import '../../../core/network/api_service.dart';
import '../../../core/providers/api_provider.dart';

// Services Notifier to fetch from API
class ServicesNotifier extends StateNotifier<List<Service>> {
  final ApiService _apiService;

  ServicesNotifier(this._apiService) : super([]);

  Future<void> loadServices({String? category, String? search}) async {
    try {
      final response = await _apiService.getServices(category, search, null, null);
      if (response.success && response.data != null) {
        // Handle the wrapped response structure: { services: [...], pagination: {...} }
        final responseData = response.data;
        final servicesData = responseData is Map<String, dynamic>
            ? (responseData['services'] as List?) ?? []
            : (responseData as List? ?? []);

        final servicesList = servicesData
            .map((json) => Service.fromJson(json as Map<String, dynamic>))
            .toList();
        state = servicesList;
        print('✓ Successfully loaded ${servicesList.length} services from database');
        return;
      }
    } catch (e) {
      // Show error message - no fallback to mock data
      print('\n❌ FAILED TO LOAD SERVICES FROM DATABASE ❌');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('Action Required:');
      print('  1. Ensure Supabase is running (supabase start)');
      print('  2. Check database connection and migrations');
      print('  3. Verify edge functions are deployed');
      print('  4. Run: supabase db reset to reset database with seed data');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      // Set empty state - force user to fix the database connection
      state = [];
      rethrow; // Propagate error to UI for proper error handling
    }
  }
}

// Providers
final servicesProvider = StateNotifierProvider<ServicesNotifier, List<Service>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  final notifier = ServicesNotifier(apiService);
  notifier.loadServices();
  return notifier;
});

final serviceByIdProvider = Provider.family<Service?, String>((ref, id) {
  final services = ref.watch(servicesProvider);
  try {
    return services.firstWhere((s) => s.id == id);
  } catch (e) {
    return null;
  }
});

final servicesByCategoryProvider = Provider<Map<String, List<Service>>>((ref) {
  final services = ref.watch(servicesProvider);
  final Map<String, List<Service>> categorized = {};

  for (var service in services) {
    if (!categorized.containsKey(service.category)) {
      categorized[service.category] = [];
    }
    categorized[service.category]!.add(service);
  }

  return categorized;
});
