// lib/teacher/calendar_page.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/models/subject.dart';
import 'package:my_app/teacher/course_detail_page.dart';

class _CalTheme {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF9CA3AF);
  static const border = Color(0xFFA6CAFA);
}

class CalendarPage extends StatefulWidget {
  final String userId;
  final Map<DateTime, List<Subject>>? events;
  final DateTime? initialFocusedDay;
  final DateTime? initialSelectedDay;

  const CalendarPage({
    super.key,
    required this.userId,
    this.events,
    this.initialFocusedDay,
    this.initialSelectedDay,
  });

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay;

  // ถ้าไม่ส่ง events มาจากข้างนอก จะใช้ตัวนี้ (เริ่มว่าง)
  final Map<DateTime, List<Subject>> _events = {};

  DateTime _normalizeDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  List<Subject> _getItemsForDay(DateTime day) {
    final data = widget.events ?? _events;
    final key = _normalizeDay(day);
    return data[key] ?? data[DateTime(key.year, key.month, key.day)] ?? const <Subject>[];
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
    _selectedDay = widget.initialSelectedDay; // ยังไม่เลือกก็ได้ -> ไม่โชว์รายการ

    // TODO: โหลดคาบสอนจาก PHP ตาม widget.userId แล้ว map ลง _events จากนั้น setState
    // await _fetchTeachingEvents();
  }

  @override
  Widget build(BuildContext context) {
    final items = (_selectedDay != null) ? _getItemsForDay(_selectedDay!) : const <Subject>[];

    return Scaffold(
      appBar: const CustomAppBar(title: 'ปฏิทิน'),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== Calendar =====
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _CalTheme.border, width: 1.5),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  spreadRadius: 2,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TableCalendar<Subject>(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2035, 12, 31),
              focusedDay: _focusedDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getItemsForDay,     // ← ใช้อ่านอีเวนต์
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 12, color: _CalTheme.sub),
                weekendStyle: TextStyle(fontSize: 12, color: _CalTheme.sub),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(color: _CalTheme.ink, fontSize: 12),
                weekendTextStyle: const TextStyle(color: _CalTheme.ink, fontSize: 12),
                outsideDaysVisible: true,
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 232, 248),
                  border: Border.all(color: _CalTheme.primary, width: 1.5),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: const TextStyle(
                  color: _CalTheme.primary,
                  fontWeight: FontWeight.w700,
                ),
                selectedDecoration: const BoxDecoration(
                  color: _CalTheme.primary,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,
                markersMaxCount: 3,
                markerDecoration: const BoxDecoration(
                  color: _CalTheme.primary,
                  shape: BoxShape.circle,
                ),
                markerSizeScale: 0.12,
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
            ),
          ),

          const SizedBox(height: 16),

          // ===== รายวิชาที่สอนในวันนั้น =====
          if (_selectedDay == null)
            const SizedBox.shrink()
          else if (items.isEmpty)
            const Center(
              child: Text('ไม่มีคาบสอนในวันนี้', style: TextStyle(color: _CalTheme.sub, fontSize: 14)),
            )
          else
            ...items.map((s) => TextBox(
                  subject: s,
                  trailing: const Icon(Icons.chevron_right, color: Color(0xFF9CA3AF)),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(
                          courseName: s.title,
                          courseCode: s.code ?? '',
                        ),
                      ),
                    );
                  },
                )),
        ],
      ),
    );
  }
}
