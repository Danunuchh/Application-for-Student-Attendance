import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/models/subject.dart';
import 'package:my_app/models/day.dart';
import 'package:my_app/teacher/calendar_page.dart';
import 'package:my_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherCalendarLoader extends StatefulWidget {
  const TeacherCalendarLoader({super.key});

  @override
  State<TeacherCalendarLoader> createState() => _TeacherCalendarLoaderState();
}

class _TeacherCalendarLoaderState extends State<TeacherCalendarLoader> {
  late Future<Map<DateTime, List<Subject>>> _future;
  String _userId = '';

  @override
  void initState() {
    super.initState();
    _future = _fetchEvents();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  Future<Map<DateTime, List<Subject>>> _fetchEvents() async {
    // ดึง userId จาก SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId') ?? '';

    if (userId.isEmpty) {
      throw Exception('ไม่พบ user_id กรุณาเข้าสู่ระบบใหม่');
    }

    _userId = userId;

    // เรียก courses_api.php?type=show&user_id={id} เพื่อดึงรายวิชาที่อาจารย์สอน
    final uri = ApiService.uri('/courses_api.php?type=show&user_id=$userId');
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

    // กำหนดช่วงเวลาที่จะแสดงในปฏิทิน (8 สัปดาห์ล่วงหน้า)
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day);
    final endDate = startDate.add(const Duration(days: 56)); // 8 สัปดาห์

    // แปลงข้อมูลจาก API (courses) ให้เป็น calendar events
    // API คืน: {id, name, code, day_id, start_time, end_time, room, teacher_name}
    for (final raw in data) {
      // สร้าง Subject จากข้อมูลรายวิชา
      final subject = Subject(
        id: '${raw['id'] ?? ''}',
        title: '${raw['name'] ?? ''}',
        code: '${raw['code'] ?? ''}',
        credits: '${raw['credit'] ?? ''}',
        teacher: '${raw['teacher_name'] ?? ''}',
        time: '${raw['start_time'] ?? ''} - ${raw['end_time'] ?? ''}',
        room: '${raw['room'] ?? ''}',
      );

      // แปลง day_id เป็นวันที่จริงๆ ในปฏิทิน
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
          return CalendarPage(
            userId: _userId,
            events: const {},
            initialFocusedDay: DateTime.now(),
          );
        }

        // รอจนข้อมูลโหลดเสร็จก่อนแสดง
        if (!snap.hasData) {
          return const Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(56),
              child: SizedBox.shrink(),
            ),
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return CalendarPage(
          userId: _userId,
          events: snap.data!,
          initialFocusedDay: DateTime.now(),
        );
      },
    );
  }
}
