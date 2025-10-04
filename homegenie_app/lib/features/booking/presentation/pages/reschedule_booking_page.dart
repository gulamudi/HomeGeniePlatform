import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:table_calendar/table_calendar.dart';

class RescheduleBookingPage extends ConsumerStatefulWidget {
  final String bookingId;

  const RescheduleBookingPage({
    super.key,
    required this.bookingId,
  });

  @override
  ConsumerState<RescheduleBookingPage> createState() => _RescheduleBookingPageState();
}

class _RescheduleBookingPageState extends ConsumerState<RescheduleBookingPage> {
  DateTime _selectedDate = DateTime.now();
  DateTime _focusedDate = DateTime.now();
  String? _selectedTimeSlot;

  final List<String> _timeSlots = [
    '9:00 AM',
    '9:30 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM',
    '5:30 PM',
  ];

  final List<String> _unavailableSlots = ['10:30 AM', '2:00 PM', '4:30 PM'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Reschedule Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date Section
                  const Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDate,
                      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                          _focusedDate = focusedDay;
                        });
                      },
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: AppTheme.primaryBlue.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: AppTheme.primaryBlue,
                          shape: BoxShape.circle,
                        ),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Time Section
                  const Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 2.5,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final slot = _timeSlots[index];
                      final isUnavailable = _unavailableSlots.contains(slot);
                      final isSelected = _selectedTimeSlot == slot;

                      return InkWell(
                        onTap: isUnavailable
                            ? null
                            : () {
                                setState(() {
                                  _selectedTimeSlot = slot;
                                });
                              },
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isUnavailable
                                ? AppTheme.backgroundColor
                                : isSelected
                                    ? AppTheme.primaryBlue
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: isUnavailable
                                  ? AppTheme.borderColor
                                  : isSelected
                                      ? AppTheme.primaryBlue
                                      : AppTheme.borderColor,
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            slot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isUnavailable
                                  ? AppTheme.textHint
                                  : isSelected
                                      ? Colors.white
                                      : AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          // Bottom Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedTimeSlot == null
                      ? null
                      : () {
                          // TODO: Update booking
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Booking rescheduled successfully'),
                              backgroundColor: AppTheme.successGreen,
                            ),
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    disabledBackgroundColor: AppTheme.textHint,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Update Booking',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
