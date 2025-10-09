import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/student/student_course_report_page.dart';

class StudentCoursesPage extends StatelessWidget {
  const StudentCoursesPage({super.key});

  // โทนสีฟ้าอ่อน
  static const Color bgLight = Color(0xFFF3F7FF); // พื้นหลัง
  static const Color cardLight = Color(0xFFEEF4FF); // พื้นการ์ด
  static const Color borderLight = Color(0xFFCFE0FF); // เส้นขอบ
  static const Color ink = Color(0xFF1F2937); // สีตัวอักษรหลัก
  static const Color sub = Color(0xFF6B7280); // สีรอง

  @override
  Widget build(BuildContext context) {
    final courses = [
      {"name": "DATA MINING", "code": "11256043"},
      {"name": "INTERNET OF THINGS AND SMART SYSTEMS", "code": "11256043"},
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final c = courses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: const Color(0xFFCFE0FF)),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              title: Text(
                c['name']!,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(
                c['code']!,
                style: const TextStyle(color: sub, fontSize: 13),
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: ink,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StudentCourseReportPage(
                      courseName: c['name']!,
                      courseCode: c['code']!,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
