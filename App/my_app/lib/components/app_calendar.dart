import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_app/components/app_calendar_theme.dart';

class AppCalendar<T> extends StatefulWidget {
  final Map<DateTime, List<T>> events;
  final DateTime? initialFocusedDay;
  final DateTime? initialSelectedDay;
  final ValueChanged<DateTime>? onDaySelected;

  /// ✅ เพิ่ม callback นี้
  final ValueChanged<DateTime>? onMonthChanged;

  const AppCalendar({
    super.key,
    required this.events,
    this.initialFocusedDay,
    this.initialSelectedDay,
    this.onDaySelected,
    this.onMonthChanged, // ✅
  });

  @override
  State<AppCalendar<T>> createState() => _AppCalendarState<T>();
}

class _AppCalendarState<T> extends State<AppCalendar<T>> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  /// normalize key (ตัดเวลาออก)
  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  List<T> _getEvents(DateTime day) {
    return widget.events[_key(day)] ?? <T>[];
  }

  bool _hasEvent(DateTime day) {
    return _getEvents(day).isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
    _selectedDay = widget.initialSelectedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF84A9EA), width: 1.5),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: TableCalendar<T>(
        firstDay: DateTime.utc(2022, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,

        selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
        eventLoader: _getEvents,
        startingDayOfWeek: StartingDayOfWeek.sunday,

        headerStyle: AppCalendarTheme.headerStyle,
        daysOfWeekStyle: AppCalendarTheme.daysOfWeekStyle,
        calendarStyle: AppCalendarTheme.calendarStyle,

        /// ⭐ จุดเล็กใต้วันที่มี event
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) {
            if (!_hasEvent(day)) return null;
            return Positioned(
              bottom: 4,
              child: Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 24, 58, 112),
                  shape: BoxShape.circle,
                ),
              ),
            );
          },
        ),

        onDaySelected: (selected, focused) {
          setState(() {
            _selectedDay = selected;
            _focusedDay = focused;
          });
          widget.onDaySelected?.call(selected);
        },

        /// ✅ ตรงนี้แหละที่เรียก fetchMonth
        onPageChanged: (focused) {
          _focusedDay = focused;
          widget.onMonthChanged?.call(focused);
        },
      ),
    );
  }
}
