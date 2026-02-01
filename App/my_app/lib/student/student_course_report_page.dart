import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';

import 'dart:math' as math;

class StudentCourseReportPage extends StatelessWidget {
  final String courseId;
  final String courseName;
  final String courseCode;
  final String? section;

  final int totalClasses;
  final int attend;
  final int absent;

  const StudentCourseReportPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    this.section,
    required this.totalClasses,
    required this.attend,
    required this.absent,
  });

  @override
  Widget build(BuildContext context) {
    final int total = totalClasses;
    final int attendCount = attend;
    final int absentCount = absent;

    final double attendPercent = total > 0 ? (attendCount / total) * 100 : 0;
    final double absentPercent = total > 0 ? (absentCount / total) * 100 : 0;

    return Scaffold(
      appBar: const CustomAppBar(title: 'สรุปผลการเข้าเรียน'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ===== ชื่อวิชา =====
            Text(
              courseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              (section == null || section!.isEmpty)
                  ? courseCode
                  : '$courseCode | S.$section',
              style: const TextStyle(color: Colors.black54),
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),

                    /// ===== PIE =====
                    Center(
                      child: _AttendancePieChart(
                        attendPercent: attendPercent,
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
                style: TextStyle(
                  fontSize: 12,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
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

  _PieChartPainter({required this.attendPercent, required this.absentPercent});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.15
      ..strokeCap = StrokeCap.round;

    // 🔴 วงพื้นหลัง (ทั้งหมด = ขาดเรียน)
    paint.color = const Color(0xFFE74848);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi,
      false,
      paint,
    );

    // 🟢 เข้าเรียน
    paint.color = Colors.green;
    final sweepAngle = 2 * math.pi * (attendPercent / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
