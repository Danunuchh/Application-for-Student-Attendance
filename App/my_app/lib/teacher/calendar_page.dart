import 'package:flutter/material.dart';

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/components/app_calendar.dart';
import 'package:my_app/models/subject.dart';
import 'package:my_app/teacher/course_detail_page.dart';

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

  /// fallback events ถ้าไม่ได้ส่งมาจากข้างนอก
  final Map<DateTime, List<Subject>> _events = {};

  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Subject> _itemsOf(DateTime day) {
    final data = widget.events ?? _events;
    return data[_key(day)] ?? const <Subject>[];
  }

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.initialFocusedDay ?? DateTime.now();
    _selectedDay = widget.initialSelectedDay;

    // TODO: fetch teaching events แล้ว setState ใส่ _events
  }

  /// ===== REFRESH =====
  Future<void> _refresh() async {
    // ถ้ามี API จริง ให้เรียก fetch ตรงนี้
    // await _fetchTeachingEvents();

    // ตอนนี้แค่ rebuild หน้าจอ
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final items = _selectedDay != null
        ? _itemsOf(_selectedDay!)
        : const <Subject>[];

    return Scaffold(
      appBar: const CustomAppBar(title: 'ปฏิทิน'),
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            /// ===== AppCalendar =====
            AppCalendar<Subject>(
              events: widget.events ?? _events,
              initialFocusedDay: _focusedDay,
              initialSelectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day;
                  _focusedDay = day;
                });
              },
            ),

            const SizedBox(height: 16),

            /// ===== รายวิชาที่สอนในวันนั้น =====
            if (_selectedDay == null)
              const SizedBox.shrink()
            else if (items.isEmpty)
              const Center(
                child: Text(
                  'ไม่มีคาบสอนในวันนี้',
                  style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                ),
              )
            else
              ...items.map(
                (s) => TextBox(
                  subject: s,
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF9CA3AF),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CourseDetailPage(
                          courseId: s.id,
                          courseName: s.title,
                          courseCode: s.code,
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
