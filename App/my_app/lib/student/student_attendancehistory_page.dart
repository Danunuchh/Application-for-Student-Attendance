import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'student_attendancedetail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:my_app/config.dart'; 

const String apiBase =
    '${baseUrl}'; // เปลี่ยนเป็น IP/URL จริงของคุณ

class AttendanceHistoryPage extends StatefulWidget {
  final String userId; // ใช้ userId เพื่อดึงรายวิชา
  const AttendanceHistoryPage({super.key, required this.userId});

  @override
  State<AttendanceHistoryPage> createState() => _AttendanceHistoryPageState();
}

class _AttendanceHistoryPageState extends State<AttendanceHistoryPage> {
  List<Map<String, dynamic>> _courses = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _loading = true);
    try {
      final uri = Uri.parse('$apiBase/courses_api.php').replace(
        queryParameters: {'user_id': widget.userId, 'type': 'show_student'},
      );
      final res = await http.get(uri);
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');

      final jsonData = jsonDecode(res.body);
      if (jsonData['success'] == true && jsonData['data'] != null) {
        final List data = jsonData['data'];
        setState(() => _courses = data.cast<Map<String, dynamic>>());
      } else {
        _showSnack('ไม่พบรายวิชา');
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book_outlined, size: 72, color: Color(0xFF88A8E8)),
            SizedBox(height: 12),
            Text(
              'ยังไม่มีรายวิชา',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: _fetchCourses,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final c = _courses[i];
                  final name = c['name'] ?? '-';
                  final code = c['code'] ?? '-';
                  final courseId = c['id']?.toString() ?? '';

                  return TextBox(
                    text: name,
                    subtitle: code,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AttendanceDetailPage(
                            courseName: name,
                            courseId: courseId,
                            userId: widget.userId, // ✅ ต้องส่งมาด้วย
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    );
  }
}