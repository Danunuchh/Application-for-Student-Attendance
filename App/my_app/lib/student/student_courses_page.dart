// lib/student/student_courses_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/student/student_course_report_page.dart';

const String apiBase = baseUrl;

/// ================= API =================
class ApiService {
  static Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$apiBase/$path').replace(queryParameters: query);

    final res = await http.get(uri, headers: _jsonHeaders);

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    return jsonDecode(res.body);
  }
}

/// ================= PAGE =================
class StudentCoursesPage extends StatefulWidget {
  const StudentCoursesPage({super.key, required this.userId});

  final String userId;

  @override
  State<StudentCoursesPage> createState() => _StudentCoursesPageState();
}

class _StudentCoursesPageState extends State<StudentCoursesPage> {
  static const Color sub = Color(0xFF6B7280);

  late Future<List<CourseOption>> _coursesFuture;

  @override
  void initState() {
    super.initState();
    _coursesFuture = _loadCourses();
  }

  /// ---------- load courses ----------
  Future<List<CourseOption>> _loadCourses() async {
    final json = await ApiService.getJson(
      'dashbord.php',
      query: {'user_id': widget.userId, 'type': 'student'},
    );

    if (json['success'] != true || json['data'] == null) {
      throw Exception('โหลดรายวิชาไม่สำเร็จ');
    }

    final List list = json['data'];

    return list.map<CourseOption>((e) {
      final student = (e['students'] as List).first;

      return CourseOption(
        id: e['course_id'].toString(),
        name: e['course_name'].toString(),
        code: e['code']?.toString(),
        totalClasses: student['total_classes'] ?? 0,
        attend: student['attend'] ?? 0,
        absent: student['absent'] ?? 0,
      );
    }).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _coursesFuture = _loadCourses();
    });
    await _coursesFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// -------- Courses --------
            FutureBuilder<List<CourseOption>>(
              future: _coursesFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                }

                if (snap.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      snap.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                if (!snap.hasData || snap.data!.isEmpty) {
                  return const _EmptyBox(text: 'ไม่พบรายวิชา', sub: sub);
                }

                final courses = snap.data!;

                return Column(
                  children: courses.map((course) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: TextBox(
                        title: course.name,
                        subtitle: course.code ?? '-',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => StudentCourseReportPage(
                                courseId: course.id,
                                courseName: course.name,
                                courseCode: course.code ?? '',
                                totalClasses: course.totalClasses,
                                attend: course.attend,
                                absent: course.absent,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= MODEL =================
class CourseOption {
  final String id;
  final String name;
  final String? code;

  final int totalClasses;
  final int attend;
  final int absent;

  const CourseOption({
    required this.id,
    required this.name,
    this.code,
    required this.totalClasses,
    required this.attend,
    required this.absent,
  });
}

/// ================= UTILS =================
class _EmptyBox extends StatelessWidget {
  final String text;
  final Color sub;

  const _EmptyBox({required this.text, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(text, style: TextStyle(color: sub)),
      ),
    );
  }
}
