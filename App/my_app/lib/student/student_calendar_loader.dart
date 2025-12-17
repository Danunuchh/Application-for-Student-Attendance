import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/subject.dart';
import 'package:my_app/student/student_calendar_page.dart';

class StudentCalendarLoader extends StatefulWidget {
  const StudentCalendarLoader({super.key});

  @override
  State<StudentCalendarLoader> createState() =>
      _StudentCalendarLoaderState();
}

class _StudentCalendarLoaderState extends State<StudentCalendarLoader> {
  late Future<Map<DateTime, List<Subject>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchEvents();
  }

  DateTime _normalize(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<Map<DateTime, List<Subject>>> _fetchEvents() async {
    final res = await http.get(Uri.parse('https://localhost:8000'));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('JSON ต้องเป็น List');

    final map = <DateTime, List<Subject>>{};

    for (final raw in data) {
      if (raw['date'] == null) continue;

      final date = _normalize(DateTime.parse(raw['date']));
      final subject = Subject(
        id: '${raw['id']}',
        title: '${raw['title']}',
        code: '${raw['code']}',
        credits: '${raw['credits']}',
        teacher: '${raw['teacher']}',
        time: '${raw['time']}',
        room: '${raw['room']}',
      );

      map.putIfAbsent(date, () => <Subject>[]).add(subject);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Subject>>>(
      future: _future,
      initialData: const {},
      builder: (context, snap) {
        if (snap.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(
                SnackBar(
                  content: Text('โหลดข้อมูลล้มเหลว: ${snap.error}'),
                ),
              );
          });
        }

        return StudentCalendarPage(
          events: snap.data ?? const {},
          initialFocusedDay: DateTime.now(),
        );
      },
    );
  }
}
