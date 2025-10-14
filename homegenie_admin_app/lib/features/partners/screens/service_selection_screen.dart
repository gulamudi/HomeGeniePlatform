import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/admin_api_service.dart';
import '../providers/partners_provider.dart';

class ServiceSelectionScreen extends ConsumerStatefulWidget {
  final String partnerId;

  const ServiceSelectionScreen({
    super.key,
    required this.partnerId,
  });

  @override
  ConsumerState<ServiceSelectionScreen> createState() =>
      _ServiceSelectionScreenState();
}

class _ServiceSelectionScreenState
    extends ConsumerState<ServiceSelectionScreen> {
  final Set<String> _selectedServiceIds = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentServices();
  }

  Future<void> _loadCurrentServices() async {
    try {
      final partner =
          await ref.read(adminApiServiceProvider).getPartnerById(widget.partnerId);
      if (partner != null) {
        final profile = partner['partner_profiles'] as Map<String, dynamic>?;
        final services = profile?['services'] as List<dynamic>?;
        if (services != null) {
          setState(() {
            _selectedServiceIds.addAll(services.map((s) => s.toString()));
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading services: $e')),
        );
      }
    }
  }

  Future<void> _saveServices() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(adminApiServiceProvider).updatePartnerServices(
            partnerId: widget.partnerId,
            services: _selectedServiceIds.toList(),
          );

      if (!mounted) return;

      // Invalidate the partner details to refresh the data
      ref.invalidate(partnerDetailsProvider(widget.partnerId));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Services updated successfully')),
      );
      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(_servicesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F8F7),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0D1C17)),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Select Services',
          style: TextStyle(
            color: Color(0xFF0D1C17),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : servicesAsync.when(
              data: (services) {
                if (services.isEmpty) {
                  return const Center(child: Text('No services available'));
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Select the services this partner can provide',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: services.length,
                        itemBuilder: (context, index) {
                          final service = services[index];
                          final serviceId = service['id'].toString();
                          final serviceName = service['name'] ?? 'Unknown';
                          final serviceCategory = service['service_category'] ?? '';
                          final isSelected =
                              _selectedServiceIds.contains(serviceId);

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isSelected
                                    ? const Color(0xFF04AE73)
                                    : Colors.grey[300]!,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: CheckboxListTile(
                              value: isSelected,
                              onChanged: (bool? value) {
                                setState(() {
                                  if (value == true) {
                                    _selectedServiceIds.add(serviceId);
                                  } else {
                                    _selectedServiceIds.remove(serviceId);
                                  }
                                });
                              },
                              title: Text(
                                serviceName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                serviceCategory,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              activeColor: const Color(0xFF04AE73),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (error, stack) =>
                  Center(child: Text('Error: $error')),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F8F7),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isSaving ? null : _saveServices,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF04AE73),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _isSaving
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  'Save (${_selectedServiceIds.length} selected)',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

// Provider for services
final _servicesProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final apiService = ref.watch(adminApiServiceProvider);
  return await apiService.getServices();
});
