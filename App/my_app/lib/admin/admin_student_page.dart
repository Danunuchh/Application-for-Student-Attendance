import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_student_detail_page.dart';
import 'package:my_app/components/custom_appbar.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_app/config.dart';

class AdminApiService {
  static Future<Map<String, dynamic>> getJson(
    String endpoint, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl/$endpoint').replace(queryParameters: query);

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Server error');
    }

    return jsonDecode(response.body);
  }

  static Future<Map<String, dynamic>> fetchData({required String type}) async {
    return await getJson('admin_api.php', query: {'type': type});
  }
}

class AdminStudentPage extends StatefulWidget {
  final List<Map<String, dynamic>> data;

  const AdminStudentPage({super.key, required this.data});

  @override
  State<AdminStudentPage> createState() => _AdminStudentPageState();
}

class _AdminStudentPageState extends State<AdminStudentPage> {
  static const Color _borderBlue = Color(0xFF88A8E8);

  int? _selectedYear;
  String _searchText = '';

  late List<Map<String, dynamic>> allStudents;
  List<Map<String, dynamic>> filteredStudents = [];

  @override
  void initState() {
    super.initState();
    allStudents = widget.data;
    filteredStudents = allStudents;
  }

  List<int> _getAvailableYears() {
    final studentYears = allStudents
        .map((s) => calculateYearFromStudentId(s['student_id']))
        .toSet();

    final maxYear = studentYears.isEmpty
        ? 4
        : studentYears.reduce((a, b) => a > b ? a : b);

    final upperLimit = maxYear < 4 ? 4 : maxYear;

    return List.generate(upperLimit, (index) => index + 1);
  }

  /// ====== คำนวณชั้นปีจาก student_id ======
  int calculateYearFromStudentId(String studentId) {
    final startYear = int.parse(studentId.substring(0, 2));

    int currentYear = DateTime.now().year + 543;
    int currentMonth = DateTime.now().month;

    if (currentMonth <= 5) {
      currentYear -= 1;
    }

    final start = startYear + 2500;
    return currentYear - start + 1;
  }

  /// ====== filter รวม (ปี + search) ======
  void _applyFilter() {
    setState(() {
      filteredStudents = allStudents.where((s) {
        final year = calculateYearFromStudentId(s['student_id']);
        final matchYear = _selectedYear == null || year == _selectedYear;

        final name = s['full_name'].toString().toLowerCase();
        final sid = s['student_id'].toString().toLowerCase();
        final matchSearch =
            name.contains(_searchText) || sid.contains(_searchText);

        return matchYear && matchSearch;
      }).toList();
    });
  }

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

  Future<void> _deleteStudentAt(int index) async {
    final student = filteredStudents[index];
    final studentId = student['student_id'];

    // ลบออกจาก UI ทันที
    setState(() {
      filteredStudents.removeAt(index);
      allStudents.removeWhere(
        (s) => s['student_id'].toString() == studentId.toString(),
      );
    });

    final uri = Uri.parse('$apiBase/admin_api.php').replace(
      queryParameters: {
        'type': 'delete_student',
        'student_id': studentId.toString(),
      },
    );

    try {
      final response = await http.get(uri);
      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        final json = await AdminApiService.fetchData(type: 'student_list');

        if (json['success'] == true && json['data'] != null) {
          final List<Map<String, dynamic>> studentList =
              List<Map<String, dynamic>>.from(json['data']);

          setState(() {
            allStudents = studentList;
          });

          // 🔥 รีเฟรชตาม filter ปัจจุบัน
          _applyFilter();
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('ลบนักศึกษาเรียบร้อย')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'นักศึกษา'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ====== ปุ่มเลือกชั้นปี ======
            const Text(
              'ชั้นปี',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: constraints.maxWidth),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: _getAvailableYears().map((year) {
                        final selected = _selectedYear == year;

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selected
                                  ? _borderBlue
                                  : Colors.white,
                              foregroundColor: selected
                                  ? Colors.white
                                  : Colors.black,
                              side: const BorderSide(color: _borderBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _selectedYear = selected ? null : year;
                                _applyFilter();
                              });
                            },
                            child: Text('ปี $year'),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            /// ====== ค้นหา ======
            TextField(
              decoration: _searchDeco('ค้นหารหัสนักศึกษา'),
              onChanged: (v) {
                _searchText = v.toLowerCase();
                _applyFilter();
              },
            ),

            const SizedBox(height: 20),

            /// ====== รายชื่อนักศึกษา ======
            Expanded(
              child: filteredStudents.isEmpty
                  ? const Center(
                      child: Text(
                        'ไม่พบข้อมูลนักศึกษา',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: filteredStudents.length,
                      itemBuilder: (_, index) {
                        final s = filteredStudents[index];
                        final year = calculateYearFromStudentId(
                          s['student_id'],
                        );

                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminStudentDetailPage(
                                  studentId: s['student_id'],
                                  fullName: s['full_name'],
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              bottom: 14,
                            ), // 👈 เพิ่มระยะห่างระหว่างช่อง
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF84A9EA),
                                width: 1.5,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x1F000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// ===== ข้อมูลนักศึกษา =====
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        s['full_name'],
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1F2937),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        s['student_id'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF6B7280),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                /// ===== ปุ่มลบ =====
                                IconButton(
                                  tooltip: 'ลบนักศึกษา',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Color(0xFFF44336),
                                  ),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: const Text('ยืนยันการลบ'),
                                        content: const Text(
                                          'คุณต้องการลบนักศึกษาคนนี้ใช่หรือไม่?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('ยกเลิก'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.red,
                                            ),
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('ลบ'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirm == true) {
                                      await _deleteStudentAt(index);
                                    }
                                  },
                                ),
                              ],
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
