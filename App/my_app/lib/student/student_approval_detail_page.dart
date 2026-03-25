import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/config.dart';
import 'package:my_app/common/pdf_viewer_page.dart' as pdf;
import 'package:my_app/common/image_viewer_page.dart' as img;

const String apiBase = baseUrl;

enum ApprovalStatus { pending, approved, rejected }

class ApprovalDetail {
  final String id;
  final DateTime date;
  final String subject;
  final String students;
  final String leaveType;
  final String reason;
  final String? attachment;
  final ApprovalStatus status;

  const ApprovalDetail({
    required this.id,
    required this.date,
    required this.subject,
    required this.students,
    required this.leaveType,
    required this.reason,
    required this.status,
    this.attachment,
  });

  factory ApprovalDetail.fromJson(Map<String, dynamic> json) {
    ApprovalStatus parseStatus(String? s) {
      switch (s) {
        case 'อนุมัติ':
          return ApprovalStatus.approved;
        case 'ไม่อนุมัติ':
          return ApprovalStatus.rejected;
        default:
          return ApprovalStatus.pending;
      }
    }

    DateTime parseDate(String? raw) {
      try {
        return DateTime.parse(raw!);
      } catch (_) {
        return DateTime.now();
      }
    }

    return ApprovalDetail(
      id: json['id'].toString(),
      date: parseDate(json['leave_date']),
      subject: '${json['code'] ?? '-'} ${json['course_name'] ?? ''}',
      students: json['student'] ?? '-',
      leaveType: json['leave_type'] ?? '-',
      reason: json['reason'] ?? '-',
      attachment: json['attachment'],
      status: parseStatus(json['status']),
    );
  }
}

class StudentApprovalDetailPage extends StatefulWidget {
  final String approvalId;

  const StudentApprovalDetailPage({super.key, required this.approvalId});

  @override
  State<StudentApprovalDetailPage> createState() =>
      _StudentApprovalDetailPageState();
}

class _StudentApprovalDetailPageState extends State<StudentApprovalDetailPage> {
  late Future<ApprovalDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<ApprovalDetail> _loadDetail() async {
    final res = await http.get(
      Uri.parse('$apiBase/file_manage.php?type=detail&id=${widget.approvalId}'),
    );

    if (res.statusCode != 200) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    final json = jsonDecode(res.body);

    if (json['success'] != true || json['data'] == null) {
      throw Exception('ไม่พบข้อมูล');
    }

    return ApprovalDetail.fromJson(json['data']);
  }

  Future<void> _cancelLeave() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('ยกเลิกการส่งคำขอลา'),
        content: const Text('ต้องการยกเลิกคำขอลานี้หรือไม่ ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ไม่'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'ยกเลิกการส่ง',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final res = await http.post(
      Uri.parse('$apiBase/file_manage.php?type=cancel'),
      body: {'id': widget.approvalId},
    );

    final json = jsonDecode(res.body);

    if (json['success'] == true) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยกเลิกการส่งคำขอสำเร็จ')));

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยกเลิกไม่สำเร็จ')));
    }
  }

  void _openFile(String fileName) {
    final encoded = Uri.encodeComponent(fileName);
    final url = '$apiBase/uploads/leave/$encoded';

    final ext = fileName.split('.').last.toLowerCase();

    if (ext == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => pdf.PdfViewerPage(url: url)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => img.ImageViewerPage(url: url)),
      );
    }
  }

  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ลา ${d.day}/${d.month}/$yy';
  }

  (String, Color) _statusLabel(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.approved:
        return ('อนุมัติ', Colors.green);
      case ApprovalStatus.rejected:
        return ('ไม่อนุมัติ', Colors.red);
      case ApprovalStatus.pending:
        return ('รออนุมัติ', Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'รายละเอียดการลา'),
      backgroundColor: Colors.white,
      body: FutureBuilder<ApprovalDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return const Center(
              child: Text(
                'โหลดข้อมูลไม่สำเร็จ',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          final d = snap.data!;
          final (statusText, statusColor) = _statusLabel(d.status);

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(thShortDate(d.date), style: const TextStyle(fontSize: 15)),

              const SizedBox(height: 16),

              Text(
                'วิชา : ${d.subject}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              if (d.attachment != null && d.attachment!.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF84A9EA),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.insert_drive_file,
                        size: 60,
                        color: Color(0xFF4A86E8),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        d.attachment!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _openFile(d.attachment!),
                        child: const Text('เปิดเอกสาร'),
                      ),
                    ],
                  ),
                ),

              Row(
                children: [
                  const Text(
                    'สถานะ : ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              Text('นักศึกษา : ${d.students}'),
              const SizedBox(height: 8),
              Text('ประเภทการลา : ${d.leaveType}'),
              const SizedBox(height: 8),
              Text('เหตุผล : ${d.reason}'),

              const SizedBox(height: 30),

              if (d.status == ApprovalStatus.pending)
                Center(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white, // ตัวอักษร + icon สีขาว
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20, // ลดความกว้าง
                      ),
                      minimumSize: const Size(180, 45), // กำหนดขนาดปุ่ม
                    ),
                    onPressed: _cancelLeave,
                    icon: const Icon(Icons.cancel),
                    label: const Text(
                      'ยกเลิกการส่งเอกสาร',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
