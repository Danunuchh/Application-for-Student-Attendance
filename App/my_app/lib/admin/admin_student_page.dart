import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_class_page.dart'; // เพิ่ม import หน้ารายวิชา

class AdminStudentPage extends StatefulWidget {
  const AdminStudentPage({super.key});

  @override
  State<AdminStudentPage> createState() => _AdminStudentsPageState();
}

class _AdminStudentsPageState extends State<AdminStudentPage> {
  final List<Map<String, dynamic>> students = [
    {"id": "65200020", "name": "กวิสรา แซ่เซี้ย", "checked": false},
    {"id": "65200128", "name": "ดนุนุช เกตุทองหลาง", "checked": true},
    {"id": "65200020", "name": "กวิสรา แซ่เซี้ย", "checked": false},
    {"id": "65200128", "name": "ดนุนุช เกตุทองหลาง", "checked": true},
  ];

  String searchText = "";

  // โทนสี
  static const _blueBorder = Color(0xFFB0C4DE);
  static const _plusBlue = Color(0xFF5C8DFF);
  static const _cardShadow = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    final filtered = students
        .where(
          (s) =>
              s["id"].toString().contains(searchText) ||
              s["name"].toString().contains(searchText),
        )
        .toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "จัดการนักศึกษา",
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          // ปุ่มบวก -> ไปหน้าเพิ่มนักศึกษา และรอผลกลับมา
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () async {
                final newStudent = await Navigator.pushNamed(
                  context,
                  '/add_student',
                );
                if (newStudent is Map<String, dynamic>) {
                  setState(() => students.insert(0, newStudent));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('เพิ่มนักศึกษาเรียบร้อย')),
                  );
                }
              },
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: _plusBlue,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: _cardShadow,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
        child: Column(
          children: [
            // กล่องค้นหา (กึ่งกลาง)
            Align(
              alignment: Alignment.center,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 260),
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _blueBorder, width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (v) => setState(() => searchText = v),
                          decoration: const InputDecoration(
                            hintText: "ค้นหานักศึกษา",
                            isCollapsed: true,
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(fontSize: 14.5),
                        ),
                      ),
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(11),
                          border: Border.all(color: _blueBorder, width: 1.1),
                        ),
                        child: const Icon(Icons.search, size: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // รายการนักศึกษา
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final s = filtered[index];
                  final checked = s["checked"] == true;

                  // เชื่อม ClassPage เมื่อแตะการ์ด
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClassPage(
                              studentId: s["id"],
                              studentName: s["name"],
                              Function: (context) {},
                            ),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        padding: const EdgeInsets.fromLTRB(16, 14, 14, 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _blueBorder, width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: _cardShadow,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ซ้าย: รหัส + ชื่อ
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    s["id"],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    s["name"],
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // ขวา: สถานะ + ถังขยะ
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  checked ? "เช็กชื่อ" : "ไม่ได้เช็กชื่อ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: checked ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.redAccent,
                                    size: 22,
                                  ),
                                  onPressed: () =>
                                      setState(() => students.removeAt(index)),
                                  tooltip: 'ลบ',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
