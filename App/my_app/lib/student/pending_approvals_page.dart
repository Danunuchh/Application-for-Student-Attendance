import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'approval_detail_page.dart';

class PendingApprovalsPage extends StatelessWidget {
  const PendingApprovalsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final approvals = [
      {
        "date": "วันที่ 1/8/68",
        "subject": "DATA WAREHOUSE",
        "status": "อนุมัติ",
        "students": "65200128 ณนุช & 65200020 กวิสรา",
        "leaveType": "ลาออก",
        "reason": "อยากพักผ่อน",
        "pdf": "assets/sample.pdf",
      },
      {
        "date": "วันที่ 1/8/68",
        "subject": "DATABASE SYSTEMS",
        "status": "ไม่อนุมัติ",
        "students": "65200111 สมชาย & 65200112 สมหญิง",
        "leaveType": "ลาป่วย",
        "reason": "เป็นไข้",
        "pdf": "assets/sample.pdf",
      },
    ];

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255), // พื้นหลังฟ้าอ่อน
      appBar: const CustomAppBar(title: 'เอกสารที่รออนุมัติ'),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: approvals.length,
        itemBuilder: (context, index) {
          final item = approvals[index];
          final isApproved = item["status"] == "อนุมัติ";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFCFE0FF), width: 1.5),
              borderRadius: BorderRadius.circular(26), // ทำให้โค้งแบบ capsule
            ),
            child: ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 12,
                horizontal: 20,
              ),
              title: Text(
                item["date"]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item["subject"]!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item["status"]!,
                    style: TextStyle(
                      color: isApproved ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ApprovalDetailPage(item: item),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
