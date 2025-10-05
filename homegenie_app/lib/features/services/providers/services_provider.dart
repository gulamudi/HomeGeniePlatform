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
      // Fallback to mock data for development
      print('\n⚠️  FALLING BACK TO MOCK DATA ⚠️');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Reason: Failed to fetch services from database');
      print('Error: $e');
      print('Impact: Showing mock/dummy services instead of real data');
      print('Action Required:');
      print('  1. Ensure Supabase is running (supabase start)');
      print('  2. Check database connection and migrations');
      print('  3. Verify edge functions are deployed');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    }

    // Mock services data
    state = [
    Service(
      id: '1',
      name: 'AC Repair & Service',
      description: 'Professional AC repair and maintenance services for all brands',
      category: 'Appliance Repair',
      base_price: 499.0,
      duration_hours: 1.5,
      is_active: true,
      requirements: ['Access to AC unit', 'Power supply'],
      includes: ['Inspection', 'Gas refilling', 'Cleaning', 'Testing'],
      excludes: ['Spare parts', 'Major repairs'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '2',
      name: 'Plumbing Services',
      description: 'Expert plumbing services for leaks, installations, and repairs',
      category: 'Plumbing',
      base_price: 349.0,
      duration_hours: 1.0,
      is_active: true,
      requirements: ['Access to plumbing area', 'Water supply control'],
      includes: ['Inspection', 'Basic repair', 'Testing'],
      excludes: ['Pipes and fittings', 'Major installations'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '3',
      name: 'Electrical Work',
      description: 'Certified electricians for all electrical installations and repairs',
      category: 'Electrical',
      base_price: 399.0,
      duration_hours: 1.0,
      is_active: true,
      requirements: ['Access to electrical panel', 'Safety clearance'],
      includes: ['Inspection', 'Wiring check', 'Installation', 'Testing'],
      excludes: ['Electrical fixtures', 'Heavy equipment'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '4',
      name: 'Home Cleaning',
      description: 'Comprehensive home cleaning services',
      category: 'Cleaning',
      base_price: 599.0,
      duration_hours: 3.0,
      is_active: true,
      requirements: ['Access to all rooms', 'Water supply'],
      includes: ['Dusting', 'Mopping', 'Bathroom cleaning', 'Kitchen cleaning'],
      excludes: ['Deep cleaning', 'Utensil cleaning'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '5',
      name: 'Painting Services',
      description: 'Professional painting services for interior and exterior',
      category: 'Painting',
      base_price: 2999.0,
      duration_hours: 8.0,
      is_active: true,
      requirements: ['Empty room', 'Surface preparation'],
      includes: ['Wall preparation', 'Painting', 'Cleanup'],
      excludes: ['Paint and materials', 'Furniture moving'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '6',
      name: 'Carpentry Work',
      description: 'Custom carpentry and furniture repair services',
      category: 'Carpentry',
      base_price: 799.0,
      duration_hours: 2.0,
      is_active: true,
      requirements: ['Work space', 'Access to area'],
      includes: ['Consultation', 'Basic repair', 'Installation'],
      excludes: ['Wood and materials', 'Custom furniture'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '7',
      name: 'Pest Control',
      description: 'Effective pest control solutions for all types of pests',
      category: 'Pest Control',
      base_price: 1299.0,
      duration_hours: 2.0,
      is_active: true,
      requirements: ['Empty house for 4 hours', 'No pets during service'],
      includes: ['Inspection', 'Treatment', 'Follow-up consultation'],
      excludes: ['Multiple treatments', 'Guarantee'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
    Service(
      id: '8',
      name: 'Appliance Installation',
      description: 'Professional installation of home appliances',
      category: 'Installation',
      base_price: 449.0,
      duration_hours: 1.0,
      is_active: true,
      requirements: ['Appliance at location', 'Required connections'],
      includes: ['Installation', 'Testing', 'Basic setup'],
      excludes: ['Accessories', 'Modifications'],
      image_url: null,
      created_at: DateTime.now(),
      updated_at: DateTime.now(),
    ),
  ];
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
