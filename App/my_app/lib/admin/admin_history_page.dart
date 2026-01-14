import 'package:flutter/material.dart';
import 'admin_history_detail.dart';
import 'package:my_app/components/custom_appbar.dart';

//หน้าประวัติการเข้าเรียนของนักศึกษา
class AdminHistoryPage extends StatelessWidget {
  const AdminHistoryPage({super.key});

  static const _blueBorder = Color(0xFFB0C4DE);

  @override
  Widget build(BuildContext context) {
    // ข้อมูลวิชาตัวอย่าง
    const courses = [
      {'name': 'DATA MINING', 'code': '11256043'},
      {'name': 'DATABASE SYSTEMS', 'code': '11256016'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 14),
        itemBuilder: (context, i) {
          final c = courses[i];
          return _CourseCard(
            title: c['name']!,
            code: c['code']!,
            onTap: () {
              // สร้างข้อมูลจำลองของการเข้าเรียน
              List<Attendance> attendanceList = [
                Attendance(
                  date: '04/08/68',
                  studentId: '65200020',
                  studentName: 'กวิสรา แซ่เชี้ย',
                  time: '10.00 น.',
                ),
                Attendance(
                  date: '05/08/68',
                  studentId: '65200021',
                  studentName: 'สมชาย ใจดี',
                  time: '09.30 น.',
                ),
                Attendance(
                  date: '06/08/68',
                  studentId: '65200022',
                  studentName: 'น.ส. อรทัย สวยมาก',
                  time: '08.45 น.',
                ),
              ];

              // ไปหน้า AdminHistoryDetail
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AdminHistoryDetail(
                    subjectName: c['name']!,
                    attendanceList: attendanceList,
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

class _CourseCard extends StatelessWidget {
  final String title;
  final String code;
  final VoidCallback onTap;
  const _CourseCard({
    required this.title,
    required this.code,
    required this.onTap,
  });

  static const _blueBorder = Color(0xFFB0C4DE);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _blueBorder, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      code,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.black45),
            ],
          ),
        ),
      ),
    );
  }
}
