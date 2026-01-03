import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class AdminTeacherPage extends StatefulWidget {
  const AdminTeacherPage({super.key});

  @override
  State<AdminTeacherPage> createState() => _AdminTeacherPageState();
}

class _AdminTeacherPageState extends State<AdminTeacherPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'จัดการอาจารย์',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'รายการอาจารย์',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // ตัวอย่างจำนวนอาจารย์
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text('อาจารย์ ${index + 1}'),
                      subtitle: Text('อีเมล: teacher${index + 1}@uni.com'),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          // TODO: เปิดหน้าจอแก้ไขข้อมูลอาจารย์
                        },
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
