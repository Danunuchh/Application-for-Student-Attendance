import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/config.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/teacher/teacher_approval_detail_page.dart';

const String apiBase = baseUrl;

enum ApprovalStatus { approved, rejected, pending }

class ApprovalItem {
  final String id;
  final DateTime date;
  final String title;
  final ApprovalStatus status;

  const ApprovalItem({
    required this.id,
    required this.date,
    required this.title,
    required this.status,
  });

  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    ApprovalStatus parseStatus(String? raw) {
      switch (raw) {
        case 'อนุมัติ':
          return ApprovalStatus.approved;
        case 'ไม่อนุมัติ':
          return ApprovalStatus.rejected;
        default:
          return ApprovalStatus.pending;
      }
    }

    return ApprovalItem(
      id: json['id'].toString(),
      date: DateTime.parse(json['leave_date']),
      title: '${json['code']}  ${json['course_name']}',
      status: parseStatus(json['leave_status']),
    );
  }
}

class PendingApprovalsPage extends StatefulWidget {
  final String userId;
  final String courseId;
  final String courseName;

  const PendingApprovalsPage({
    super.key,
    required this.userId,
    required this.courseId,
    required this.courseName,
  });
  @override
  State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();
}

class _PendingApprovalsPageState extends State<PendingApprovalsPage> {
  late Future<List<ApprovalItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadList();
  }

  Future<List<ApprovalItem>> _loadList() async {
    final res = await http.get(
      Uri.parse(
        '$apiBase/file_manage.php?type=list_by_course'
        '&course_id=${widget.courseId}',
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

    return list.map((e) => ApprovalItem.fromJson(e)).toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = _loadList();
    });
    await _future;
  }

  String _thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ลา ${d.day}/${d.month}/$yy';
  }

  (String, Color) _statusLabel(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.approved:
        return ('อนุมัติ', const Color(0xFF20A445));
      case ApprovalStatus.rejected:
        return ('ไม่อนุมัติ', const Color(0xFFE53935));
      case ApprovalStatus.pending:
        return ('รอดำเนินการ', const Color(0xFF9CA3AF));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.courseName),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ApprovalItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(
              child: Text(
                'โหลดข้อมูลไม่สำเร็จ',
                style: const TextStyle(color: Color(0xFF9CA3AF)),
              ),
            );
          }

          final items = snap.data ?? [];

          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'ยังไม่มีเอกสาร',
                      style: TextStyle(color: Color(0xFF9CA3AF)),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final it = items[i];
                final (label, color) = _statusLabel(it.status);

                return TextBox(
                  title: it.title,
                  subtitle: _thShortDate(it.date),
                  status: label,
                  statusColor: color,
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApprovalDetailPage(approvalId: it.id),
                      ),
                    ).then((_) => _refresh());
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
