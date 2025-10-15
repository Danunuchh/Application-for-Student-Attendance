// lib/student/student_courses_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/student/student_course_report_page.dart';

class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key});

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  late Future<List<Map<String, String>>> _future;
  static const Color ink = Color(0xFF1F2937);
  static const Color sub = Color(0xFF6B7280);

  // TODO: เปลี่ยนเป็น URL จริงของคุณ
  final Uri apiUrl = Uri.parse('https://your-backend.com/api/student/courses');

  @override
  void initState() {
    super.initState();
    _future = _fetchCourses();
  }

  Future<List<Map<String, String>>> _fetchCourses() async {
    final res = await http.get(apiUrl);
    if (res.statusCode != 200) {
      throw Exception('โหลดรายวิชาไม่สำเร็จ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! List) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง (ต้องเป็นลิสต์)');
    }

    // รองรับคีย์ที่พบบ่อย: name/title และ code/courseCode
    // map ให้กลายเป็น {name, code} ที่เป็น String ทั้งคู่
    return data.map<Map<String, String>>((e) {
      final name = (e['name'] ?? e['title'] ?? '').toString();
      final code = (e['code'] ?? e['courseCode'] ?? '').toString();
      return {'name': name, 'code': code};
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _fetchCourses();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: FutureBuilder<List<Map<String, String>>>(
        future: _future,
        builder: (context, snap) {
          // 🌀 กำลังโหลด
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A86E8)),
            );
          }

          // ❌ ผิดพลาด
          if (snap.hasError) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'รอดึงข้อมูลมาแสดงจ้าาา\n${snap.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 12),
                  const Text('ดึงเพื่อรีเฟรชอีกครั้ง'),
                ],
              ),
            );
          }

          final courses = snap.data ?? [];

          // 🕳 ไม่มีข้อมูล
          if (courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  Text(
                    'ไม่พบรายวิชา',
                    style: TextStyle(color: sub, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          // ✅ แสดงรายการ (รองรับ Pull-to-refresh)
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                final name = c['name'] ?? '-';
                final code = c['code'] ?? '-';

                return TextBox(
                  text: name,        // บรรทัดบน: ชื่อรายวิชา
                  subtitle: code,    // บรรทัดล่าง: รหัสวิชา
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentCourseReportPage(
                          courseName: name,
                          courseCode: code,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
