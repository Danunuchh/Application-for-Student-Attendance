import 'package:flutter/material.dart';
import 'teacher_qr_page.dart';
import 'addcourse_page.dart';
import 'course_detail_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // ดัมมี่คอร์ส (แก้ไขได้)
  final List<Map<String, dynamic>> _courses = [
    {'id': 1, 'name': 'DATA MINING', 'code': '11256043'},
    {
      'id': 2,
      'name': 'INTERNET OF THINGS AND SMART SYSTEMS',
      'code': '11256043',
    },
  ];

  // ไปหน้า “รายละเอียดวิชา”
  void _goToDetail(Map<String, dynamic> c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CourseDetailPage(
          courseName: c['name'] as String,
          courseCode: c['code'] as String,
        ),
      ),
    );
  }

  // (ถ้าอยากยังใช้หน้า QR ก็เรียกฟังก์ชันนี้ได้ เช่น long-press)
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

  // ปุ่ม + เพิ่มคอร์ส
  Future<void> _onAddCourse() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(builder: (_) => const AddCoursePage()),
    );
    if (result != null) {
      setState(() {
        _courses.add({
          'id': result['id'],
          'name': result['name'],
          'code': result['code'],
        });
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('เพิ่มวิชาเรียบร้อย')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF88A8E8)),
            onPressed: _onAddCourse,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        itemCount: _courses.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final c = _courses[i];
          return Card(
            color: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFF88A8E8), width: 2),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              title: Text(
                c['name'] as String,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .2,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  c['code'] as String,
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _goToDetail(c), // แตะแล้วไปหน้า “รายละเอียดวิชา”
              // onLongPress: () => _goToQR(c), // (ตัวเลือก) กดค้างไปหน้า QR
            ),
          );
        },
      ),
    );
  }
}
