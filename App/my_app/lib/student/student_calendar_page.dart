import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'subject_detail_page.dart'; // ต้องมี class Subject และ SubjectDetailPage

/// ---- THEME (แยกออกมาให้ใช้ซ้ำได้) ----
class _CalTheme {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF9CA3AF);
  static const border = Color(0xFFCFE0FF);
}

/// หน้า "ปฏิทินนักศึกษา" — ชื่อคลาสให้ตรงกับที่หน้าโฮมเรียกใช้
class StudentCalendarPage extends StatefulWidget {
  const StudentCalendarPage({super.key});

  @override
  State<StudentCalendarPage> createState() => _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  /// ดัมมี่ดาต้า: ใช้ Subject ที่ประกาศไว้ใน subject_detail_page.dart
  /// TableCalendar กำหนด generic เป็น <Subject> และ eventLoader คืน List<Subject>
  final Map<DateTime, List<Subject>> _events = {
    DateTime.utc(2025, 8, 4): const [
      Subject(
        title: "DATA MINING",
        code: "11256043",
        credits: "3",
        teacher: "ดร.รัตติกร สมบัติแก้ว",
        time: "17:00 - 20:00",
        room: "E107",
      ),
      Subject(
        title: "DATABASE SYSTEMS",
        code: "11256016",
        credits: "3",
        teacher: "ผศ.สุพจน์ วิริยะ",
        time: "13:00 - 16:00",
        room: "C205",
      ),
    ],
    DateTime.utc(2025, 8, 11): const [
      Subject(
        title: "DATA MINING",
        code: "11256043",
        credits: "3",
        teacher: "ดร.รัตติกร สมบัติแก้ว",
        time: "17:00 - 20:00",
        room: "E107",
      ),
    ],
    DateTime.utc(2025, 8, 18): const [
      Subject(
        title: "DATABASE SYSTEMS",
        code: "11256016",
        credits: "3",
        teacher: "ผศ.สุพจน์ วิริยะ",
        time: "13:00 - 16:00",
        room: "C205",
      ),
    ],
  };

  List<Subject> _getItemsForDay(DateTime day) {
    // ทำ key ให้เป็นเที่ยงคืนแบบ UTC ให้ตรงกับที่ _events ใช้
    final key = DateTime.utc(day.year, day.month, day.day);
    return _events[key] ?? const [];
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final items = _getItemsForDay(_selectedDay ?? _focusedDay);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Calendar'),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ---- CALENDAR CARD ----
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: _CalTheme.border),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: TableCalendar<Subject>(
              firstDay: DateTime.utc(2022, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getItemsForDay,
              // ถ้าเวอร์ชัน table_calendar ของคุณไม่มี StartingDayOfWeek.sunday
              // ให้ลบบรรทัดนี้ออกได้
              startingDayOfWeek: StartingDayOfWeek.sunday,
              headerStyle: HeaderStyle(
                titleCentered: true,
                titleTextFormatter: (date, locale) => _monthName(date.month),
                formatButtonVisible: false,
                leftChevronIcon: const Icon(Icons.chevron_left, size: 18),
                rightChevronIcon: const Icon(Icons.chevron_right, size: 18),
                headerPadding: const EdgeInsets.symmetric(vertical: 4),
                titleTextStyle: const TextStyle(
                  fontSize: 16,
                  color: _CalTheme.ink,
                  fontWeight: FontWeight.w500,
                ),
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
                  color: _CalTheme.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
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
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
            ),
          ),
          const SizedBox(height: 16),

          // ---- LIST OF SUBJECT CARDS ----
          ...items.map(
            (subject) => _SubjectCard(
              subject: subject,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SubjectDetailPage(subject: subject),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _monthName(int m) {
    const names = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return names[m - 1];
  }
}

/// การ์ดแต่ละวิชา
class _SubjectCard extends StatelessWidget {
  final Subject subject;
  final VoidCallback? onTap;

  const _SubjectCard({required this.subject, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        elevation: 3,
        shadowColor: Colors.black12,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFCFE0FF)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        subject.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _CalTheme.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subject.code,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _CalTheme.sub,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5EDFF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
