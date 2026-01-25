import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/teacher/student_attendance_detail_page.dart';
import 'package:my_app/components/textbox.dart';

Widget _statChip(String label, int value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$label $value',
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}

class StudentStat {
  final String studentId;
  final String studentName;
  final int attend;
  final int absent;
  final int totalClasses;

  StudentStat({
    required this.studentId,
    required this.studentName,
    required this.attend,
    required this.absent,
    required this.totalClasses,
  });

  factory StudentStat.fromJson(Map<String, dynamic> json) {
    return StudentStat(
      studentId: json['student_id'],
      studentName: json['student_name'],
      attend: json['attend'],
      absent: json['absent'],
      totalClasses: json['total_classes'],
    );
  }
}

const String apiBase = baseUrl;

class DashbordDetailPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;

  const DashbordDetailPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<DashbordDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<DashbordDetailPage> {
  late Future<List<StudentStat>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<List<StudentStat>> _loadDetail() async {
    final uri = Uri.parse(
      '$apiBase/dashbord.php',
    ).replace(queryParameters: {'type': 'teacher', 'user_id': widget.userId});

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final json = jsonDecode(res.body);

    if (json['success'] != true) {
      throw Exception('API error');
    }

    final List courses = json['data'];

    /// 🔑 หา course ที่ตรงกับ courseId
    final course = courses.firstWhere(
      (c) => c['course_id'].toString() == widget.courseId,
      orElse: () => null,
    );

    if (course == null || course['students'] == null) {
      return [];
    }

    final List students = course['students'];

    return students.map((e) => StudentStat.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.courseName),
      body: FutureBuilder<List<StudentStat>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลนักศึกษา'));
          }

          final students = snap.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final s = students[i];

              return TextBox(
                title: s.studentName,
                subtitleWidget: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// ====== รายละเอียดฝั่งซ้าย ======
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${s.studentId}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _statChip('เข้า', s.attend, Colors.green),
                              _statChip('ขาด', s.absent, Colors.red),
                              _statChip('ทั้งหมด', s.totalClasses, Colors.blue),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => StudentAttendanceDetailPage(
                          student: s,
                          courseName: widget.courseName,
                        ),
                      ),
                    );
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
