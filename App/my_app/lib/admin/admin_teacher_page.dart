import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_class_page.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';

class AdminTeacherPage extends StatefulWidget {
  const AdminTeacherPage({super.key});

  @override
  State<AdminTeacherPage> createState() => _AdminTeacherPageState();
}

class _AdminTeacherPageState extends State<AdminTeacherPage> {
  static const Color _borderBlue = Color(0xFF88A8E8);

  final List<Map<String, dynamic>> teachers = [
    {"user_id": "1", "name": "ดร.สมชาย ใจดี"},
    {"user_id": "2", "name": "ผศ.สมหญิง รักงาน"},
    {"user_id": "3", "name": "อ.วิชัย สอนดี"},
    {"user_id": "4", "name": "ดร.นิภา เก่งกาจ"},
  ];

  String searchText = "";

  /// ===== ช่องค้นหา =====
  InputDecoration _searchDeco(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),
    suffixIcon: const Icon(Icons.search),
  );

  /// ===== InputDecoration ใน Modal =====
  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
    ),
  );

  /// ===== Modal เพิ่มอาจารย์ =====
  void _openAddTeacherModal() {
    final formKey = GlobalKey<FormState>();
    final idCtl = TextEditingController();
    final nameCtl = TextEditingController();

    bool canSave = false;

    void checkCanSave() {
      canSave = idCtl.text.trim().isNotEmpty && nameCtl.text.trim().isNotEmpty;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'เพิ่มอาจารย์',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: idCtl,
                      decoration: _dec('รหัสอาจารย์'),
                      onChanged: (_) => setModalState(() => checkCanSave()),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกรหัสอาจารย์'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: idCtl,
                      decoration: _dec('คำนำหน้า'),
                      onChanged: (_) => setModalState(() => checkCanSave()),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกคำนำหน้า'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    TextFormField(
                      controller: nameCtl,
                      decoration: _dec('ชื่อ – นามสกุล'),
                      onChanged: (_) => setModalState(() => checkCanSave()),
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกชื่อ–นามสกุล'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        /// ยกเลิก
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const Spacer(),

                        FilledButton.icon(
                          onPressed: () {
                            if (!canSave) return;
                            if (!formKey.currentState!.validate()) return;

                            setState(() {
                              teachers.add({
                                "user_id": idCtl.text.trim(),
                                "name": nameCtl.text.trim(),
                              });
                            });

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('เพิ่มอาจารย์เรียบร้อย'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('บันทึก'),
                          style: FilledButton.styleFrom(
                            backgroundColor: canSave
                                ? const Color(0xFF22C55E)
                                : const Color.fromARGB(255, 188, 246, 219),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTeacher(Map<String, dynamic> teacher) {
    setState(() => teachers.remove(teacher));
  }

  @override
  Widget build(BuildContext context) {
    final filteredTeachers = teachers
        .where(
          (t) => t['name'].toLowerCase().contains(searchText.toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'อาจารย์',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: _borderBlue),
            onPressed: _openAddTeacherModal,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: _searchDeco('ค้นหาอาจารย์'),
              onChanged: (v) => setState(() => searchText = v),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: filteredTeachers.length,
                itemBuilder: (context, index) {
                  final t = filteredTeachers[index];
                  return TextBox(
                    title: t['name'],
                    subtitle: 'รหัสอาจารย์: ${t['user_id']}',
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => _deleteTeacher(t),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ClassPage(
                            studentId: t['user_id'],
                            studentName: t['name'],
                          ),
                        ),
                      );
                    },
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
