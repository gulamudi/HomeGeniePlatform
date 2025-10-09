import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/theme/app_theme.dart';
import '../../../core/models/partner_preferences.dart';
import '../../../core/models/service_area.dart';
import '../providers/preferences_provider.dart';

class ServicePreferencesScreen extends ConsumerStatefulWidget {
  const ServicePreferencesScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ServicePreferencesScreen> createState() =>
      _ServicePreferencesScreenState();
}

class _ServicePreferencesScreenState
    extends ConsumerState<ServicePreferencesScreen> {
  List<String> selectedServices = [];
  List<String> selectedAreas = [];
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPreferences();
    });
  }

  void _loadCurrentPreferences() {
    final prefsAsync = ref.read(partnerPreferencesProvider);
    prefsAsync.whenData((prefs) {
      setState(() {
        selectedServices = List.from(prefs.services);
        selectedAreas = List.from(prefs.safeJobPreferences.preferredAreas);
      });
    });
  }

  Future<void> _savePreferences() async {
    if (selectedServices.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one service'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    try {
      final currentPrefs = ref.read(partnerPreferencesProvider).value;
      if (currentPrefs == null) {
        throw Exception('Unable to load current preferences');
      }

      // Update services
      await ref
          .read(partnerPreferencesProvider.notifier)
          .updateServices(selectedServices);

      // Update job preferences with selected areas
      final updatedJobPrefs = currentPrefs.safeJobPreferences.copyWith(
        preferredAreas: selectedAreas,
      );
      await ref
          .read(partnerPreferencesProvider.notifier)
          .updateJobPreferences(updatedJobPrefs);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Service preferences updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefsAsync = ref.watch(partnerPreferencesProvider);
    final serviceAreasAsync = ref.watch(serviceAreasProvider(null));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Service and Building Preferences',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading preferences: $error'),
        ),
        data: (prefs) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Types Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Job Types',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Choose the services you want to provide',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildServicesList(),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Preferred Locations Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Preferred Locations',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Select areas where you prefer to work',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    serviceAreasAsync.when(
                      loading: () => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      error: (error, stack) => Text('Error: $error'),
                      data: (areas) => _buildLocationsList(areas),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _savePreferences,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList() {
    return Column(
      children: ServiceCategory.values.map((category) {
        final isSelected = selectedServices.contains(category.value);
        return CheckboxListTile(
          title: Text(
            category.displayName,
            style: const TextStyle(
              fontSize: 15,
              color: AppTheme.textPrimary,
            ),
          ),
          value: isSelected,
          onChanged: (value) {
            setState(() {
              if (value == true) {
                selectedServices.add(category.value);
              } else {
                selectedServices.remove(category.value);
              }
            });
          },
          controlAffinity: ListTileControlAffinity.trailing,
          contentPadding: EdgeInsets.zero,
          activeColor: AppTheme.primaryBlue,
        );
      }).toList(),
    );
  }

  Widget _buildLocationsList(ServiceAreasResponse areasResponse) {
    if (areasResponse.areas.isEmpty) {
      return const Text(
        'No service areas available',
        style: TextStyle(color: AppTheme.textSecondary),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: areasResponse.groupedByCity.entries.map((entry) {
        final city = entry.key;
        final areas = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (areasResponse.groupedByCity.length > 1) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  city,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
            ...areas.map((area) {
              final isSelected = selectedAreas.contains(area.id);
              return CheckboxListTile(
                title: Text(
                  area.name,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      selectedAreas.add(area.id);
                    } else {
                      selectedAreas.remove(area.id);
                    }
                  });
                },
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primaryBlue,
              );
            }).toList(),
            if (areasResponse.groupedByCity.length > 1)
              const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
