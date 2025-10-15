import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/models/subject.dart';
import 'package:my_app/student/student_calendar_page.dart';

class StudentCalendarLoader extends StatefulWidget {
  const StudentCalendarLoader({super.key});

  @override
  State<StudentCalendarLoader> createState() => _StudentCalendarLoaderState();
}

class _StudentCalendarLoaderState extends State<StudentCalendarLoader> {
  late Future<Map<DateTime, List<Subject>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchEvents(); // ✅ โหลดจาก API จริง
  }

  DateTime _normalizeDay(DateTime d) => DateTime.utc(d.year, d.month, d.day);

  Future<Map<DateTime, List<Subject>>> _fetchEvents() async {
    // 🔵 เปลี่ยน URL เป็นของคุณเอง
    final url = Uri.parse('https://your-server.com/api/schedule');

    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${res.statusCode})');
    }

    final list = jsonDecode(res.body);
    if (list is! List) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง (ต้องเป็น List)');
    }

    final map = <DateTime, List<Subject>>{};
    for (final raw in list) {
      final dateStr = (raw['date'] ?? '').toString();
      if (dateStr.isEmpty) continue;

      final date = _normalizeDay(DateTime.parse(dateStr));
      final subject = Subject(
        title: (raw['title'] ?? '').toString(),
        code: (raw['code'] ?? '').toString(),
        credits: (raw['credits'] ?? '').toString(),
        teacher: (raw['teacher'] ?? '').toString(),
        time: (raw['time'] ?? '').toString(),
        room: (raw['room'] ?? '').toString(),
      );

      map.putIfAbsent(date, () => <Subject>[]).add(subject);
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Subject>>>(
      future: _future,
      initialData: const <DateTime, List<Subject>>{}, // ✅ เริ่มด้วย events ว่าง
      builder: (context, snap) {
        // ❌ ถ้า error: ยังแสดงปฏิทิน (events ว่าง) แต่โชว์แถบแจ้งเตือนด้านล่าง
        if (snap.hasError) {
          // ใช้ ScaffoldMessenger หลังจากเฟรมนี้ build เสร็จ เพื่อไม่ให้ throw during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final msg = 'เกิดข้อผิดพลาดในการโหลดข้อมูล: ${snap.error}';
            ScaffoldMessenger.of(context)
              ..clearSnackBars()
              ..showSnackBar(SnackBar(content: Text(msg)));
          });
        }

        // ✅ แสดงปฏิทินตั้งแต่แรก (แม้กำลังโหลด)
        final events = snap.data ?? const <DateTime, List<Subject>>{};
        return StudentCalendarPage(
          events: events,
          initialFocusedDay: DateTime.now(),
          // initialSelectedDay ไม่ส่ง เพื่อให้ขึ้น “เฉพาะปฏิทินก่อน”
        );
      },
    );
  }
}
