import 'package:flutter/material.dart';
import 'pending_approvals_page.dart'; // ใช้ enum/สีเดิมได้ ถ้าไม่มีก็ตัดออก

class ApprovalDetail {
  final DateTime date;
  final String subject;
  final String students; // ข้อความรวม เช่น "65200128 ณนุช & 65200020 กวิสรา"
  final String leaveType; // ประเภทการลา
  final String reason; // หมายเหตุ
  final ApprovalStatus status;

  const ApprovalDetail({
    required this.date,
    required this.subject,
    required this.students,
    required this.leaveType,
    required this.reason,
    this.status = ApprovalStatus.pending,
  });
}

class ApprovalDetailPage extends StatelessWidget {
  const ApprovalDetailPage({super.key, required this.detail});
  final ApprovalDetail detail;

  static const _ink = Color(0xFF1F2937);
  static const _sub = Color(0xFF9CA3AF);
  static const _green = Color(0xFF20A445);
  static const _red = Color(0xFFE53935);
  static const _border = Color(0xFF9DBAF6);

  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ ${d.day}/${d.month}/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'เอกสารรออนุมัติ',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        children: [
          Text(
            thShortDate(detail.date),
            style: const TextStyle(fontSize: 16, color: _ink),
          ),
          const SizedBox(height: 16),
          Text(
            'วิชา : ${detail.subject}',
            style: const TextStyle(
              fontSize: 16,
              color: _ink,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),

          // กล่องไอคอน PDF
          Center(
            child: Container(
              width: 140,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: _ink.withOpacity(.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.insert_drive_file_outlined, size: 56, color: _ink),
                  SizedBox(height: 12),
                  Text(
                    'PDF',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ปุ่ม อนุมัติ / ไม่อนุมัติ
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pillButton(
                text: 'อนุมัติ',
                color: _green,
                onTap: () {
                  // TODO: call approve API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กดอนุมัติ (ดัมมี่)')),
                  );
                },
              ),
              const SizedBox(width: 16),
              _pillButton(
                text: 'ไม่อนุมัติ',
                color: _red,
                onTap: () {
                  // TODO: call reject API
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กดไม่อนุมัติ (ดัมมี่)')),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 28),
          Text(
            detail.students,
            style: const TextStyle(fontSize: 16, color: _ink),
          ),
          const SizedBox(height: 16),
          _kv('ประเภทการลา', detail.leaveType),
          const SizedBox(height: 10),
          _kv('หมายเหตุการลา', detail.reason),
        ],
      ),
    );
  }

  static Widget _pillButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: _border),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$k :',
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: _ink,
        ),
      ),
      const SizedBox(height: 4),
      Text(v, style: const TextStyle(fontSize: 15, color: _ink)),
    ],
  );
}
