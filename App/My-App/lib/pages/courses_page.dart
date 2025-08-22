import 'package:flutter/material.dart';
import '../teacher/teacher_qr_page.dart'; // เพิ่ม import

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // Mock data — ภายหลังจะดึงจาก API แทน
  final _courses = const [
    {'id': 1, 'name': 'DATA MINING', 'code': '11256043'},
    {'id': 2, 'name': 'DATABASE SYSTEMS', 'code': '11256016'},
  ];

  int? _selectedCourseId; // กดเลือกไว้เตรียมไปหน้า QR

  // 🟢 ฟังก์ชันนำทางไป TeacherQRPage
  void _goToQR(Map<String, dynamic> c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherQRPage(
          courseId: c['id'] as int,
          courseName: c['name'] as String,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // NEW: ปุ่มย้อนกลับให้ทำงานจริง
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'คลาสเรียน',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        // NEW: ปุ่มสแกน QR (นักศึกษา) ที่ AppBar
        actions: [
          IconButton(
            tooltip: 'สแกน QR (นักศึกษา)',
            onPressed: () => Navigator.pushNamed(context, '/scan'),
            icon: const Icon(Icons.qr_code_scanner_rounded),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final c = _courses[i];
          final selected = _selectedCourseId == c['id'];
          return InkWell(
            onTap: () {
              setState(() => _selectedCourseId = c['id'] as int);
              _goToQR(c); // 🟢 ไปหน้า QR ทันทีเมื่อกดรายวิชา
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? const Color(0xFF99B8F2) : Colors.black12,
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${c['name']}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${c['code']}',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          );
        },
      ),

      // แถบด้านล่างตามดีไซน์ (สีฟ้า + ปุ่มกลางวงกลม)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD4E2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _BarIcon(
                  icon: Icons.home_rounded,
                  selected: true,
                  onTap: () {}, // อยู่หน้า Home แล้ว
                ),
                Expanded(
                  child: Center(
                    child: InkResponse(
                      onTap: () {
                        if (_selectedCourseId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('กรุณาเลือกวิชาก่อน')),
                          );
                          return;
                        }
                        final c = _courses.firstWhere(
                          (e) => e['id'] == _selectedCourseId,
                        );
                        _goToQR(c); // 🟢 ปุ่มกลางก็นำไปหน้า QR ได้
                      },
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 28),
                      ),
                    ),
                  ),
                ),
                _BarIcon(
                  icon: Icons.logout_rounded,
                  selected: false,
                  // NEW: กลับไปหน้า login (ปรับตาม flow ของคุณได้)
                  onTap: () =>
                      Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BarIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Icon(icon, size: 26),
        ),
      ),
    );
  }
}
