import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../providers/booking_provider.dart';

class SelectDateTimePage extends ConsumerStatefulWidget {
  final String serviceId;
  final double basePrice;

  const SelectDateTimePage({
    super.key,
    required this.serviceId,
    required this.basePrice,
  });

  @override
  ConsumerState<SelectDateTimePage> createState() => _SelectDateTimePageState();
}

class _SelectDateTimePageState extends ConsumerState<SelectDateTimePage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDate;
  String? _selectedTime;
  double _selectedDuration = 2.0;

  final List<String> _timeSlots = [
    '9:00 am', '9:30 am', '10:00 am', '10:30 am',
    '11:00 am', '11:30 am', '12:00 pm', '12:30 pm',
    '1:00 pm', '1:30 pm', '2:00 pm', '2:30 pm',
    '3:00 pm', '3:30 pm', '4:00 pm', '4:30 pm',
    '5:00 pm', '5:30 pm', '6:00 pm'
  ];

  final List<double> _durations = [1.0, 2.0, 3.0, 4.0];

  @override
  void initState() {
    super.initState();
    // Set service in booking state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(bookingProvider.notifier).setService(
        widget.serviceId,
        widget.basePrice * _selectedDuration,
        duration: _selectedDuration,
      );
    });
  }

  double get _totalAmount => widget.basePrice * _selectedDuration;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: isDark
          ? const Color(0xFF101922).withOpacity(0.8)
          : const Color(0xFFF6F7F8).withOpacity(0.8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Select Date & Time',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                  Text(
                    'Date',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 90)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
                      onDaySelected: (selectedDay, focusedDay) {
                        if (selectedDay.isAfter(DateTime.now().subtract(const Duration(days: 1)))) {
                          setState(() {
                            _selectedDate = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        }
                      },
                      calendarFormat: CalendarFormat.month,
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.grey[900],
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      calendarStyle: CalendarStyle(
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF1173D4),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: const Color(0xFF1173D4).withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        defaultTextStyle: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        weekendTextStyle: TextStyle(
                          color: isDark ? Colors.grey[300] : Colors.grey[700],
                        ),
                        outsideTextStyle: TextStyle(
                          color: isDark ? Colors.grey[600] : Colors.grey[400],
                        ),
                      ),
                      daysOfWeekStyle: DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                        weekendStyle: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[500] : Colors.grey[400],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Time Section
                  Text(
                    'Time',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _timeSlots.length,
                    itemBuilder: (context, index) {
                      final timeSlot = _timeSlots[index];
                      final isSelected = _selectedTime == timeSlot;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedTime = timeSlot;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                              ? const Color(0xFF1173D4)
                              : (isDark ? Colors.grey[800] : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            timeSlot,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[300] : Colors.grey[700]),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // Duration Section
                  Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.grey[900],
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 2.5,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: _durations.length,
                    itemBuilder: (context, index) {
                      final duration = _durations[index];
                      final isSelected = _selectedDuration == duration;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDuration = duration;
                            // Update total amount in booking state
                            ref.read(bookingProvider.notifier).setService(
                              widget.serviceId,
                              _totalAmount,
                              duration: _selectedDuration,
                            );
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                              ? const Color(0xFF1173D4)
                              : (isDark ? Colors.grey[800] : Colors.white),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 5,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${duration.toInt()} ${duration == 1 ? 'hour' : 'hours'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                ? Colors.white
                                : (isDark ? Colors.grey[300] : Colors.grey[700]),
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

          // Bottom Bar with Continue Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
              border: Border(
                top: BorderSide(
                  color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
                ),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: (_selectedDate != null && _selectedTime != null)
                    ? () {
                        print('=== CONTINUE BUTTON PRESSED ===');
                        print('Selected Date: $_selectedDate');
                        print('Selected Time: $_selectedTime');
                        print('Selected Duration: $_selectedDuration');

                        try {
                          // Parse time manually (e.g., "9:30 am")
                          print('Parsing time manually');
                          final timeParts = _selectedTime!.split(' ');
                          final hourMinute = timeParts[0].split(':');
                          int hour = int.parse(hourMinute[0]);
                          final minute = int.parse(hourMinute[1]);
                          final isPM = timeParts[1].toLowerCase() == 'pm';

                          // Convert to 24-hour format
                          if (isPM && hour != 12) {
                            hour += 12;
                          } else if (!isPM && hour == 12) {
                            hour = 0;
                          }
                          print('Parsed hour: $hour, minute: $minute');

                          final selectedDateTime = DateTime(
                            _selectedDate!.year,
                            _selectedDate!.month,
                            _selectedDate!.day,
                            hour,
                            minute,
                          );
                          print('Combined DateTime: $selectedDateTime');

                          // Save to booking state
                          print('Saving to booking state...');
                          ref.read(bookingProvider.notifier).setDateTime(
                            selectedDateTime,
                            _selectedTime!,
                            duration: _selectedDuration,
                          );
                          print('Saved to booking state');

                          // Navigate to address selection
                          print('Navigating to /booking/select-address');
                          context.push('/booking/select-address');
                          print('Navigation called');
                        } catch (e, stackTrace) {
                          print('ERROR: $e');
                          print('STACK TRACE: $stackTrace');
                        }
                      }
                    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1173D4),
                    disabledBackgroundColor: Colors.grey[400],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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
