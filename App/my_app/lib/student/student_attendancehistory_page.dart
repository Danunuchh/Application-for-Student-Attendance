import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'student_attendancedetail_page.dart';

class AttendanceHistoryPage extends StatelessWidget {
  const AttendanceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final courses = const [
      _CourseItem(name: "DATA MINING", code: "11256043"),
      _CourseItem(name: "DATABASE SYSTEMS", code: "11256016"),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final c = courses[i];
          return _CourseCard(
            courseName: c.name,
            courseCode: c.code,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AttendanceDetailPage(courseName: c.name),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// ---- UI Card ----
class _CourseCard extends StatelessWidget {
  final String courseName;
  final String courseCode;
  final VoidCallback? onTap;

  const _CourseCard({
    required this.courseName,
    required this.courseCode,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1,
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      courseName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      courseCode,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseItem {
  final String name;
  final String code;
  const _CourseItem({required this.name, required this.code});
}
