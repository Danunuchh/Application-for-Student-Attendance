import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/admin/admin_student_report_page.dart';
import 'package:my_app/admin/admin_teacher_report_page.dart';

enum UserRole { student, teacher }

class AdminDashboardPage extends StatefulWidget {
  final List<dynamic>? data;

  const AdminDashboardPage({
    super.key,
    this.data,
  });

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}


class _AdminDashboardPageState extends State<AdminDashboardPage> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// ===== ROLE BUTTONS =====
          /*Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoleButton(
                text: 'นักศึกษา',
                isSelected: selectedRole == UserRole.student,
                onTap: () {
                  setState(() => selectedRole = UserRole.student);
                },
              ),
              const SizedBox(width: 20),
              _RoleButton(
                text: 'อาจารย์',
                isSelected: selectedRole == UserRole.teacher,
                onTap: () {
                  setState(() => selectedRole = UserRole.teacher);
                },
              ),
            ],
          ),*/

          const SizedBox(height: 16),
          const Divider(height: 1),

          /// ===== CONTENT =====
          Expanded(
            child: Builder(
              builder: (_) {
                if (selectedRole == null) {
                  return const Center(
                    child: Text(
                      'กรุณาเลือกบทบาทเพื่อดูรายงาน',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                /// ===== STUDENT REPORT =====
              

                /// ===== TEACHER REPORT =====
                return AdminTeacherReportPage(
                  userId: 'teacher_001',

                  loadCourses: (userId) async {
                    await Future.delayed(const Duration(milliseconds: 300));
                    return const [
                      CourseOption(id: '11256043', name: 'DATA MINING'),
                      CourseOption(id: '11256044', name: 'DATABASE SYSTEMS'),
                    ];
                  },

                  loadDashboard: ({
                    required String userId,
                    required String courseId,
                    required String range,
                  }) async {
                    await Future.delayed(const Duration(milliseconds: 400));
                    return DashboardData(
                      totalStudents: 45,
                      attendanceRate: 80,
                      latePerTerm: 10,
                      absentPerTerm: 3,
                      slices: const [
                        Slice(
                          label: 'มาเรียน',
                          value: 80,
                          color: Color(0xFFA3E3A0),
                        ),
                        Slice(
                          label: 'ขาดเรียน',
                          value: 20,
                          color: Color(0xFFF26A6A),
                        ),
                      ],
                      students: const [],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
