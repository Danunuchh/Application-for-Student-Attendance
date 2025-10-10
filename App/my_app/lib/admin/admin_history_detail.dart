import 'package:flutter/material.dart';

// โมเดลข้อมูล
class Attendance {
  final String date;
  final String studentId;
  final String studentName;
  final String time;

  Attendance({
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.time,
  });
}

class AdminHistoryDetail extends StatelessWidget {
  final String subjectName;
  final List<Attendance> attendanceList;

  const AdminHistoryDetail({
    super.key,
    required this.subjectName,
    required this.attendanceList,
  });

  static const _blueBorder = Color(0xFFB0C4DE); // สีขอบฟ้าอ่อน

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // พื้นหลังหน้าเป็นขาว
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'ประวัติการเข้าเรียน',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ชื่อวิชาอยู่ตรงกลาง
            Center(
              child: Text(
                'วิชา : $subjectName',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: attendanceList.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final a = attendanceList[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: _blueBorder, width: 1.2),
                      borderRadius: BorderRadius.circular(
                        16,
                      ), // โค้งมนเหมือนภาพ
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              a.date,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${a.studentId} ${a.studentName}',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                        Text(
                          a.time,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
