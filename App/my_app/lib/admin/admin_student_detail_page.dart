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

  // ===================== ปรับเป็น bool =====================
  bool? _status; // true = Active, false = Graduated
  bool _updatingStatus = false;
  // ========================================================

  @override
  void initState() {
    super.initState();
    _future = _loadCourses();
  }

  static const Color _borderBlue = Color(0xFF88A8E8);

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

    setState(() {
      _studentInfo = data;

      // ====== แปลง 1/0 จาก API เป็น bool ======
      _status = data['status']?.toString() == '1';
    });

    return courses.map((e) {
      return CourseStat(
        courseName: e['course_name'] ?? '',
        courseCode: e['course_code'] ?? '',
        year: e['year']?.toString(),
        term: e['term']?.toString(),
        section: e['section']?.toString(),
        total: e['total_classes'] ?? 0,
        attend: e['attend_count'] ?? 0,
        leave: e['leave'] ?? 0,
        absent: e['absent_count'] ?? 0,
      );
    }).toList();
  }

  // ===================== เพิ่ม Dialog ยืนยัน =====================
  Future<void> _confirmAndUpdateStatus(bool newStatus) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('ยืนยันการเปลี่ยนสถานะ'),
          content: Text(
            'ต้องการเปลี่ยนสถานะเป็น ${newStatus ? "Active" : "Graduated"} ใช่หรือไม่?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('ยืนยัน'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _updateStatus(newStatus);
    }
  }
  // ==========================================================

  Future<void> _updateStatus(bool newStatus) async {
    setState(() => _updatingStatus = true);

    final res = await http.post(
      Uri.parse('$apiBase/admin_api.php'),
      body: {
        'type': 'update_student_status',
        'student_id': widget.studentId,
        'status': newStatus ? '1' : '0',
      },
    );

    final json = jsonDecode(res.body);

    setState(() => _updatingStatus = false);

    if (json['success'] == true) {
      setState(() => _status = newStatus);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อัปเดตสถานะเรียบร้อย')));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อัปเดตไม่สำเร็จ')));
    }
  }

  Map<String, dynamic>? _studentInfo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.fullName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_studentInfo != null)
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
              ),
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รหัสนักศึกษา : ${_studentInfo!['student_id'] ?? '-'}',
                    ),
                    const SizedBox(height: 6),

                    Text('อีเมล : ${_studentInfo!['email'] ?? '-'}'),
                    const SizedBox(height: 6),

                    Text('โทร : ${_studentInfo!['phone_number'] ?? '-'}'),
                    const SizedBox(height: 6),

                    Text('ที่อยู่ : ${_studentInfo!['address'] ?? '-'}'),
                    const SizedBox(height: 6),

                    // ===================== Switch แทน Dropdown =====================
                    Row(
                      children: [
                        const Text('สถานะ : '),
                        const SizedBox(width: 12),

                        _updatingStatus
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : _status == null
                            ? const SizedBox()
                            : Row(
                                children: [
                                  Text(
                                    _status! ? 'Active' : 'Graduated',
                                    style: TextStyle(
                                      color: _status!
                                          ? Colors.green
                                          : Colors.grey,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: _status!,
                                    activeColor: Colors.green,
                                    onChanged: (value) {
                                      _confirmAndUpdateStatus(value);
                                    },
                                  ),
                                ],
                              ),
                      ],
                    ),
                    // ==========================================================
                  ],
                ),
              ),
            ),

          FutureBuilder<List<CourseStat>>(
            future: _future,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const LinearProgressIndicator();
              }

              if (!snap.hasData || snap.data == null || snap.data!.isEmpty) {
                return const SizedBox();
              }

              return Column(
                children: snap.data!.map((c) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextBox(
                      title: '${c.courseCode}  ${c.courseName}',
                      subtitle:
                          'ปีการศึกษา ${c.year ?? '-'} | ภาคเรียน ${c.term ?? '-'} | Sec ${c.section ?? '-'}',
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
                                leave: c.leave,
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
  final int leave;
  final int absent;
  final int total;

  StudentCourseStat({
    required this.studentId,
    required this.studentName,
    required this.attend,
    required this.leave,
    required this.absent,
    required this.total,
  });

  factory StudentCourseStat.fromJson(Map<String, dynamic> json) {
    return StudentCourseStat(
      studentId: json['student_id'],
      studentName: json['student_name'],
      attend: json['attend'] ?? 0,
      leave: json['leave'] ?? 0,
      absent: json['absent'] ?? 0,
      total: json['total_classes'] ?? 0,
    );
  }
}

class CourseStat {
  final String courseName;
  final String courseCode;

  final String? year;
  final String? term;
  final String? section;

  final int total;
  final int attend;
  final int leave;
  final int absent;

  CourseStat({
    required this.courseName,
    required this.courseCode,
    this.year,
    this.term,
    this.section,
    required this.total,
    required this.attend,
    required this.leave,
    required this.absent,
  });
}
