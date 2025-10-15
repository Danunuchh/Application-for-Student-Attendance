import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'student_attendancedetail_page.dart';

class AttendanceHistoryPage extends StatelessWidget {
  final List<Map<String, String>> courses; // ✅ รับพารามิเตอร์จากภายนอก

  const AttendanceHistoryPage({
    super.key,
    required this.courses,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = courses[i];
          final name = c['name'] ?? '-';  //ชื่อวิชา
          final code = c['code'] ?? '-';  //รหัสวิชา

          return TextBox(
            text: name,
            subtitle: code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceDetailPage(
                    courseName: name,
                    records: const [], // ส่งข้อมูลเช็คชื่อของรายวิชานั้น
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
