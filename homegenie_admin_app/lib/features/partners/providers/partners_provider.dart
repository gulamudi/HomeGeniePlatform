import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/admin_api_service.dart';

final partnersProvider =
    FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String?>((ref, search) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getPartners(search: search);
});

final partnerDetailsProvider =
    FutureProvider.autoDispose.family<Map<String, dynamic>?, String>((ref, partnerId) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getPartnerById(partnerId);
});
