import 'dart:math';
import 'package:flutter/material.dart';

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/teacher/dashbord_detail_page.dart';
// ใช้ StudentStat จากไฟล์นี้ 👆

class StudentAttendanceDetailPage extends StatelessWidget {
  final StudentStat student;
  final String courseName;

  const StudentAttendanceDetailPage({
    super.key,
    required this.student,
    required this.courseName,
  });

  @override
  Widget build(BuildContext context) {
    final int total = student.totalClasses;
    final int attend = student.attend;
    final int absent = student.absent;

    final double attendPercent = total > 0 ? (attend / total) * 100 : 0;
    final double absentPercent = total > 0 ? (absent / total) * 100 : 0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'รายละเอียดการเข้าเรียน'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== ชื่อรายวิชา =====
            Text(
              courseName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// ===== CARD =====
            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20), // มุมโค้ง (ปรับได้)
                side: const BorderSide(
                  color: Color(
                    0xFF84A9EA,
                  ), // 👈 สีเส้นกรอบ (โทนเดียวกับ TextBox)
                  width: 1.5, // 👈 ความหนาเส้น
                ),
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
                        absentPercent: absentPercent,
                        size: 120,
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Divider(),

                    _infoRow(
                      'เข้าเรียน',
                      '${student.attend} ครั้ง (${attendPercent.toStringAsFixed(0)}%)',
                      Colors.green,
                    ),
                    _infoRow(
                      'ขาดเรียน',
                      '${student.absent} ครั้ง (${absentPercent.toStringAsFixed(0)}%)',
                      Colors.red,
                    ),
                    _infoRow(
                      'จำนวนคาบทั้งหมด',
                      '${student.totalClasses} คาบ',
                      Colors.blue,
                    ),
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
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// =======================================================
/// ================== PIE CHART (INLINE) =================
/// =======================================================

class _AttendancePieChart extends StatelessWidget {
  final double attendPercent;
  final double absentPercent;
  final double size;

  const _AttendancePieChart({
    required this.attendPercent,
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
          absentPercent: absentPercent,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'เข้าเรียน',
                style: TextStyle(fontSize: 12, color: Color.fromARGB(255, 0, 0, 0)),
              ),
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
  final double absentPercent;

  _PieChartPainter({
    required this.attendPercent,
    required this.absentPercent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    // 🔴 background (ทั้งหมด)
    paint.color = const Color(0xFFE74848);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      2 * pi,
      false,
      paint,
    );

    // 🟢 attend
    paint.color = Colors.green;
    final sweepAngle = 2 * pi * (attendPercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
