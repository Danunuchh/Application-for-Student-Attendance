import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/teacher/student_attendance_detail_page.dart';
import 'package:my_app/components/textbox.dart';
import 'package:url_launcher/url_launcher.dart';

Widget _statChip(String label, int value, Color color) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '$label $value',
      style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
    ),
  );
}

class StudentStat {
  final String studentId;
  final String studentName;
  final int attend;
  final int absent;
  final int leave;
  final int totalClasses;

  StudentStat({
    required this.studentId,
    required this.studentName,
    required this.attend,
    required this.absent,
    required this.leave,
    required this.totalClasses,
  });

  factory StudentStat.fromJson(Map<String, dynamic> json) {
    return StudentStat(
      studentId: json['student_id'],
      studentName: json['student_name'],
      attend: json['attend'],
      absent: json['absent'],
      leave: json['leave'],
      totalClasses: json['total_classes'],
    );
  }
}

const String apiBase = baseUrl;

class DashbordDetailPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;
  final String courseCode;
  final String? year;
  final String? term;
  final String? section;

  const DashbordDetailPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    this.year,
    this.term,
    this.section,
  });

  @override
  State<DashbordDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<DashbordDetailPage> {
  late Future<List<StudentStat>> _future;

  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<void> _showExportDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('เลือกรูปแบบไฟล์'),
          content: const Text('ต้องการ Export เป็นไฟล์อะไร?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportFile('excel');
              },
              child: const Text('Excel (.csv)'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _exportFile('pdf');
              },
              child: const Text('PDF (.pdf)'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _exportFile(String type) async {
    String endpoint = type == 'excel' ? 'report_csv.php' : 'report_pdf.php';

    final uri = Uri.parse(
      '$apiBase/$endpoint',
    ).replace(queryParameters: {'course_id': widget.courseId});

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('ไม่สามารถเปิดลิงก์ export ได้');
    }
  }

  Future<List<StudentStat>> _loadDetail() async {
    final uri = Uri.parse(
      '$apiBase/dashbord.php',
    ).replace(queryParameters: {'type': 'teacher', 'user_id': widget.userId});

    final res = await http.get(uri);

    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final json = jsonDecode(res.body);

    if (json['success'] != true) {
      throw Exception('API error');
    }

    final List courses = json['data'];

    final course = courses.firstWhere(
      (c) => c['course_id'].toString() == widget.courseId,
      orElse: () => null,
    );

    if (course == null || course['students'] == null) {
      return [];
    }

    final List students = course['students'];
    return students.map((e) => StudentStat.fromJson(e)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.courseName,
        actions: [
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Export',
            onPressed: _showExportDialog,
          ),
        ],
      ),
      body: FutureBuilder<List<StudentStat>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snap.hasData || snap.data!.isEmpty) {
            return const Center(child: Text('ไม่มีข้อมูลนักศึกษา'));
          }

          final students = snap.data!;

          int totalAttend = 0;
          int totalLeave = 0;
          int totalAbsent = 0;

          int totalClasses = students.isNotEmpty
              ? students.first.totalClasses
              : 0;

          for (var s in students) {
            totalAttend += s.attend;
            totalLeave += s.leave;
            totalAbsent += s.absent;
          }

          double attendPercent = totalClasses == 0
              ? 0
              : (totalAttend / (totalClasses * students.length)) * 100;

          double leavePercent = totalClasses == 0
              ? 0
              : (totalLeave / (totalClasses * students.length)) * 100;

          double absentPercent = totalClasses == 0
              ? 0
              : (totalAbsent / (totalClasses * students.length)) * 100;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20), // เพิ่ม padding นิดนึง
                margin: const EdgeInsets.only(
                  bottom: 20,
                ), // เว้นช่องว่างล่างเพิ่ม
                decoration: BoxDecoration(
                  color: Colors.white, // 🔥 พื้นหลังขาว
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF3B82F6), // ขอบฟ้าเหมือนเดิม
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'สรุปภาพรวมรายวิชา',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24), // 🔥 เพิ่มจาก 16 → 24

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                      ), // 🔥 เว้นบนล่าง Pie เพิ่ม
                      child: _AttendancePieChart(
                        attendPercent: attendPercent,
                        leavePercent: leavePercent,
                        absentPercent: absentPercent,
                        size: 170,
                        selectedType: _selectedType,
                        totalAttend: totalAttend,
                        totalLeave: totalLeave,
                        totalAbsent: totalAbsent,
                        onTapSegment: (type) {
                          setState(() {
                            if (_selectedType == type) {
                              _selectedType = null;
                            } else {
                              _selectedType = type;
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              ...students.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextBox(
                    title: s.studentName,
                    subtitleWidget: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.studentId,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                children: [
                                  _statChip('เข้า', s.attend, Colors.green),
                                  _statChip('ลา', s.leave, Colors.orange),
                                  _statChip('ขาด', s.absent, Colors.red),
                                  _statChip(
                                    'ทั้งหมด',
                                    s.totalClasses,
                                    Colors.blue,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StudentAttendanceDetailPage(
                            student: s,
                            courseName: widget.courseName,
                            courseCode: widget.courseCode,
                            year: widget.year,
                            term: widget.term,
                            section: widget.section,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            ],
          );
        },
      ),
    );
  }
}

class _AttendancePieChart extends StatelessWidget {
  final double attendPercent;
  final double leavePercent;
  final double absentPercent;
  final double size;
  final Function(String type) onTapSegment;
  final String? selectedType;
  final int totalAttend;
  final int totalLeave;
  final int totalAbsent;

  const _AttendancePieChart({
    required this.attendPercent,
    required this.leavePercent,
    required this.absentPercent,
    required this.onTapSegment,
    required this.selectedType,
    required this.totalAttend,
    required this.totalLeave,
    required this.totalAbsent,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ กำหนด label และ percent ให้ใช้ layout เดียวกันทั้งหมด
    String label;
    String percentText;

    if (selectedType == null) {
      label = 'มาเรียน';
      percentText = '${attendPercent.toStringAsFixed(1)}%';
    } else if (selectedType == 'attend') {
      label = 'มาเรียน';
      percentText = '${attendPercent.toStringAsFixed(1)}%';
    } else if (selectedType == 'leave') {
      label = 'ลา';
      percentText = '${leavePercent.toStringAsFixed(1)}%';
    } else {
      label = 'ขาดเรียน';
      percentText = '${absentPercent.toStringAsFixed(1)}%';
    }

    return GestureDetector(
      onTapUp: (details) {
        final dx = details.localPosition.dx - size / 2;
        final dy = details.localPosition.dy - size / 2;

        final angle = (atan2(dy, dx) + pi / 2 + 2 * pi) % (2 * pi);

        double attendSweep = 2 * pi * (attendPercent / 100);
        double leaveSweep = 2 * pi * (leavePercent / 100);

        if (angle <= attendSweep) {
          onTapSegment('attend');
        } else if (angle <= attendSweep + leaveSweep) {
          onTapSegment('leave');
        } else {
          onTapSegment('absent');
        }
      },
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CustomPaint(
              size: Size(size, size),
              painter: _PieChartPainter(
                attendPercent: attendPercent,
                leavePercent: leavePercent,
                absentPercent: absentPercent,
              ),
            ),

            /// ✅ ตรงกลางวงกลม
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  percentText,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
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
