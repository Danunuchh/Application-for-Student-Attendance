import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/config.dart'; // N: เพิ่ม import config เพื่อใช้ baseUrl

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
  // โทนสีกราฟ
  static const Color kLightBlue = Color(0xFFABCDFB); // ฟ้าอ่อน
  static const Color kLightRed = Color(0xFFE06E6E); // แดงอ่อน
  static const Color kInk = Color(0xFF1F2937);

  // ตัวเลือกช่วงเวลา
  final _periods = const ["month", "term", "year"]; // ใช้ key ภาษาอังกฤษส่ง API
  String _selectedPeriod = "month";

  late Future<CourseReport> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchReport(period: _selectedPeriod);
  }

  Future<CourseReport> _fetchReport({required String period}) async {
    // 🔵 เปลี่ยน URL ให้เป็นของ Back-end จริงของคุณ
    // ตัวอย่าง API (GET):
    //   GET https://your-server.com/api/course-report?code=11256043&period=month
    //
    // ✅ ตัวอย่าง JSON ที่คาดหวัง:
    // {
    //   "avg_percent": 80.0,
    //   "status_text": "ดีเยี่ยม",
    //   "absent_count": 3,
    //   "late_count": 10,
    //   "present_count": 41,
    //   "absent_count_total": 9   // ถ้ามีรวมไว้ก็โอเค หรือจะส่ง "total_sessions": 50 แล้วให้คำนวณเองก็ได้
    // }
    //
    // หรืออีกแบบ:
    // {
    //   "avg_percent": 80.0,
    //   "status_text": "ดีเยี่ยม",
    //   "absent_count": 3,
    //   "late_count": 10,
    //   "total_sessions": 50,
    //   "present_sessions": 41
    // }

    // N: เปลี่ยนจาก hardcode https://localhost:8000 เป็นใช้ baseUrl จาก config.dart
    final uri = Uri.parse(
      '$baseUrl'
      '?code=${Uri.encodeQueryComponent(widget.courseCode)}'
      '&period=$period',
    );

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! Map<String, dynamic>) {
      throw Exception('รูปแบบข้อมูลไม่ถูกต้อง');
    }

    return CourseReport.fromJson(data);
  }

  void _reload() {
    setState(() {
      _future = _fetchReport(period: _selectedPeriod);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: FutureBuilder<CourseReport>(
        future: _future,
        builder: (context, snap) {
          // สถานะโหลด
          if (snap.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4A86E8)),
            );
          }
          // ผิดพลาด
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'เกิดข้อผิดพลาด: ${snap.error}',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final report = snap.data!;
          final attendShare = report.attendShare;
          final absentShare = report.absentShare;

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ชื่อวิชา/รหัสวิชา — ใช้ Text ปกติ
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.courseName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: kInk,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.courseCode,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                // ตัวเลือกช่วงเวลา
                _DropdownBox<String>(
                  value: _selectedPeriod,
                  items: const ["month", "term", "year"],
                  // แสดง label ไทย แต่ส่ง key อังกฤษ
                  itemBuilder: (val) => switch (val) {
                    "month" => "เดือน",
                    "term" => "ภาคเรียน",
                    "year" => "ปีการศึกษา",
                    _ => val,
                  },
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selectedPeriod = v);
                    _reload();
                  },
                ),

                const SizedBox(height: 16),

                // การ์ดสถิติ
                _StatCard(
                  svgAsset: 'assets/time.svg',
                  title: "เปอร์เซ็นต์การเข้าห้องเรียนของ\nนักศึกษาโดยเฉลี่ย",
                  value: "${report.avgPercent.toStringAsFixed(0)} %",
                ),
                const SizedBox(height: 16),
                _StatCard(
                  svgAsset: 'assets/check_status.svg',
                  title: "สถานะ",
                  value: report.statusText,
                ),
                const SizedBox(height: 16),
                _StatCard(
                  svgAsset: 'assets/cross_circle.svg',
                  title: "จำนวนครั้งที่ขาดเรียน/ภาคเรียน",
                  value: "${report.absentCount}",
                ),
                const SizedBox(height: 16),
                _StatCard(
                  svgAsset: 'assets/exclamation.svg',
                  title: "จำนวนครั้งที่มาสาย/ภาคเรียน",
                  value: "${report.lateCount}",
                ),
                const SizedBox(height: 16),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "สัดส่วนการเข้าห้องเรียน",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                // พายชาร์ต (ใช้ share จาก API)
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
                                fraction: attendShare,
                                color: kLightBlue,
                                label: "เข้าเรียน",
                              ),
                              _PieSlice(
                                fraction: absentShare,
                                color: kLightRed,
                                label: "ขาดเรียน",
                              ),
                            ],
                            labelStyle: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: kInk,
                            ),
                            startAngleRad: -math.pi / 2,
                            labelRadiusFactor: 0.55,
                            lockLargestSliceToCenter: true,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ---------------- Model & Parser ----------------

