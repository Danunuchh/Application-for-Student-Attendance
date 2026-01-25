import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/admin/admin_student_dashboard_page.dart';

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';

const String apiBase = baseUrl;

class AdminStudentDetailPage extends StatefulWidget {
  final String studentId;
  final String fullName;

  const AdminStudentDetailPage({
    super.key,
    required this.studentId,
    required this.fullName,
  });

  @override
  State<AdminStudentDetailPage> createState() => _AdminStudentDetailPageState();
}

class _AdminStudentDetailPageState extends State<AdminStudentDetailPage> {
  late Future<List<CourseStat>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCourses();
  }

  Future<List<CourseStat>> _loadCourses() async {
    final uri = Uri.parse('$apiBase/admin_api.php').replace(
      queryParameters: {
        'type': 'student_detail',
        'student_id': widget.studentId,
      },
    );

    final res = await http.get(uri);
    final json = jsonDecode(res.body);

    if (json['success'] != true) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final Map<String, dynamic> data = json['data'];
    final List courses = data['courses'];

    return courses.map((e) {
      return CourseStat(
        courseName: e['course_name'],
        courseCode: e['course_code'],
        total: e['total_classes'],
        attend: e['attend_count'],
        absent: e['absent_count'],
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fullName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FutureBuilder<List<CourseStat>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              if (!snap.hasData || snap.data!.isEmpty) {
                return const Center(child: Text('ไม่มีรายวิชา'));
              }

              return Column(
                children: snap.data!.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextBox(
                      title: c.courseName,
                      subtitle: c.courseCode,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminStudentDashboardPage(
                              courseName: c.courseName,
                              stat: StudentCourseStat(
                                studentId: widget.studentId,
                                studentName: widget.fullName,
                                attend: c.attend,
                                absent: c.absent,
                                total: c.total,
                              ),
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
    );
  }
}

class StudentCourseStat {
  final String studentId;
  final String studentName;
  final int attend;
  final int absent;
  final int total;

  StudentCourseStat({
    required this.studentId,
    required this.studentName,
    required this.attend,
    required this.absent,
    required this.total,
  });

  factory StudentCourseStat.fromJson(Map<String, dynamic> json) {
    return StudentCourseStat(
      studentId: json['student_id'],
      studentName: json['student_name'],
      attend: json['attend'],
      absent: json['absent'],
      total: json['total_classes'],
    );
  }
}

class CourseStat {
  final String courseName;
  final String courseCode;
  final int total;
  final int attend;
  final int absent;

  CourseStat({
    required this.courseName,
    required this.courseCode,
    required this.total,
    required this.attend,
    required this.absent,
  });
}
