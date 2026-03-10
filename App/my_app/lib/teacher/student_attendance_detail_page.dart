import 'dart:math';
import 'package:flutter/material.dart';

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/teacher/dashbord_detail_page.dart';

class StudentAttendanceDetailPage extends StatelessWidget {
  final StudentStat student;
  final String courseName;
  final String courseCode;
  final String? year;
  final String? term;
  final String? section;

  const StudentAttendanceDetailPage({
    super.key,
    required this.student,
    required this.courseName,
    required this.courseCode,
    this.year,
    this.term,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    final int total = student.totalClasses;
    final int attend = student.attend;
    final int absent = student.absent;
    final int leave = student.leave;

    final double attendPercent = total > 0 ? (attend / total) * 100 : 0;
    final double absentPercent = total > 0 ? (absent / total) * 100 : 0;
    final double leavePercent = total > 0 ? (leave / total) * 100 : 0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'รายละเอียดการเข้าเรียน'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== ชื่อรายวิชา =====
            Text(
              '$courseCode  $courseName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            Text(
              'ปีการศึกษา ${year ?? '-'} | ภาคเรียน ${term ?? '-'} | Sec ${section ?? '-'}',
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),

            const SizedBox(height: 16),

            /// ===== CARD =====
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// ชื่อนักศึกษา
                    Text(
                      student.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('รหัสนักศึกษา : ${student.studentId}'),

                    const SizedBox(height: 40),

                    /// ===== PIE CHART =====
                    Center(
                      child: _AttendancePieChart(
                        attendPercent: attendPercent,
                        leavePercent: leavePercent,
                        absentPercent: absentPercent,
                        size: 140,
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Divider(),

                    _infoRow(
                      'เข้าเรียน',
                      '${attend} ครั้ง (${attendPercent.toStringAsFixed(0)}%)',
                      Colors.green,
                    ),
                    _infoRow(
                      'ลาเรียน',
                      '${leave} ครั้ง (${leavePercent.toStringAsFixed(0)}%)',
                      Colors.orange,
                    ),
                    _infoRow(
                      'ขาดเรียน',
                      '${absent} ครั้ง (${absentPercent.toStringAsFixed(0)}%)',
                      Colors.red,
                    ),
                    _infoRow('จำนวนคาบทั้งหมด', '$total คาบ', Colors.blue),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ================== PIE CHART ==========================
/// =======================================================

class _AttendancePieChart extends StatelessWidget {
  final double attendPercent;
  final double leavePercent;
  final double absentPercent;
  final double size;

  const _AttendancePieChart({
    required this.attendPercent,
    required this.leavePercent,
    required this.absentPercent,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PieChartPainter(
          attendPercent: attendPercent,
          leavePercent: leavePercent,
          absentPercent: absentPercent,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('เข้าเรียน', style: TextStyle(fontSize: 12)),
              Text(
                '${attendPercent.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartPainter extends CustomPainter {
  final double attendPercent;
  final double leavePercent;
  final double absentPercent;

  _PieChartPainter({
    required this.attendPercent,
    required this.leavePercent,
    required this.absentPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.18
      ..strokeCap = StrokeCap.round;

    double start = -pi / 2;

    // เข้าเรียน (เขียว)
    paint.color = Colors.green;
    double attendSweep = 2 * pi * (attendPercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      attendSweep,
      false,
      paint,
    );
    start += attendSweep;

    // ลา (ส้ม)
    paint.color = Colors.orange;
    double leaveSweep = 2 * pi * (leavePercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      leaveSweep,
      false,
      paint,
    );
    start += leaveSweep;

    // ขาด (แดง)
    paint.color = Colors.red;
    double absentSweep = 2 * pi * (absentPercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      start,
      absentSweep,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
