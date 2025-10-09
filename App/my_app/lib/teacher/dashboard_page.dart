import 'dart:math' as math;
import 'package:flutter/material.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // THEME
  static const bg = Color(0xFFFAF6ED); // off-white like the mock
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF6B7280);
  static const border = Color(0xFFCFE0FF);

  // filters (dummy)
  final subjects = const ['DATA MINING', 'DATABASE SYSTEMS', 'AI BASICS'];
  final ranges = const ['เดือน', 'ภาคเรียน', 'ปี'];
  String selectedSubject = 'DATA MINING';
  String selectedRange = 'เดือน';

  // Stats (dummy)
  final int totalStudents = 45;
  final int latePerTerm = 10;
  final int absentPerTerm = 3;
  final int attendanceRate = 80; // %

  // Pie chart (dummy)
  // present 70%, absent 15%, late 15%
  final List<_Slice> slices = const [
    _Slice(label: 'มาเรียน', value: 70, color: Color(0xFFA3E3A0)),
    _Slice(label: 'ขาดเรียน', value: 15, color: Color(0xFFF26A6A)),
    _Slice(label: 'มาสาย', value: 15, color: Color(0xFFF7D37A)),
  ];

  // Table data (dummy)
  final List<_StudentRow> rows = const [
    _StudentRow(
      id: '65200020',
      name: 'กวิสรา แซ่เฮี้ย',
      att: 80,
      present: 10,
      absent: 5,
      late: 1,
      status: 'พอใช้',
    ),
    _StudentRow(
      id: '65200020',
      name: 'กวิสรา แข็งยิ่ง',
      att: 50,
      present: 10,
      absent: 20,
      late: 5,
      status: 'แย่มาก',
    ),
    _StudentRow(
      id: '65200128',
      name: 'ณนุช พรหมทวี',
      att: 92,
      present: 22,
      absent: 1,
      late: 0,
      status: 'ดีมาก',
    ),
    _StudentRow(
      id: '65200105',
      name: 'ธนกร อินทร์ดี',
      att: 67,
      present: 14,
      absent: 6,
      late: 1,
      status: 'พอใช้',
    ),
    _StudentRow(
      id: '65200077',
      name: 'สุพจน์ รุ่งเรือง',
      att: 73,
      present: 16,
      absent: 5,
      late: 1,
      status: 'พอใช้',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "คลาสเรียน",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          const Text(
            'ระบบติดตามการเข้าห้องเรียนของนักศึกษา',
            style: TextStyle(color: sub, fontSize: 13),
          ),
          const SizedBox(height: 10),

          // Filters
          Row(
            children: [
              _Dropdown<String>(
                value: selectedSubject,
                items: subjects,
                onChanged: (v) => setState(() => selectedSubject = v!),
              ),
              const SizedBox(width: 10),
              _Dropdown<String>(
                value: selectedRange,
                items: ranges,
                onChanged: (v) => setState(() => selectedRange = v!),
                width: 110,
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Stat cards
          _StatCard(
            title: 'จำนวนนักศึกษา',
            value: '$totalStudents คน',
            icon: Icons.group_outlined,
          ),
          _StatCard(
            title: 'เปอร์เซ็นต์การเข้าห้องเรียน',
            value: '$attendanceRate %',
            icon: Icons.refresh_outlined,
          ),
          _StatCard(
            title: 'จำนวนครั้งที่มาสาย/ภาคเรียน',
            value: '$latePerTerm',
            icon: Icons.priority_high_outlined,
          ),
          _StatCard(
            title: 'จำนวนครั้งที่ขาดเรียน/ภาคเรียน',
            value: '$absentPerTerm',
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
                    painter: _PiePainter(slices),
                    child: const Center(),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: slices
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

          // Table header + search (dummy)
          Row(
            children: [
              const Expanded(
                child: Text(
                  'รายชื่อนักศึกษา',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
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

          // Scrollable table
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
                rows: rows.map((r) {
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
      ),
    );
  }
}

/// ---------- helpers & widgets ----------

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final double? width;
  const _Dropdown({
    required this.value,
    required this.items,
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
              .map((e) => DropdownMenuItem(value: e, child: Text('$e')))
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

class _Slice {
  final String label;
  final double value;
  final Color color;
  const _Slice({required this.label, required this.value, required this.color});
}

class _PiePainter extends CustomPainter {
  final List<_Slice> slices;
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
    for (final s in slices) {
      final sweep = (s.value / total) * 2 * math.pi;
      paint.color = s.color;
      canvas.drawArc(rect, startRadian, sweep, true, paint);
      startRadian += sweep;
    }

    // inner hole to look clean
    final holePaint = Paint()..color = Colors.white;
    canvas.drawCircle(
      size.center(Offset.zero),
      (math.min(size.width, size.height) / 2) - 40,
      holePaint,
    );

    // percentage label for biggest slice
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

class _StudentRow {
  final String id;
  final String name;
  final int att;
  final int present;
  final int absent;
  final int late;
  final String status;
  const _StudentRow({
    required this.id,
    required this.name,
    required this.att,
    required this.present,
    required this.absent,
    required this.late,
    required this.status,
  });
}
