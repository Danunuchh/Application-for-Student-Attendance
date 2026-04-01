import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/button.dart';
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

    return ApprovalDetail(
      id: json['id'].toString(),
      date: DateTime.parse(json['leave_date']),
      subject: '${json['code']} ${json['course_name']}',
      students: json['student'] ?? '-',
      leaveType: json['leave_type'] ?? '-',
      reason: json['reason'] ?? '-',
      attachment: json['attachment'],
      status: parseStatus(json['status']),
    );
  }
}

class ApprovalDetailPage extends StatefulWidget {
  final String approvalId;

  const ApprovalDetailPage({super.key, required this.approvalId});

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  late Future<ApprovalDetail> _future;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _future = _loadDetail();
  }

  Future<ApprovalDetail> _loadDetail() async {
    final res = await http.get(
      Uri.parse('$apiBase/file_manage.php?type=detail&id=${widget.approvalId}'),
    );

    final json = jsonDecode(res.body);

    if (json['success'] != true) {
      throw Exception('โหลดข้อมูลไม่สำเร็จ');
    }

    return ApprovalDetail.fromJson(json['data']);
  }

  void _openFile(String fileName) {
    final encoded = Uri.encodeComponent(fileName);

    final url = '$apiBase/uploads/leave/$encoded';

    print('FILE URL: $url');

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

  Future<void> _confirmUpdate(String type) async {
    String title;
    String message;
    Color color;

    if (type == 'approve') {
      title = 'ยืนยันการอนุมัติ';
      message = 'ต้องการอนุมัติเอกสารนี้ใช่หรือไม่';
      color = Colors.green;
    } else {
      title = 'ยืนยันการไม่อนุมัติ';
      message = 'ต้องการไม่อนุมัติเอกสารนี้ใช่หรือไม่';
      color = Colors.red;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: const Text('ยืนยัน'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _updateStatus(type);
    }
  }

  Future<void> _updateStatus(String type) async {
    setState(() => _busy = true);

    await http.post(
      Uri.parse('$apiBase/file_manage.php?type=$type'),
      body: {'id': widget.approvalId},
    );

    if (!mounted) return;

    Navigator.pop(context, {'updated': true});
  }

  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ลา ${d.day}/${d.month}/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'รายละเอียดของเอกสาร'),
      backgroundColor: Colors.white,
      body: FutureBuilder<ApprovalDetail>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final d = snap.data!;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(thShortDate(d.date)),
              const SizedBox(height: 16),

              Text(
                'วิชา : ${d.subject}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 24),

              if (d.attachment != null)
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
                      CustomButton(
                        text: 'เปิดเอกสาร',
                        onPressed: () => _openFile(d.attachment!),
                        backgroundColor: const Color(0xFF4A86E8),
                        textColor: Colors.white,
                      ),
                    ],
                  ),
                ),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                    text: 'อนุมัติ',
                    onPressed: _busy ? null : () => _confirmUpdate('approve'),
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    loading: _busy,
                  ),
                  const SizedBox(width: 16),
                  CustomButton(
                    text: 'ไม่อนุมัติ',
                    onPressed: _busy ? null : () => _confirmUpdate('reject'),
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                    loading: false,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('นักศึกษา : ${d.students}'),
              const SizedBox(height: 8),
              Text('ประเภทการลา : ${d.leaveType}'),
              const SizedBox(height: 8),
              Text('หมายเหตุ : ${d.reason}'),
            ],
          );
        },
      ),
    );
  }
}
