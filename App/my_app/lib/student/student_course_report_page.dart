import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class StudentCourseReportPage extends StatefulWidget {
  final String courseName;
  final String courseCode;
  const StudentCourseReportPage({
    super.key,
    required this.courseName,
    required this.courseCode,
  });

  @override
  State<StudentCourseReportPage> createState() =>
      _StudentCourseReportPageState();
}

class _StudentCourseReportPageState extends State<StudentCourseReportPage> {
  // ฟ้าอ่อน / แดงอ่อน โทนตามภาพตัวอย่าง
  static const Color kLightBlue = Color(0xFFABCDFB); // ฟ้าอ่อน
  static const Color kLightRed = Color(0xFFE06E6E); // แดงอ่อน
  static const Color kInk = Color(0xFF1F2937);

  final _courses = const [
    "DATA MINING",
    "INTERNET OF THINGS AND SMART SYSTEMS",
    "DATABASE SYSTEMS",
  ];
  final _periods = const ["เดือน", "ภาคเรียน", "ปีการศึกษา"];

  late String _selectedCourse = widget.courseName;
  String _selectedPeriod = "เดือน";

  // ---- ดัมมี่ค่าแสดงผล ----
  final double _avgAttendPercent = 80; // %
  final String _statusText = "ดีเยี่ยม";
  final int _absentCountPerTerm = 3;
  final int _lateCountPerTerm = 10;

  // สัดส่วนพาย (ต้องรวม ~1.0)
  final double _attendShare = 0.82;
  final double _absentShare = 0.18;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ชื่อคอร์ส (ย่อย)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 8),
              child: Text(
                "${widget.courseName} (${widget.courseCode})",
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ),

            // เลือกคอร์ส/ช่วงเวลา
            Row(
              children: [
                Expanded(
                  flex: 6,
                  child: _DropdownBox<String>(
                    value: _selectedCourse,
                    items: _courses,
                    onChanged: (v) => setState(() => _selectedCourse = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 4,
                  child: _DropdownBox<String>(
                    value: _selectedPeriod,
                    items: _periods,
                    onChanged: (v) => setState(() => _selectedPeriod = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _StatCard(
              icon: Icons.refresh,
              title: "เปอร์เซ็นต์การเข้าห้องเรียนของ\nนักศึกษาโดยเฉลี่ย",
              value: "${_avgAttendPercent.toStringAsFixed(0)} %",
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.thumb_up_alt_outlined,
              title: "สถานะ",
              value: _statusText,
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.report_problem_outlined,
              title: "จำนวนครั้งที่ขาดเรียน/ภาคเรียน",
              value: "$_absentCountPerTerm",
            ),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.priority_high_rounded,
              title: "จำนวนครั้งที่มาสาย/ภาคเรียน",
              value: "$_lateCountPerTerm",
            ),
            const SizedBox(height: 24),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                "สัดส่วนการเข้าห้องเรียน",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            // การ์ดกราฟ: พื้นหลังขาว ไม่มีเส้นขอบ (ให้คล้ายภาพแรก)
            AspectRatio(
              aspectRatio: 1.2,
              child: Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: SizedBox(
                    width: 260,
                    height: 260,
                    child: CustomPaint(
                      painter: _PiePainter(
                        slices: [
                          _PieSlice(
                            fraction: _attendShare,
                            color: kLightBlue,
                            label: "เข้าเรียน",
                          ),
                          _PieSlice(
                            fraction: _absentShare,
                            color: kLightRed,
                            label: "ขาดเรียน",
                          ),
                        ],
                        labelStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: kInk,
                        ),
                        // ให้เริ่มวาดจาก 12 นาฬิกา (เหมือนภาพ)
                        startAngleRad: -math.pi / 2,
                        // จุดวางป้ายบนชิ้นพาย (0 = ศูนย์กลาง, 1 = ขอบวง)
                        labelRadiusFactor: 0.55,
                        // ถ้าชิ้นหนึ่งใหญ่กว่า 70% จะ “ตรึง” ป้ายไว้กลางวง เพื่อให้คำว่า "เข้าเรียน" อยู่กลาง ๆ
                        lockLargestSliceToCenter: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------- Widgets ย่อย ----------------

class _DropdownBox<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButton<T>(
        value: value,
        isExpanded: true,
        underline: const SizedBox.shrink(),
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        items: items
            .map(
              (e) => DropdownMenuItem<T>(value: e, child: Text(e.toString())),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCFE0FF)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFCDE0F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.loop, color: _StatCard.kInk),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  static const Color kInk = Color(0xFF1F2937);
}

/// ---------------- Pie Chart ----------------

class _PieSlice {
  final double fraction; // 0..1
  final Color color;
  final String label;
  _PieSlice({required this.fraction, required this.color, required this.label});
}

class _PiePainter extends CustomPainter {
  final List<_PieSlice> slices;
  final TextStyle labelStyle;
  final double startAngleRad;
  final double labelRadiusFactor;
  final bool lockLargestSliceToCenter;

  _PiePainter({
    required this.slices,
    required this.labelStyle,
    this.startAngleRad = -math.pi / 2,
    this.labelRadiusFactor = 0.55,
    this.lockLargestSliceToCenter = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = math.min(size.width, size.height) / 2;

    // วาดชิ้นพาย
    final paint = Paint()..style = PaintingStyle.fill;
    double start = startAngleRad;

    // หา slice ที่ใหญ่สุด (ไว้ล็อก label ให้อยู่กลางวง)
    int largestIdx = 0;
    for (int i = 1; i < slices.length; i++) {
      if (slices[i].fraction > slices[largestIdx].fraction) largestIdx = i;
    }

    // 1) วาดพาย
    for (final s in slices) {
      final sweep = s.fraction * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        true,
        paint,
      );
      start += sweep;
    }

    // 2) วาด label ลงบนชิ้นพาย
    start = startAngleRad;
    for (int i = 0; i < slices.length; i++) {
      final s = slices[i];
      final sweep = s.fraction * 2 * math.pi;
      final mid = start + sweep / 2;

      Offset pos;
      if (lockLargestSliceToCenter && i == largestIdx && s.fraction >= 0.7) {
        // ถ้าชิ้นใหญ่มาก — วางคำไว้กลางวง (ให้ได้เอฟเฟกต์แบบภาพแรก)
        pos = center;
      } else {
        final r = radius * labelRadiusFactor;
        pos = center + Offset(math.cos(mid) * r, math.sin(mid) * r);
      }

      _drawTextCentered(canvas, s.label, pos, labelStyle);
      start += sweep;
    }
  }

  void _drawTextCentered(Canvas c, String text, Offset at, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();
    final offset = at - Offset(tp.width / 2, tp.height / 2);
    tp.paint(c, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