class CourseReport {
  final double avgPercent;
  final String statusText;
  final int absentCount;
  final int lateCount;
  final double attendShare; // 0..1
  final double absentShare; // 0..1

  CourseReport({
    required this.avgPercent,
    required this.statusText,
    required this.absentCount,
    required this.lateCount,
    required this.attendShare,
    required this.absentShare,
  });

  factory CourseReport.fromJson(Map<String, dynamic> json) {
    // รองรับได้ทั้ง 2 รูปแบบ:
    // 1) ส่ง share มาให้เลย (attend_share, absent_share)
    // 2) ส่ง present/absent/total มา แล้วเราคำนวณ share เอง
    double attendShare = 0, absentShare = 0;

    if (json.containsKey('attend_share') && json.containsKey('absent_share')) {
      attendShare = (json['attend_share'] ?? 0).toDouble();
      absentShare = (json['absent_share'] ?? 0).toDouble();
    } else {
      final int present =
          (json['present_count'] ?? json['present_sessions'] ?? 0) as int;
      final int absent = (json['absent_count_total'] ?? 0) as int;
      final int total = (json['total_sessions'] ?? (present + absent)) as int;
      if (total > 0) {
        attendShare = present / total;
        absentShare = absent / total;
      }
    }

    // ป้องกันไม่ให้เกิน 1.0
    final sum = attendShare + absentShare;
    if (sum > 0 && (sum - 1.0).abs() > 0.001) {
      // นอร์มัลไลซ์เล็กน้อย ถ้า server ส่งมาเพี้ยน
      attendShare = attendShare / sum;
      absentShare = absentShare / sum;
    }

    return CourseReport(
      avgPercent: (json['avg_percent'] ?? 0).toDouble(),
      statusText: (json['status_text'] ?? '').toString(),
      absentCount: (json['absent_count'] ?? 0) as int,
      lateCount: (json['late_count'] ?? 0) as int,
      attendShare: attendShare,
      absentShare: absentShare,
    );
  }
}

/// ---------------- Widgets ย่อย ----------------

class _DropdownBox<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T value)? itemBuilder;
  final ValueChanged<T?> onChanged;

  const _DropdownBox({
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    String labelOf(T v) => itemBuilder != null ? itemBuilder!(v) : v.toString();

    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          dropdownColor: Colors.white,
          items: items
              .map(
                (e) => DropdownMenuItem<T>(value: e, child: Text(labelOf(e))),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String svgAsset;
  final String title;
  final String value;

  const _StatCard({
    required this.svgAsset,
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
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: const Color(0xFFA6CAFA), width: 1.5),
      ),
      child: Row(
        children: [
          // ไอคอน SVG
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFCDE0F9),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              svgAsset,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(
                Color(0xFF1F2937),
                BlendMode.srcIn,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
                height: 1.25,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
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
        pos = center; // ชิ้นใหญ่พิเศษ → วางกลางวง
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
