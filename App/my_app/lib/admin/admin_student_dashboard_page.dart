import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/admin/admin_student_detail_page.dart';

class AdminStudentDashboardPage extends StatelessWidget {
  final String courseName;
  final StudentCourseStat stat;

  const AdminStudentDashboardPage({
    super.key,
    required this.courseName,
    required this.stat,
  });

  @override
  Widget build(BuildContext context) {
    final int total = stat.total;
    final int attend = stat.attend;
    final int leave = stat.leave; 
    final int absent = stat.absent;

    final double attendPercent = total > 0 ? (attend / total) * 100 : 0;
    final double leavePercent = total > 0 ? (leave / total) * 100 : 0;
    final double absentPercent = total > 0 ? (absent / total) * 100 : 0;

    return Scaffold(
      appBar: CustomAppBar(title: courseName),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.studentName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text('รหัสนักศึกษา : ${stat.studentId}'),

                    const SizedBox(height: 40),

                    Center(
                      child: _AttendancePieChart(
                        attendPercent: attendPercent,
                        leavePercent: leavePercent, 
                        absentPercent: absentPercent,
                        size: 120,
                      ),
                    ),

                    const SizedBox(height: 40),
                    const Divider(),

                    _infoRow(
                      'เข้าเรียน',
                      '$attend ครั้ง (${attendPercent.toStringAsFixed(0)}%)',
                      Colors.green,
                    ),

                    _infoRow(
                      'ลา', 
                      '$leave ครั้ง (${leavePercent.toStringAsFixed(0)}%)',
                      Colors.orange,
                    ),

                    _infoRow(
                      'ขาดเรียน',
                      '$absent ครั้ง (${absentPercent.toStringAsFixed(0)}%)',
                      Colors.red,
                    ),

                    _infoRow(
                      'จำนวนคาบทั้งหมด',
                      '$total คาบ',
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

    // 🟢 เข้าเรียน
    paint.color = Colors.green;
    final attendSweep = 2 * math.pi * (attendPercent / 100);
    canvas.drawArc(rect, start, attendSweep, false, paint);
    start += attendSweep;

    // 🟠 ลา
    paint.color = Colors.orange;
    final leaveSweep = 2 * math.pi * (leavePercent / 100);
    canvas.drawArc(rect, start, leaveSweep, false, paint);
    start += leaveSweep;

    // 🔴 ขาด
    paint.color = Colors.red;
    final absentSweep = 2 * math.pi * (absentPercent / 100);
    canvas.drawArc(rect, start, absentSweep, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}