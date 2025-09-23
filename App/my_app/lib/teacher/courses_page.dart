import 'package:flutter/material.dart';
import 'teacher_qr_page.dart';
import 'addcourse_page.dart'; // <-- เพิ่มไฟล์นี้

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  // เปลี่ยนให้แก้ไขได้ (ไม่ใส่ const)
  final List<Map<String, dynamic>> _courses = [
    {'id': 1, 'name': 'DATA MINING', 'code': '11256043'},
    {
      'id': 2,
      'name': 'INTERNET OF THINGS AND SMART SYSTEMS',
      'code': '11256043',
    },
  ];

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
            icon: const Icon(Icons.add_circle, color: Colors.blue),
            onPressed: _onAddCourse, // <-- เปิดหน้าเพิ่มคอร์ส
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
              onTap: () => _goToQR(c),
            ),
          );
        },
      ),
    );
  }
}
