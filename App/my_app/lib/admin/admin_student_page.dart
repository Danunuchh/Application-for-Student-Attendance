import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/config.dart';

class AdminStudentPage extends StatefulWidget {
  const AdminStudentPage({super.key});

  @override
  State<AdminStudentPage> createState() => _AdminStudentPageState();
}

const String apiBase =
    //'http://10.0.2.2:8000'; // หรือ http://10.0.2.2:8000 สำหรับ Android Emulator
    baseUrl; // หรือ http://10.0.2.2:8000 สำหรับ Android Emulator

class ApiService {
  static Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$apiBase/$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _jsonHeaders);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$apiBase/$path');
    final res = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  // ✅ ย้ายเมธอดนี้เข้ามาในคลาส และยังเป็น static ได้
  static Future<Map<String, dynamic>> addStudentToCourse({
    required String studentId,
    required int courseId,
  }) async {
    final body = {'student_id': studentId, 'course_id': courseId};
    return await postJson('courses_api.php?type=add_student', body);
  }
}

class _AdminStudentPageState extends State<AdminStudentPage> {
  static const Color _borderBlue = Color(0xFF88A8E8);

  int? _selectedYear;

  /// ====== ตัวแปรนักศึกษา ======
  List<Map<String, dynamic>> allStudents = [];
  List<Map<String, dynamic>> filteredStudents = [];
  Map<String, bool> selectedStudents = {};

  /// ====== ช่องค้นหา ======
  InputDecoration _searchDeco(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF88A8E8), width: 1.5),
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

  /// ====== InputDecoration ใช้ใน Modal ======
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

  /// ====== ดึงข้อมูลนักศึกษาจาก API ======

  /// ====== Modal เพิ่มนักศึกษา ======
  void _openAddStudentModal() {
    final formKey = GlobalKey<FormState>();
    final studentIdCtl = TextEditingController();
    final nameCtl = TextEditingController();

    bool canSave = false;

    void checkCanSave() {
      canSave =
          studentIdCtl.text.trim().isNotEmpty && nameCtl.text.trim().isNotEmpty;
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
                      'เพิ่มนักศึกษา',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// รหัสนักศึกษา
                    TextFormField(
                      controller: studentIdCtl,
                      decoration: _dec('รหัสนักศึกษา'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setModalState(() => checkCanSave());
                      },
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกรหัสนักศึกษา'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    /// ชื่อ–นามสกุล
                    TextFormField(
                      controller: nameCtl,
                      decoration: _dec('ชื่อ – นามสกุล'),
                      onChanged: (_) {
                        setModalState(() => checkCanSave());
                      },
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกชื่อ–นามสกุล'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('ยกเลิก'),
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: canSave
                              ? () {
                                  if (!formKey.currentState!.validate()) return;

                                  Navigator.pop(context);

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('เพิ่มนักศึกษาเรียบร้อย'),
                                    ),
                                  );
                                }
                              : null,
                          icon: const Icon(Icons.check_circle_outline),
                          label: const Text('บันทึก'),
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

  /// ====== UI หลัก ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'นักศึกษา',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: _borderBlue),
            onPressed: _openAddStudentModal,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ชั้นปี',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final year = i + 1;
                final selected = _selectedYear == year;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected ? _borderBlue : Colors.white,
                      foregroundColor: selected ? Colors.white : Colors.black,
                      side: const BorderSide(color: _borderBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _selectedYear = year),
                    child: Text('ปี $year'),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            TextField(decoration: _searchDeco('รหัสนักศึกษา')),
          ],
        ),
      ),
    );
  }
}
