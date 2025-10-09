import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/partner_preferences.dart';
import '../../../core/models/service_area.dart';
import '../../../main.dart';
import '../providers/preferences_provider.dart';

class PreferencesScreen extends ConsumerStatefulWidget {
  final bool isInitialSetup;

  const PreferencesScreen({
    Key? key,
    this.isInitialSetup = false,
  }) : super(key: key);

  @override
  ConsumerState<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends ConsumerState<PreferencesScreen> {
  // Local state for editing
  List<String> selectedServices = [];
  List<int> selectedWeekdays = [];
  TimeOfDay startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
  List<String> selectedAreas = [];
  bool isAvailable = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentPreferences();
    });
  }

  void _loadCurrentPreferences() {
    final prefsAsync = ref.read(partnerPreferencesProvider);
    prefsAsync.whenData((prefs) {
      setState(() {
        selectedServices = List.from(prefs.services ?? []);
        selectedWeekdays = List.from(prefs.availability?.weekdays ?? [1, 2, 3, 4, 5, 6]);
        isAvailable = prefs.availability?.isAvailable ?? true;
        selectedAreas = List.from(prefs.jobPreferences?.preferredAreas ?? []);

        // Parse start and end times
        try {
          final workingHours = prefs.availability?.workingHours;
          if (workingHours != null) {
            final startParts = workingHours.start.split(':');
            startTime = TimeOfDay(
              hour: int.parse(startParts[0]),
              minute: int.parse(startParts[1]),
            );

            final endParts = workingHours.end.split(':');
            endTime = TimeOfDay(
              hour: int.parse(endParts[0]),
              minute: int.parse(endParts[1]),
            );
          }
        } catch (e) {
          print('Error parsing time: $e');
        }
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
      final preferences = PartnerPreferences(
        services: selectedServices,
        availability: PartnerAvailability(
          weekdays: selectedWeekdays,
          workingHours: WorkingHours(
            start: '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
            end: '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
          ),
          isAvailable: isAvailable,
        ),
        jobPreferences: JobPreferences(
          preferredAreas: selectedAreas,
        ),
      );

      await ref.read(partnerPreferencesProvider.notifier).updatePreferences(preferences);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preferences saved successfully'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.isInitialSetup) {
          // Mark as onboarded and navigate to home
          // Import needed at top: import '../../../main.dart';
          final storage = ref.read(storageServiceProvider);
          await storage.setOnboarded(true);
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save preferences: $e'),
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
        title: Text(widget.isInitialSetup ? 'Set Up Your Profile' : 'Preferences'),
        automaticallyImplyLeading: !widget.isInitialSetup,
      ),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error loading preferences: $error'),
        ),
        data: (prefs) {
          // Handle case where preferences might be null or incomplete
          final services = prefs.services ?? [];
          final availability = prefs.availability ?? PartnerAvailability(
            weekdays: [1, 2, 3, 4, 5, 6],
            workingHours: WorkingHours(start: '08:00', end: '18:00'),
            isAvailable: true,
          );
          final jobPreferences = prefs.jobPreferences ?? JobPreferences();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isInitialSetup) ...[
                  const Text(
                    'Welcome! Let\'s set up your preferences',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This helps us match you with the right jobs',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                ],

                // Service Preferences
                _buildSectionHeader('Service Preferences'),
                const SizedBox(height: 8),
                const Text(
                  'Select the types of services you\'re interested in providing.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildServicesList(),

                const SizedBox(height: 24),

                // Availability
                _buildSectionHeader('Availability'),
                const SizedBox(height: 8),
                const Text(
                  'Set your general availability for accepting jobs.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                _buildAvailabilitySection(),

                const SizedBox(height: 24),

                // Preferred Locations
                _buildSectionHeader('Preferred Locations'),
                const SizedBox(height: 8),
                const Text(
                  'Select areas where you prefer to work.',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 12),
                serviceAreasAsync.when(
                  loading: () => const CircularProgressIndicator(),
                  error: (error, stack) => Text('Error: $error'),
                  data: (areas) => _buildLocationsList(areas),
                ),

                const SizedBox(height: 32),

                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: isSaving ? null : _savePreferences,
                    child: isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Save Preferences'),
                  ),
                ),

                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildServicesList() {
    return Column(
      children: ServiceCategory.values.map((category) {
        final isSelected = selectedServices.contains(category.value);
        return CheckboxListTile(
          title: Text(category.displayName),
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
        );
      }).toList(),
    );
  }

  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weekdays selection
        const Text('Weekdays', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: Weekday.values.map((day) {
            final isSelected = selectedWeekdays.contains(day.value);
            return FilterChip(
              label: Text(day.shortName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedWeekdays.add(day.value);
                    selectedWeekdays.sort();
                  } else {
                    selectedWeekdays.remove(day.value);
                  }
                });
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 16),

        // Working hours
        const Text('Working Hours', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: startTime,
                  );
                  if (time != null) {
                    setState(() => startTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Start'),
                      Text(
                        startTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Text('-'),
            ),
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: endTime,
                  );
                  if (time != null) {
                    setState(() => endTime = time);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('End'),
                      Text(
                        endTime.format(context),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLocationsList(ServiceAreasResponse areasResponse) {
    if (areasResponse.areas.isEmpty) {
      return const Text('No service areas available');
    }

    // Group by city
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: areasResponse.groupedByCity.entries.map((entry) {
        final city = entry.key;
        final areas = entry.value;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                city,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            ),
            ...areas.map((area) {
              final isSelected = selectedAreas.contains(area.id);
              return CheckboxListTile(
                title: Text(area.name),
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
              );
            }).toList(),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
}
