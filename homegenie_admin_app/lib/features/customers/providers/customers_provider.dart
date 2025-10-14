import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/admin_api_service.dart';

final customersProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, search) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getCustomers(search: search);
});

final customerDetailsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, customerId) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getCustomerById(customerId);
});
