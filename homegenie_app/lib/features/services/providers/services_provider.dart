import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/service.dart';

// Mock services data
final servicesProvider = Provider<List<Service>>((ref) {
  return [
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
