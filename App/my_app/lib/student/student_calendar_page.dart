import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/components/app_calendar.dart';
import 'package:my_app/components/app_calendar_theme.dart';
import 'package:my_app/models/subject.dart';
import 'package:my_app/student/subject_detail_page.dart';

class StudentCalendarPage extends StatefulWidget {
  final Map<DateTime, List<Subject>> events;
  final DateTime? initialFocusedDay;

  const StudentCalendarPage({
    super.key,
    required this.events,
    this.initialFocusedDay,
  });

  @override
  State<StudentCalendarPage> createState() =>
      _StudentCalendarPageState();
}

class _StudentCalendarPageState extends State<StudentCalendarPage> {
  DateTime? _selectedDay;

  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  List<Subject> _itemsForSelectedDay() {
    if (_selectedDay == null) return [];
    return widget.events[_key(_selectedDay!)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final items = _itemsForSelectedDay();

    return Scaffold(
      appBar: const CustomAppBar(title: 'ปฏิทิน'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AppCalendar<Subject>(
            events: widget.events,
            onDaySelected: (d) {
              setState(() => _selectedDay = d);
            },
          ),

          const SizedBox(height: 16),

          if (_selectedDay == null)
            const SizedBox.shrink()
          else if (items.isEmpty)
            const Center(
              child: Text(
                'ไม่มีรายวิชาที่เรียนในวันนี้',
                style: TextStyle(
                  color: AppCalendarTheme.sub,
                  fontSize: 14,
                ),
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
                      builder: (_) =>
                          SubjectDetailPage(subject: s),
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
