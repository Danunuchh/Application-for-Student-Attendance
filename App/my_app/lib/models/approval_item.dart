import 'package:my_app/models/subject.dart';

/// ✅ ใช้เก็บข้อมูลแต่ละใบลา (โยงกับ Subject)
class ApprovalItem {
  final Subject subject;     // วิชาที่ลา (เชื่อมกับโมเดล Subject)
  final String leaveType;    // ประเภทการลา เช่น "ลากิจ" "ลาป่วย"
  final DateTime date;       // วันที่ลา
  final String reason;       // เหตุผล/หมายเหตุ
  final String? pdfName;     // ชื่อไฟล์แนบ (ถ้ามี)
  final String status;       // สถานะ เช่น "รออนุมัติ", "อนุมัติ", "ไม่อนุมัติ"
  final String students;     // ชื่อ/รหัสนักศึกษาที่ลา

  const ApprovalItem({
    required this.subject,
    required this.leaveType,
    required this.date,
    required this.reason,
    required this.students,
    this.pdfName,
    this.status = 'รออนุมัติ',
  });

  /// ✅ แปลงเป็น JSON (ส่งให้ backend หรือเก็บ local)
  Map<String, dynamic> toJson() => {
        'subject': subject.toJson(),
        'leaveType': leaveType,
        'date': date.toIso8601String(),
        'reason': reason,
        'students': students,
        'pdfName': pdfName,
        'status': status,
      };

  /// ✅ สร้างอ็อบเจ็กต์จาก JSON (ตอนโหลดกลับจากฐานข้อมูล)
  factory ApprovalItem.fromJson(Map<String, dynamic> json) => ApprovalItem(
        subject: Subject.fromJson(json['subject']),
        leaveType: json['leaveType'] ?? '',
        date: DateTime.parse(json['date']),
        reason: json['reason'] ?? '',
        students: json['students'] ?? '',
        pdfName: json['pdfName'],
        status: json['status'] ?? 'รออนุมัติ',
      );

  /// ✅ toString เพื่อ debug ดูง่ายขึ้น
  @override
  String toString() {
    return 'ApprovalItem(${subject.title}, $leaveType, $date, $status)';
  }
}
