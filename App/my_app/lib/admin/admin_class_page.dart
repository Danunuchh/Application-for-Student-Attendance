import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_class_edit_page.dart';

class ClassPage extends StatelessWidget {
  const ClassPage({
    super.key,
    this.studentId,
    this.studentName,
    required Null Function(dynamic context) Function,
    //required AdminHistoryPage Function(dynamic context),
  });

  final String? studentId;
  final String? studentName;

  static const _blueBorder = Color(0xFFB0C4DE);
  static const _shadow = Color(0x1A000000);

  // รายวิชาตัวอย่าง
  static const List<Map<String, String>> _classes = [
    {"name": "DATA MINING", "code": "11256043"},
    {"name": "DATABASE SYSTEMS", "code": "11256011"},
  ];

  @override
  Widget build(BuildContext context) {
    final hasStudent = studentName != null && studentName!.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'คลาสเรียน',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: _classes.length + (hasStudent ? 1 : 0),
        itemBuilder: (context, i) {
          // แสดงข้อมูลนักศึกษาด้านบน (ถ้ามี)
          if (hasStudent && i == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'นักศึกษา: $studentName  ${studentId != null ? "($studentId)" : ""}',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            );
          }

          final idx = hasStudent ? i - 1 : i;
          final c = _classes[idx];

          return Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                //ไปหน้าแก้ไขรายวิชา พร้อมส่งค่าเริ่มต้น
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ClassEditPage(
                      name: c['name']!,
                      code: c['code']!,
                      credits: '3',
                      teacher: 'ดร.รัตติกกร สมบัติแก้ว',
                      startTime: '17:00',
                      endTime: '20:00',
                      room: 'E107',
                      attendCount: '',
                    ),
                  ),
                );

                // ถ้าหน้าแก้ไขส่งค่ากลับมา (เช่นกดบันทึก/ลบ)
                if (result is Map) {
                  // คุณจะอัปเดตรายการ/ลบได้ที่นี่ (เดโม่เป็น snackbar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'อัปเดตข้อมูลคลาส: ${result['name'] ?? c['name']}',
                      ),
                    ),
                  );
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _blueBorder),
                  boxShadow: const [
                    BoxShadow(
                      color: _shadow,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c['code']!,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: Colors.black54,
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
}
