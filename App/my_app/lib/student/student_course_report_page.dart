import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:my_app/components/custom_appbar.dart';

class StudentCourseReportPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String? year;
  final String? term;
  final String? section;

  final int totalClasses;
  final int attend;
  final int leave;
  final int absent;

  const StudentCourseReportPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.totalClasses,
    required this.attend,
    required this.leave,
    required this.absent,
    this.year,
    this.term,
    this.section,
  });

  @override
  Widget build(BuildContext context) {
    final int total = totalClasses;
    final int attendCount = attend;
    final int leaveCount = leave;
    final int absentCount = absent;

    final double attendPercent = total > 0 ? (attendCount / total) * 100 : 0;
    final double leavePercent = total > 0 ? (leaveCount / total) * 100 : 0;
    final double absentPercent = total > 0 ? (absentCount / total) * 100 : 0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'สรุปผลการเข้าเรียน'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$courseCode  $courseName',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),

            Text(
              'ปีการศึกษา ${year ?? '-'} | ภาคเรียน ${term ?? '-'} | Sec ${section ?? '-'}',
              style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
            ),
            const SizedBox(height: 16),

            Card(
              color: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(
                  color: Color(0xFF84A9EA),
                  width: 1.5,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),

                    Center(
                      child: _AttendancePieChart(
                        attendPercent: attendPercent,
                        leavePercent: leavePercent,
                        absentPercent: absentPercent,
                        size: 120,
                      ),
                    ),

                    const SizedBox(height: 24),
                    const Divider(),

                    _infoRow(
                      'เข้าเรียน',
                      '$attendCount ครั้ง (${attendPercent.toStringAsFixed(0)}%)',
                      Colors.green,
                    ),

                    _infoRow(
                      'ลา',
                      '$leaveCount ครั้ง (${leavePercent.toStringAsFixed(0)}%)',
                      Colors.orange,
                    ),

                    _infoRow(
                      'ขาดเรียน',
                      '$absentCount ครั้ง (${absentPercent.toStringAsFixed(0)}%)',
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
          child: Text(
            '${attendPercent.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
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
    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    double start = -math.pi / 2;

    paint.color = Colors.green;
    final attendSweep = 2 * math.pi * (attendPercent / 100);
    canvas.drawArc(rect, start, attendSweep, false, paint);
    start += attendSweep;

    paint.color = Colors.orange;
    final leaveSweep = 2 * math.pi * (leavePercent / 100);
    canvas.drawArc(rect, start, leaveSweep, false, paint);
    start += leaveSweep;

    paint.color = Colors.red;
    final absentSweep = 2 * math.pi * (absentPercent / 100);
    canvas.drawArc(rect, start, absentSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
