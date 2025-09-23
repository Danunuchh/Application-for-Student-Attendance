import 'package:flutter/material.dart';

class ApprovalDetailPage extends StatelessWidget {
  final Map<String, String> item;
  const ApprovalDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final date = item["date"] ?? "";
    final subject = item["subject"] ?? "";
    final students = item["students"] ?? "";
    final leaveType = item["leaveType"] ?? "-";
    final reason = item["reason"] ?? "-";
    final status = item["status"] ?? "";

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FF), // พื้นหลังฟ้าอ่อน
      appBar: AppBar(
        leading: const BackButton(color: Colors.black),
        title: const Text(
          "เอกสารรออนุมัติ",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCFE0FF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              Text(
                "วิชา : $subject",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // ไอคอน PDF
              Center(
                child: Column(
                  children: const [
                    Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 120,
                      color: Colors.black87,
                    ),
                    SizedBox(height: 6),
                    Text(
                      "PDF",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(students, style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),

              Text(
                "ประเภทการลา : $leaveType",
                style: const TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),

              Text("เหตุผล : $reason", style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text(
                    "สถานะ : ",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "อนุมัติ" ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
