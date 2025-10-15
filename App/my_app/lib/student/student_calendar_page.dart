// lib/pages/student_calendar_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:table_calendar/table_calendar.dart';

// ✅ ใช้ Subject จากโมเดลกลาง
import 'package:my_app/models/subject.dart';

// ✅ นำเข้าหน้า detail ปกติ (ห้ามประกาศ Subject ในไฟล์นั้น)
import 'package:my_app/student/subject_detail_page.dart';

class _CalTheme {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF9CA3AF);
  static const border = Color(0xFFCFE0FF);
}

class StudentCalendarPage extends StatefulWidget {
  final Map<DateTime, List<Subject>> events;
  final DateTime? initialFocusedDay;
  final DateTime? initialSelectedDay;

  const StudentCalendarPage({
    super.key,
    required this.events,
    this.initialFocusedDay,
    this.initialSelectedDay,
  });

  @override
  State<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  late DateTime _focusedDay;
  DateTime? _selectedDay; // ← เริ่มต้นเป็น null เพื่อยังไม่แสดงรายการ

  DateTime _normalizeDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  List<Subject> _getItemsForDay(DateTime day) {
    final key = _normalizeDay(day);
    return widget.events[key] ??
        widget.events[DateTime(key.year, key.month, key.day)] ??
        const <Subject>[];
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
    // ❌ เดิม: _selectedDay = widget.initialSelectedDay ?? _normalizeDay(DateTime.now());
    // ✅ ใหม่: ยังไม่เลือกวัน จึงไม่แสดงรายวิชา
    _selectedDay = null;
  }

  @override
  Widget build(BuildContext context) {
    final List<Subject> items =
        (_selectedDay != null) ? _getItemsForDay(_selectedDay!) : const <Subject>[];

    return Scaffold(
      appBar: const CustomAppBar(title: 'Calendar'),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ===== ปฏิทิน =====
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFA6CAFA), width: 1.5),
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
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getItemsForDay,
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(fontSize: 12, color: _CalTheme.sub),
                weekendStyle: TextStyle(fontSize: 12, color: _CalTheme.sub),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: const TextStyle(
                  color: _CalTheme.ink,
                  fontSize: 12,
                ),
                weekendTextStyle: const TextStyle(
                  color: _CalTheme.ink,
                  fontSize: 12,
                ),
                outsideDaysVisible: true,
                todayDecoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 232, 248), // ฟ้าอ่อนมาก
                  border: Border.all(
                    color: const Color(0xFF4A86E8), // ฟ้าเข้ม
                    width: 1.5,
                  ),
                  shape: BoxShape.circle,
                ),
                  todayTextStyle: const TextStyle(
                  color: Color(0xFF4A86E8), // ตัวเลขเป็นฟ้าเข้ม
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
                  _selectedDay = selectedDay; // ← เลือกวันแล้วค่อยโชว์รายการ
                  _focusedDay = focusedDay;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),

          const SizedBox(height: 16),

          // ===== แสดงรายการรายวิชา "เฉพาะเมื่อ" มีการเลือกวันแล้ว =====
          if (_selectedDay == null)
            const Center(
            )
          else if (items.isEmpty)
            const Center(
              child: Text(
                'ไม่มีรายวิชาที่เรียนในวันนี้',
                style: TextStyle(color: _CalTheme.sub, fontSize: 14),
              ),
            )
          else
            ...items.map(
              (s) => TextBox(
                subject: s,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SubjectDetailPage(subject: s),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
