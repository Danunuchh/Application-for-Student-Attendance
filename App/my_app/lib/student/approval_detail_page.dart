import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class ApprovalDetailPage extends StatelessWidget {
  final Map<String, dynamic> item; // ✅ รับทุกชนิด
  const ApprovalDetailPage({super.key, required this.item});

  bool _isPdf(String? pathOrName) {
    if (pathOrName == null) return false;
    final lower = pathOrName.toLowerCase();
    return lower.endsWith('.pdf');
  }

  bool _isImage(String? pathOrName) {
    if (pathOrName == null) return false;
    final lower = pathOrName.toLowerCase();
    return lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg');
  }

  Widget _buildAttachment(BuildContext context) {
    // รองรับทั้ง bytes และ path
    final Uint8List? fileBytes = item['fileBytes'] as Uint8List?;
    final String? filePath = item['filePath'] as String?;
    final String? fileName = item['fileName']?.toString() ?? filePath?.split('/').last;

    // 1) กรณีมี bytes (มาเองจาก FilePicker.bytes)
    if (fileBytes != null) {
      if (_isPdf(fileName)) {
        return SizedBox(
          height: 360,
          child: SfPdfViewer.memory(fileBytes),
        );
      } else if (_isImage(fileName)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(fileBytes, height: 220, fit: BoxFit.contain),
        );
      }
    }

    // 2) กรณีมี path (แสดงจากไฟล์ในเครื่อง)
    if (filePath != null && File(filePath).existsSync()) {
      if (_isPdf(filePath)) {
        return SizedBox(
          height: 360,
          child: SfPdfViewer.file(File(filePath)),
        );
      } else if (_isImage(filePath)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(File(filePath), height: 220, fit: BoxFit.contain),
        );
      }

      // ไม่ใช่ pdf / image → ให้ปุ่มเปิดด้วยแอปอื่น
      return Column(
        children: [
          const Icon(Icons.insert_drive_file, size: 80, color: Colors.black54),
          const SizedBox(height: 8),
          Text(fileName ?? 'ไฟล์แนบ', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => OpenFilex.open(filePath),
            icon: const Icon(Icons.open_in_new),
            label: const Text('เปิดไฟล์'),
          ),
        ],
      );
    }

    // 3) ไม่มีไฟล์/หาไม่เจอ → fallback เดิม
    return Column(
      children: const [
        Icon(Icons.picture_as_pdf_outlined, size: 120, color: Colors.black87),
        SizedBox(height: 6),
        Text('ไม่มีไฟล์แนบ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final String date = (item["date"] ?? "").toString();
    final String subject = (item["subject"] ?? "").toString();
    final String students = (item["students"] ?? "").toString();
    final String leaveType = (item["leaveType"] ?? "-").toString();
    final String reason = (item["reason"] ?? "-").toString();
    final String status = (item["status"] ?? "").toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const CustomAppBar(title: 'รายละเอียดเอกสารลา'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFFA6CAFA), width: 1.5),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 6,
                spreadRadius: 2,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(date, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),

              Text("วิชา : $subject",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),

              // 👇 แสดงไฟล์แนบจริง
              Center(child: _buildAttachment(context)),
              const SizedBox(height: 24),

              if (students.isNotEmpty) ...[
                Text(students, style: const TextStyle(fontSize: 15)),
                const SizedBox(height: 16),
              ],
              Text("ประเภทการลา : $leaveType", style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 16),
              Text("เหตุผล : $reason", style: const TextStyle(fontSize: 15)),
              const SizedBox(height: 24),

              Row(
                children: [
                  const Text("สถานะ : ",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: status == "อนุมัติ"
                          ? Colors.green
                          : status == "ไม่อนุมัติ"
                              ? Colors.red
                              : Colors.orange,
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
