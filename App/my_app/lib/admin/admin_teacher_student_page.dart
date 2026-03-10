import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/config.dart';

const String apiBase = baseUrl;

class AdminTeacherCourseStudentPage extends StatefulWidget {
  final String courseCode;
  final String courseName;

  const AdminTeacherCourseStudentPage({
    super.key,
    required this.courseCode,
    required this.courseName,
  });

  @override
  State<AdminTeacherCourseStudentPage> createState() =>
      _AdminTeacherCourseStudentPageState();
}

class _AdminTeacherCourseStudentPageState
    extends State<AdminTeacherCourseStudentPage> {
  late Future<List<StudentItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadStudents();
  }

  /// ===== โหลดนักศึกษาในรายวิชา =====
  Future<List<StudentItem>> _loadStudents() async {
    final uri = Uri.parse('$apiBase/admin_api.php').replace(
      queryParameters: {
        'type': 'teacher_course_students',
        'course_code': widget.courseCode,
      },
    );

    final res = await http.get(uri);
    final json = jsonDecode(res.body);

    if (json['success'] != true || json['data'] == null) {
      return []; // 🔥 คืน list ว่างแทน throw
    }

    final List students = json['data']['students'];

    return students.map<StudentItem>((e) {
      return StudentItem(studentId: e['student_id'], fullName: e['full_name']);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.courseName),
      body: FutureBuilder<List<StudentItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                snap.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(
              child: Text(
                'ไม่พบข้อมูล',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snap.data!.length,
            itemBuilder: (context, index) {
              final s = snap.data![index];

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF84A9EA),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1F000000),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.studentId,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ===== Model นักศึกษา =====
class StudentItem {
  final String studentId;
  final String fullName;

  StudentItem({required this.studentId, required this.fullName});
}
