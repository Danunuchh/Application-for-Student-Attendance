import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/admin/admin_teacher_student_page.dart';

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/config.dart';

const String apiBase = baseUrl;

class AdminTeacherDetailPage extends StatefulWidget {
  final String fullName; // ชื่ออาจารย์

  AdminTeacherDetailPage({super.key, required this.fullName});

  @override
  State<AdminTeacherDetailPage> createState() =>
      _AdminTeacherDetailPageState();
}

class _AdminTeacherDetailPageState extends State<AdminTeacherDetailPage> {
  late Future<List<CourseStat>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCourses();
  }

  /// ===== โหลดรายวิชาที่อาจารย์สอน =====
  Future<List<CourseStat>> _loadCourses() async {
    final uri = Uri.parse('$apiBase/admin_api.php').replace(
      queryParameters: {
        'type': 'teacher_detail',
        'teacher_name': widget.fullName,
      },
    );

    final res = await http.get(uri);
    final json = jsonDecode(res.body);

    if (json['success'] != true || json['data'] == null) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final List courses = json['data']['courses'];

    return courses.map<CourseStat>((e) {
      return CourseStat(
        courseName: e['course_name'],
        courseCode: e['course_code'],
        section: e['section'],
        totalStudents: e['total_students'],
      );
    }).toList();
  }

  /// ===== refresh =====
  Future<void> _refresh() async {
    setState(() {
      _future = _loadCourses();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fullName),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<CourseStat>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return ListView(
                children: [
                  SizedBox(height: 200),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }

            if (snap.hasError) {
              return ListView(
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      snap.error.toString(),
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ],
              );
            }

            if (!snap.hasData || snap.data!.isEmpty) {
              return ListView(
                children: [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'อาจารย์ท่านนี้ยังไม่มีรายวิชาที่สอน',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: snap.data!.length,
              itemBuilder: (context, index) {
                final c = snap.data![index];

                return InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminTeacherCourseStudentPage(
                          courseCode: c.courseCode,
                          courseName: c.courseName,
                          section: c.section,
                        ),
                      ),
                    );
                  },
                  child: Container(
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
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                c.courseName,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'กลุ่มที่เรียน : ${c.section}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'รหัสวิชา : ${c.courseCode}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'จำนวนนักศึกษา : ${c.totalStudents} คน',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 22,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

/// ===== Model รายวิชา =====
class CourseStat {
  final String courseName;
  final String courseCode;
  final String section;
  final int totalStudents;

  CourseStat({
    required this.courseName,
    required this.courseCode,
    required this.section,  
    required this.totalStudents,
  });
}
