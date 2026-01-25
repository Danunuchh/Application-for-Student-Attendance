import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/admin/admin_student_detail_page.dart';

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/teacher/student_attendance_detail_page.dart';

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

class AdminStudentDashboardPage extends StatelessWidget {
  final String courseName;
  final StudentCourseStat stat;

  const AdminStudentDashboardPage({
    super.key,
    required this.courseName,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: courseName),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            stat.studentName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(stat.studentId, style: const TextStyle(color: Colors.grey)),

          const SizedBox(height: 16),

          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                children: [
                  _statChip('เข้า', stat.attend, Colors.green),
                  _statChip('ขาด', stat.absent, Colors.red),
                  _statChip('ทั้งหมด', stat.total, Colors.blue),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
