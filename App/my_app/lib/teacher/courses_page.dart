import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'teacher_qr_page.dart';
import 'addcourse_page.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  final String userId; 
  const CoursesPage({super.key, required this.userId});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {

  // ✅ ลิสต์รายวิชาเริ่ม "ว่าง" เพื่อรอรับจากหน้าเพิ่มวิชา / PHP
  final List<Map<String, dynamic>> _courses = [];

  // ---------------- Actions ----------------

  // ไปหน้า “รายละเอียดวิชา” (และรอฟังผลลบ)
  Future<void> _goToDetail(Map<String, dynamic> c) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(
          courseName: c['name'] as String,
          courseCode: c['code'] as String,
        ),
      ),
    );

    // ถ้าหน้ารายละเอียดส่งสัญญาณลบกลับมา → ลบจากลิสต์นี้
    if (result is Map && result['deleteCourse'] == true) {
      setState(() {
        _courses.removeWhere((x) => x['code'] == result['courseCode']);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ลบรายวิชาเรียบร้อย')),
      );
    }
  }

  // ไปหน้า QR
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

  // เพิ่มคอร์ส (รับค่าจากหน้า AddCoursePage)
  Future<void> _onAddCourse() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddCoursePage()),
    );

    if (result != null) {
      setState(() {
        _courses.add({
          'id': result['id'],         // ควรเป็น int (เช่น timestamp)
          'name': result['name'],     // String
          'code': result['code'],     // String
        });
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เพิ่มวิชาเรียบร้อย')),
      );
    }
  }

  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'คลาสเรียน',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF88A8E8)),
            onPressed: _onAddCourse,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _courses.isEmpty
          ? _emptyState()
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = _courses[i];
                return TextBox(
                  title: c['name'],           // ชื่อวิชา
                  subtitle: c['code'],        // รหัสวิชา
                  onTap: () => _goToDetail(c),
                  // ไอคอนทางขวา: ไปหน้า QR (หรือจะเปลี่ยนเป็น chevron ก็ได้)
                  trailing: IconButton(
                    icon: const Icon(Icons.qr_code_2, color: Color(0xFF9CA3AF)),
                    onPressed: () => _goToQR(c),
                    tooltip: 'QR เช็กชื่อ',
                  ),
                );
              },
            ),
    );
  }

  // หน้าว่างเมื่อยังไม่มีรายวิชา
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.menu_book_outlined, size: 72, color: Color(0xFF88A8E8)),
            const SizedBox(height: 12),
            const Text(
              'ยังไม่มีรายวิชา',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'กดปุ่ม + มุมขวาบนเพื่อเพิ่มรายวิชาใหม่',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
