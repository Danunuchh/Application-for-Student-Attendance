// lib/student/pending_approvals_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'approval_detail_page.dart';

class PendingApprovalsPage extends StatelessWidget {
  final List<Map<String, dynamic>> approvals; // ✅ รับเป็น List<Map>

  const PendingApprovalsPage({super.key, required this.approvals});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const CustomAppBar(title: 'เอกสารที่รออนุมัติ'),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: approvals.length,
        itemBuilder: (context, index) {
          final Map<String, dynamic> item = approvals[index]; // ✅ cast ให้ชัด
          final isApproved = item["status"] == "อนุมัติ";

          return TextBox(
            text: item["subject"] ?? '-', // ✅ TextBox เวอร์ชันคุณรองรับ text
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  item["status"] ?? '-',
                  style: TextStyle(
                    color: isApproved ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right, color: Color(0xFF9E9E9E)),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ApprovalDetailPage(item: item), // ✅ ส่ง Map
                ),
              );
            },
          );
        },
      ),
    );
  }
}
