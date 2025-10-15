import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart'; // ✅ ใช้ TextBox
import 'package:my_app/teacher/attendancedetail_page.dart'; // ✅ หน้ารายละเอียดอาจารย์

/// หน้าประวัติการเข้าเรียน (ฝั่งอาจารย์)
/// - เรียกได้แบบ const
/// - ถ้ายังไม่มี courses จะแสดงข้อความว่าง
class AttendanceHistoryPage extends StatelessWidget {
  /// รายวิชาที่จะโชว์เป็นลิสต์
  /// ตัวอย่างโครง: [{'id': '1', 'name': 'DATA MINING', 'code': '11256043'}, ...]
  final List<Map<String, String>> courses;

  const AttendanceHistoryPage({
    super.key,
    this.courses = const [], // ✅ ไม่ส่งมาก็ไม่พัง
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: courses.isEmpty
          ? const _EmptyState()
          : ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final c = courses[i];
                final name = c['name'] ?? '-';
                final code = c['code'] ?? '-';

                return TextBox(
                  title: name, // ✅ ชื่อวิชา
                  subtitle: code, // ✅ รหัสวิชา
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                  onTap: () {
                    // ✅ เปิดหน้า attendancedetail_page โดยส่งข้อมูลวิชานั้นไป
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AttendanceDetailPage(
                          courseName: name,
                          records: const [], // ✅ รอข้อมูลจริงจากฐานข้อมูล
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

/// ------- ว่าง (ไม่มีรายวิชา) -------
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
      children: const [
        Center(
          child: Text(
            'ยังไม่มีรายวิชา',
            style: TextStyle(color: Color(0xFF9CA3AF)),
          ),
        ),
      ],
    );
  }
}
