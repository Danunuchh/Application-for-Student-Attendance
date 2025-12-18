import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/admin/admin_student_report_page.dart';
import 'package:my_app/admin/admin_teacher_report_page.dart';

enum UserRole { student, teacher }

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  UserRole? selectedRole; // ยังไม่เลือกตอนแรก

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: Column(
        children: [
          const SizedBox(height: 16),

          /// ===== ROLE BUTTONS =====
          Row(
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
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),

          /// ===== CONTENT =====
          Expanded(
            child: Builder(
              builder: (context) {
                // ยังไม่เลือก role
                if (selectedRole == null) {
                  return const Center(
                    child: Text(
                      'กรุณาเลือกบทบาทเพื่อดูรายงาน',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                // -------- นักศึกษา --------
                if (selectedRole == UserRole.student) {
                  return const AdminStudentReportPage(
                    courseName: 'DATA MINING',
                    courseCode: '11256043',
                  );
                }

                // -------- อาจารย์ --------
                return AdminTeacherReportPage(
                  userId: 'teacher_001',

                  // mock โหลดรายวิชาที่สอน
                  loadCourses: (userId) async {
                    await Future.delayed(const Duration(milliseconds: 400));
                    return const [
                      CourseOption(id: '11256043', name: 'DATA MINING'),
                      CourseOption(id: '11256044', name: 'DATABASE SYSTEMS'),
                    ];
                  },

                  // mock โหลด dashboard
                  loadDashboard:
                      ({
                        required String userId,
                        required String courseId,
                        required String range,
                      }) async {
                        await Future.delayed(const Duration(milliseconds: 500));
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

/// ===== ROLE BUTTON =====
class _RoleButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF5B7CFA)
                : const Color(0xFFC7D2FE),
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.black : Colors.black87,
          ),
        ),
      ),
    );
  }
}
