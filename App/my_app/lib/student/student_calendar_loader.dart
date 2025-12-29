import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/models/subject.dart';
import 'package:my_app/models/day.dart';
import 'package:my_app/student/student_calendar_page.dart';
import 'package:my_app/services/api_service.dart'; // N: ใช้ ApiService แทน http ตรงๆ
import 'package:shared_preferences/shared_preferences.dart'; // N: เพิ่มเพื่อดึง user_id

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
  
  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  
  //N: ปรับให้ใช้ api จริง
  Future<Map<DateTime, List<Subject>>> _fetchEvents() async {
    // N: ดึง userId จาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      throw Exception('ไม่พบ user_id กรุณาเข้าสู่ระบบใหม่');
    }

    // N: เรียก courses_api.php?type=show_student&user_id={id} เพื่อดึงรายวิชาของนักศึกษา
    final uri = ApiService.uri('/courses_api.php?type=show_student&user_id=$userId');
    final headers = await ApiService.authHeaders();
    final res = await ApiService.client().get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final response = jsonDecode(res.body);
    if (response is! Map || response['success'] != true) {
      throw Exception(response['message'] ?? 'โหลดข้อมูลล้มเหลว');
    }

    final data = response['data'];
    if (data is! List) throw Exception('JSON ต้องเป็น List');

    final map = <DateTime, List<Subject>>{};

    // N: กำหนดช่วงเวลาที่จะแสดงในปฏิทิน (8 สัปดาห์ล่วงหน้า)
    final now = DateTime.now();
    // ถ้าจะเปลี่ยนระยะเวลาแสดงผลก็เปลี่ยนตรงนี้
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 56)); // 8 สัปดาห์

    // N: แปลงข้อมูลจาก API (courses) ให้เป็น calendar events
    // API คืน: {id, name, code, credit, day_id, start_time, end_time, room, teacher_name, section}
    for (final raw in data) {
      // สร้าง Subject จากข้อมูลรายวิชา
      final subject = Subject(
        id: '${raw['id'] ?? ''}',
        title: '${raw['name'] ?? ''}', // course_name
        code: '${raw['code'] ?? ''}',
        credits: '${raw['credit'] ?? ''}',
        teacher: '${raw['teacher_name'] ?? ''}',
        time: '${raw['start_time'] ?? ''} - ${raw['end_time'] ?? ''}',
        room: '${raw['room'] ?? ''}',
      );

      // N: แปลง day_id เป็นวันที่จริงๆ ในปฏิทิน
      final dayId = raw['day_id'];
      if (dayId != null && dayId is int && dayId >= 1 && dayId <= 7) {
        // หาทุกวันที่ตรงกับ day_id ในช่วงเวลาที่กำหนด
        final dates = Day.getAllDatesInRange(dayId, startDate, endDate);

        // เพิ่ม Subject เข้าไปในทุกวันที่ตรงกับ day_id
        for (final date in dates) {
          final normalizedDate = _normalize(date);
          map.putIfAbsent(normalizedDate, () => <Subject>[]).add(subject);
        }
      }
    }

    return map;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<DateTime, List<Subject>>>(
      future: _future,
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
          // แสดง error state แต่ยังให้ใช้งานปฏิทินได้
          return StudentCalendarPage(
            events: const {},
            initialFocusedDay: DateTime.now(),
          );
        }

        // รอจนข้อมูลโหลดเสร็จก่อนแสดง
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return StudentCalendarPage(
          events: snap.data!,
          initialFocusedDay: DateTime.now(),
        );
      },
    );
  }
}
