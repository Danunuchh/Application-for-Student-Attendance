// lib/teacher/dashboard_page.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class AdminTeacherReportPage extends StatefulWidget {
  const AdminTeacherReportPage({
    super.key,
    required this.userId,

    /// โหลดรายวิชาที่อาจารย์สอน
    required this.loadCourses,

    /// โหลดข้อมูลสรุปของวิชาที่เลือก + ช่วงเวลา
    required this.loadDashboard,
  });

  final String userId;

  /// คืนลิสต์วิชาที่อาจารย์คนนั้นสอน
  /// ตัวอย่างผลลัพธ์: [CourseOption(id:'11256043', name:'DATA MINING'), ...]
  final Future<List<CourseOption>> Function(String userId) loadCourses;

  /// คืนข้อมูลสรุปแดชบอร์ดของวิชา + ช่วงเวลา
  final Future<DashboardData> Function({
    required String userId,
    required String courseId,
    required String range, // เดือน / ภาคเรียน / ปี (หรืออะไรก็ได้ตามคุณ)
  })
  loadDashboard;

  @override
  State<AdminTeacherReportPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<AdminTeacherReportPage> {
  // THEME
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFCFE0FF);

  // filters
  final ranges = const ['เดือน', 'ภาคเรียน', 'ปี'];
  String? selectedRange;
  CourseOption? selectedCourse;

  // data state
  late Future<List<CourseOption>> _coursesFuture;
  Future<DashboardData>? _dashFuture;

  @override
  void initState() {
    super.initState();
    selectedRange = ranges.first; // ค่าเริ่มต้น
    _coursesFuture = widget.loadCourses(widget.userId);
  }

  void _loadDashboardIfReady() {
    if (selectedCourse == null || selectedRange == null) return;
    setState(() {
      _dashFuture = widget.loadDashboard(
        userId: widget.userId,
        courseId: selectedCourse!.id,
        range: selectedRange!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'สรุปผลรายงาน'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const Text(
            'ระบบติดตามการเข้าห้องเรียนของนักศึกษา',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 10),

          // ---------- ขั้นที่ 1: เลือกวิชาที่อาจารย์สอน ----------
          FutureBuilder<List<CourseOption>>(
            future: _coursesFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: LinearProgressIndicator(minHeight: 4),
                );
              }
              if (snap.hasError) {
                return _ErrorBox(
                  message: 'โหลดรายวิชาไม่สำเร็จ',
                  onRetry: () {
                    setState(() {
                      _coursesFuture = widget.loadCourses(widget.userId);
                    });
                  },
                );
              }

              final courses = snap.data ?? const <CourseOption>[];
              if (courses.isEmpty) {
                return const _EmptyBox(text: 'ยังไม่มีรายวิชาที่สอน');
              }

              // ตั้งค่าเริ่มต้นถ้ายังไม่ได้เลือก
              selectedCourse ??= courses.first;

              return Row(
                children: [
                  _Dropdown<CourseOption>(
                    value: selectedCourse!,
                    items: courses,
                    toText: (c) => c.name,
                    onChanged: (v) {
                      if (v == null) return;
                      selectedCourse = v;
                      _loadDashboardIfReady();
                    },
                  ),
                  const SizedBox(width: 10),
                  _Dropdown<String>(
                    value: selectedRange!,
                    items: ranges,
                    toText: (s) => s,
                    width: 120,
                    onChanged: (v) {
                      if (v == null) return;
                      selectedRange = v;
                      _loadDashboardIfReady();
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 14),

          // ---------- ขั้นที่ 2: โหลดสรุปของวิชาที่เลือก ----------
          if (_dashFuture == null)
            const _EmptyBox(text: 'โปรดเลือกวิชา/ช่วงเวลาเพื่อดูสรุป')
          else
            FutureBuilder<DashboardData>(
              future: _dashFuture,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: LinearProgressIndicator(minHeight: 4),
                  );
                }
                if (snap.hasError) {
                  return _ErrorBox(
                    message: 'โหลดสรุปไม่สำเร็จ',
                    onRetry: _loadDashboardIfReady,
                  );
                }
                final data = snap.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stat cards
                    _StatCard(
                      title: 'จำนวนนักศึกษา',
                      value: '${data.totalStudents} คน',
                      icon: Icons.group_outlined,
                    ),
                    _StatCard(
                      title: 'เปอร์เซ็นต์การเข้าห้องเรียน',
                      value: '${data.attendanceRate} %',
                      icon: Icons.refresh_outlined,
                    ),
                    _StatCard(
                      title: 'จำนวนครั้งที่มาสาย/ภาคเรียน',
                      value: '${data.latePerTerm}',
                      icon: Icons.priority_high_outlined,
                    ),
                    _StatCard(
                      title: 'จำนวนครั้งที่ขาดเรียน/ภาคเรียน',
                      value: '${data.absentPerTerm}',
                      icon: Icons.close_outlined,
                    ),
                    const SizedBox(height: 8),

                    const Text(
                      'สัดส่วนการเข้าห้องเรียนของนักศึกษา',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),

                    // Pie Chart
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 220,
                            child: CustomPaint(
                              painter: _PiePainter(data.slices),
                              child: const Center(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: data.slices
                                .map(
                                  (s) => _Legend(
                                    color: s.color,
                                    text: '${s.label} ${s.value}%',
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ตารางรายชื่อนักศึกษา
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'รายชื่อนักศึกษา',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        // ตรงนี้ถ้าจะทำ search จริง ให้ย้ายไปชั้นบน + ใส่ state/filter
                        SizedBox(
                          width: 160,
                          child: TextField(
                            decoration: InputDecoration(
                              isDense: true,
                              hintText: 'ค้นหา',
                              suffixIcon: const Icon(Icons.search, size: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: border),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.all(8),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('รหัส')),
                            DataColumn(label: Text('ชื่อ')),
                            DataColumn(label: Text('เปอร์เซ็นต์การเข้าเรียน')),
                            DataColumn(label: Text('มาเรียน')),
                            DataColumn(label: Text('ขาดเรียน')),
                            DataColumn(label: Text('มาสาย')),
                            DataColumn(label: Text('สถานะ')),
                          ],
                          rows: data.students.map((r) {
                            return DataRow(
                              cells: [
                                DataCell(Text(r.id)),
                                DataCell(Text(r.name)),
                                DataCell(Text('${r.att}%')),
                                DataCell(Text('${r.present}')),
                                DataCell(Text('${r.absent}')),
                                DataCell(Text('${r.late}')),
                                DataCell(Text(r.status)),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }
}

/// ---------------- Models ----------------

class CourseOption {
  final String id; // ใช้เป็น courseId สำหรับยิงโหลดสรุป
  final String name; // ชื่อวิชา
  const CourseOption({required this.id, required this.name});
}

class StudentRow {
  final String id;
  final String name;
  final int att; // attendance %
  final int present;
  final int absent;
  final int late;
  final String status;
  const StudentRow({
    required this.id,
    required this.name,
    required this.att,
    required this.present,
    required this.absent,
    required this.late,
    required this.status,
  });

  factory StudentRow.fromJson(Map<String, dynamic> j) => StudentRow(
    id: '${j['id']}',
    name: j['name'] ?? '-',
    att: (j['att'] ?? 0) as int,
    present: (j['present'] ?? 0) as int,
    absent: (j['absent'] ?? 0) as int,
    late: (j['late'] ?? 0) as int,
    status: j['status'] ?? '-',
  );
}

class Slice {
  final String label;
  final double value; // %
  final Color color;
  const Slice({required this.label, required this.value, required this.color});

  factory Slice.fromJson(Map<String, dynamic> j) => Slice(
    label: j['label'] ?? '',
    value: (j['value'] as num).toDouble(),
    color: _colorFromHex(j['color'] ?? '#A3E3A0'),
  );
}

class DashboardData {
  final int totalStudents;
  final int latePerTerm;
  final int absentPerTerm;
  final int attendanceRate; // %
  final List<Slice> slices; // pie chart
  final List<StudentRow> students;

  const DashboardData({
    required this.totalStudents,
    required this.latePerTerm,
    required this.absentPerTerm,
    required this.attendanceRate,
    required this.slices,
    required this.students,
  });

  factory DashboardData.fromJson(Map<String, dynamic> j) => DashboardData(
    totalStudents: (j['totalStudents'] ?? 0) as int,
    latePerTerm: (j['latePerTerm'] ?? 0) as int,
    absentPerTerm: (j['absentPerTerm'] ?? 0) as int,
    attendanceRate: (j['attendanceRate'] ?? 0) as int,
    slices: ((j['slices'] ?? []) as List)
        .map((e) => Slice.fromJson(e as Map<String, dynamic>))
        .toList(),
    students: ((j['students'] ?? []) as List)
        .map((e) => StudentRow.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

/// ---------------- Widgets ----------------

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) toText;
  final ValueChanged<T?> onChanged;
  final double? width;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.toText,
    required this.onChanged,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? 220,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _DashboardPageState.border),
          borderRadius: BorderRadius.circular(10),
        ),
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          underline: const SizedBox.shrink(),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(toText(e))))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _DashboardPageState.border),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: _DashboardPageState.sub),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: _DashboardPageState.ink,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PiePainter extends CustomPainter {
  final List<Slice> slices;
  const _PiePainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromCircle(
      center: size.center(Offset.zero),
      radius: math.min(size.width, size.height) / 2 - 8,
    );
    final paint = Paint()..style = PaintingStyle.fill;
    double startRadian = -math.pi / 2;

    final total = slices.fold<double>(0, (p, s) => p + s.value);
    if (total <= 0) {
      // วาดวงกลมเทาอ่อนกรณีไม่มีข้อมูล
      paint.color = const Color(0xFFE5E7EB);
      canvas.drawArc(rect, 0, 2 * math.pi, true, paint);
    } else {
      for (final s in slices) {
        final sweep = (s.value / total) * 2 * math.pi;
        paint.color = s.color;
        canvas.drawArc(rect, startRadian, sweep, true, paint);
        startRadian += sweep;
      }
    }

    // inner hole
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      size.center(Offset.zero),
      (math.min(size.width, size.height) / 2) - 40,
      holePaint,
    );

    // biggest slice label
    if (slices.isNotEmpty) {
      final biggest = slices.reduce((a, b) => a.value >= b.value ? a : b);
      final tp = TextPainter(
        text: TextSpan(
          text: '${biggest.value.toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, size.center(Offset(-tp.width / 2, -tp.height / 2)));
    }
  }

  @override
  bool shouldRepaint(covariant _PiePainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _Legend extends StatelessWidget {
  final Color color;
  final String text;
  const _Legend({required this.color, required this.text});
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }
}

class _EmptyBox extends StatelessWidget {
  final String text;
  const _EmptyBox({required this.text});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      alignment: Alignment.center,
      child: Text(text, style: const TextStyle(color: _DashboardPageState.sub)),
    );
  }
}

class _ErrorBox extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorBox({required this.message, this.onRetry});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: Colors.red)),
        if (onRetry != null) ...[
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ],
    );
  }
}

/// ---------------- utils ----------------
Color _colorFromHex(String hex) {
  var v = hex.replaceAll('#', '').trim();
  if (v.length == 6) v = 'FF$v';
  return Color(int.parse(v, radix: 16));
}
