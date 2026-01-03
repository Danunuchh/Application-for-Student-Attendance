import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_class_page.dart';

class AdminTeacherPage extends StatefulWidget {
  const AdminTeacherPage({super.key});

  @override
  State<AdminTeacherPage> createState() => _AdminTeacherPageState();
}

class _AdminTeacherPageState extends State<AdminTeacherPage> {
  final List<Map<String, dynamic>> teachers = [
    {"user_id": "1", "name": "ดร.สมชาย ใจดี"},
    {"user_id": "2", "name": "ผศ.สมหญิง รักงาน"},
    {"user_id": "3", "name": "อ.วิชัย สอนดี"},
    {"user_id": "4", "name": "ดร.นิภา เก่งกาจ"},
  ];

  String searchText = "";

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = teachers
        .where(
          (t) => t["name"].toString().contains(searchText),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("จัดการอาจารย์"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ช่องค้นหา
            TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: "ค้นหาอาจารย์",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // รายการอาจารย์
            Expanded(
              child: ListView.builder(
                itemCount: filteredTeachers.length,
                itemBuilder: (context, index) {
                  final teacher = filteredTeachers[index];

                  return Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(teacher["name"]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            teachers.remove(teacher);
                          });
                        },
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ClassPage(
                              studentId: teacher["user_id"],
                              studentName: teacher["name"],
                              Function: (context) {},
                            ),
                          ),
                        );
                      },
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
