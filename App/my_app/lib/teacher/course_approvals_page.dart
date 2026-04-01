import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'pending_approvals_page.dart';

const String apiBase = baseUrl;

class CourseItem {
  final String id;
  final String code;
  final String name;
  final String year;
  final String term;
  final String section;

  const CourseItem({
    required this.id,
    required this.code,
    required this.name,
    required this.year,
    required this.term,
    required this.section,
  });

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    return CourseItem(
      id: json['id'].toString(),
      code: json['code'] ?? '',
      name: json['course_name'] ?? '',
      year: json['year']?.toString() ?? '-',
      term: json['term']?.toString() ?? '-',
      section: json['section']?.toString() ?? '-',
    );
  }
}

class CourseApprovalPage extends StatefulWidget {
  final String userId;

  const CourseApprovalPage({super.key, required this.userId});

  @override
  State<CourseApprovalPage> createState() => _CourseApprovalPageState();
}

class _CourseApprovalPageState extends State<CourseApprovalPage> {
  late Future<List<CourseItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadCourses();
  }

  Future<List<CourseItem>> _loadCourses() async {
    final res = await http.get(
      Uri.parse(
        '$apiBase/file_manage.php?type=course_list&user_id=${widget.userId}',
      ),
    );

    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final json = jsonDecode(res.body);

    if (json['success'] != true || json['data'] == null) {
      return [];
    }

    final List list = json['data'];

    return list.map((e) => CourseItem.fromJson(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadCourses();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'เอกสารที่รอการอนุมัติ'),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<CourseItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(
              child: Text(
                'โหลดข้อมูลไม่สำเร็จ',
                style: TextStyle(color: Color(0xFF9CA3AF)),
              ),
            );
          }

          final courses = snap.data ?? [];

          if (courses.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 72,
                              color: Color(0xFF88A8E8),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'ยังไม่มีรายวิชา',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final course = courses[i];

                return TextBox(
                  title: '${course.code}  ${course.name}',
                  subtitle:
                      'ปีการศึกษา ${course.year} | ภาคเรียน ${course.term} | Sec ${course.section}',
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PendingApprovalsPage(
                          userId: widget.userId,
                          courseId: course.id,
                          courseName: course.name,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
