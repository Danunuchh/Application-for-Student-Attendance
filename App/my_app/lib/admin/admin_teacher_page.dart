import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/admin/admin_student_detail_page.dart';

class AdminTeacherPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const AdminTeacherPage({super.key, required this.data});

  @override
  State<AdminTeacherPage> createState() => _AdminTeacherPageState();
}

class _AdminTeacherPageState extends State<AdminTeacherPage> {
  late List<Map<String, dynamic>> teachers;

  @override
  void initState() {
    super.initState();
    teachers = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'อาจารย์'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: teachers.isEmpty
            ? const Center(
                child: Text(
                  'ไม่พบข้อมูล',
                  style: TextStyle(color: Colors.grey),
                ),
              )
            : ListView.builder(
                itemCount: teachers.length,
                itemBuilder: (_, index) {
                  final t = teachers[index];

                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminStudentDetailPage(
                            studentId: t['student_id'] ?? '',
                            fullName: t['full_name'] ?? '',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF84A9EA),
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x1F000000),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t['full_name'] ?? '-',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t['student_id']?.isNotEmpty == true
                                ? t['student_id']
                                : '—',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
