import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; 
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/components/button.dart';
import 'package:my_app/components/upper_case_english_formatter.dart';
import 'package:my_app/teacher/course_detail_page.dart';
import 'teacher_qr_page.dart';
import 'package:my_app/config.dart';


// ---------- ปรับตามเครื่องคุณ ----------
const String apiBase =
    baseUrl; 

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

  static Future<Map<String, dynamic>> addStudentToCourse({
    required String studentId,
    required int courseId,
  }) async {
    final body = {'student_id': studentId, 'course_id': courseId};
    return await postJson('courses_api.php?type=add_student', body);
  }
}

class CoursesPage extends StatefulWidget {
  final String userId;
  const CoursesPage({super.key, required this.userId});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  final List<Map<String, dynamic>> _courses = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  // ====== ช่องค้นหา ======
  static const _borderBlue = Color(0xFF88A8E8);

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

  void _showAddStudentSheet(int courseId) {
    List<Map<String, dynamic>> allStudents = [];
    List<Map<String, dynamic>> filteredStudents = [];
    Map<String, bool> selectedStudents = {};
    bool isLoading = false;
    int? selectedYear;

    int calculateYearFromStartYear(String startYear) {
      // ปี พ.ศ. ปัจจุบัน
      int currentYear = DateTime.now().year + 543;

      // เดือนปัจจุบัน
      int currentMonth = DateTime.now().month;

      // ถ้ายังไม่เกินเดือนพฤษภาคม (1–5) ให้ใช้ปีการศึกษาปีก่อน
      if (currentMonth <= 5) {
        currentYear -= 1;
      }

      // ปีที่เริ่มเข้า (เช่น 65 -> 2565)
      int start = int.parse(startYear) + 2500;

      // คำนวณชั้นปี
      return currentYear - start + 1;
    }

    void applyFilter(String search) {
      filteredStudents = allStudents.where((s) {
        final matchesYear =
            selectedYear == null ||
            calculateYearFromStartYear(s['start_year']) == selectedYear;

        final name = s['full_name'].toString().toLowerCase();
        final sid = s['student_id'].toString().toLowerCase();

        final matchesSearch =
            name.contains(search.toLowerCase()) ||
            sid.contains(search.toLowerCase());

        return matchesYear && matchesSearch;
      }).toList();
    }

    int getMaxYear() {
      if (allStudents.isEmpty) return 4;

      return allStudents
          .map((s) => calculateYearFromStartYear(s['start_year']))
          .reduce((a, b) => a > b ? a : b);
    }

    Future<void> fetchStudents(int courseId) async {
      try {
        final json = await ApiService.getJson(
          'get_student.php',
          query: {'course_id': courseId.toString()},
        );

        if (json['success'] == true && json['students'] is List) {
          final List data = json['students'];

          allStudents = data.cast<Map<String, dynamic>>();
          filteredStudents = allStudents;
          selectedStudents = {
            for (var s in allStudents) s['user_id'].toString(): false,
          };

          print('✅ Loaded students: ${allStudents.length}');
        } else {
          print('⚠️ Server message: ${json['message']}');
        }
      } catch (e) {
        print('⚠️ Error fetching students: $e');
      }
    }

    Future<void> saveStudents(List<Map<String, dynamic>> students) async {
      // 🔹 สร้าง payload เป็น Map<String, dynamic>
      final Map<String, dynamic> payload = {
        'type': 'insert',
        'course_id': courseId,
        'students': students.map((s) {
          return {
            'user_id': s['user_id'],
            'user_name': s['full_name'],
            'student_id': s['student_id'],
          };
        }).toList(),
      };

      try {
        final json = await ApiService.postJson(
          'save_schedule.php', // positional arg 1
          payload, // positional arg 2
        );

        if (json['success'] == true) {
          print('✅ Saved successfully');
        } else {
          print('❌ Save failed: ${json['message']}');
        }
      } catch (e) {
        print('⚠️ Error saving students: $e');
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            // โหลดข้อมูลครั้งแรก
            if (!isLoading) {
              isLoading = true;
              fetchStudents(courseId).then((_) => setModalState(() {}));
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.9,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    CustomAppBar(
                      title: 'เพิ่มนักศึกษาเข้าคลาส',
                      leading: IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      actions: const [
                        SizedBox(width: 6),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(getMaxYear(), (i) {
                          final year = i + 1;
                          final isSelected = selectedYear == year;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected
                                    ? const Color(0xFF88A8E8)
                                    : Colors.white,
                                foregroundColor: isSelected
                                    ? Colors.white
                                    : Colors.black,
                                side: const BorderSide(
                                  color: Color(0xFF88A8E8),
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  selectedYear = year;
                                  applyFilter('');
                                });
                              },
                              child: Text('ปี $year'),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ช่องค้นหานักศึกษา
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: _searchDeco('ค้นหานักศึกษา'),
                        onChanged: (value) {
                          setModalState(() {
                            applyFilter(value);
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Smart Select All Box
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Builder(
                        builder: (_) {
                          int selectedCount = filteredStudents
                              .where(
                                (s) =>
                                    selectedStudents[s['user_id'].toString()] ==
                                    true,
                              )
                              .length;

                          bool allSelected =
                              filteredStudents.isNotEmpty &&
                              selectedCount == filteredStudents.length;

                          return Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: selectedYear == null
                                  ? null
                                  : () {
                                      setModalState(() {
                                        for (var s in filteredStudents) {
                                          selectedStudents[s['user_id']
                                                  .toString()] =
                                              !allSelected;
                                        }
                                      });
                                    },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                  border: Border.all(
                                    color: selectedYear == null
                                        ? Colors.grey.shade300
                                        : allSelected
                                        ? const Color(0xFF4A7DFF)
                                        : const Color(0xFF88A8E8),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // checkbox style
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(4),
                                        color: allSelected
                                            ? const Color(0xFF4A7DFF)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: const Color(0xFF4A7DFF),
                                          width: 1.5,
                                        ),
                                      ),
                                      child: allSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Select all',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: selectedYear == null
                                            ? Colors.grey
                                            : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // รายการนักศึกษา
                    Expanded(
                      child: filteredStudents.isEmpty
                          ? const Center(
                              child: Text(
                                'ไม่มีข้อมูลนักศึกษา',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                          : ListView.builder(
                              itemCount: filteredStudents.length,
                              itemBuilder: (context, index) {
                                final student = filteredStudents[index];
                                final id = student['user_id'].toString();
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 4,
                                  ),
                                  title: Text(
                                    '${student['full_name']} (${student['student_id']})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    'ชั้นปี ${calculateYearFromStartYear(student['start_year'])}',
                                  ),
                                  trailing: Checkbox(
                                    value: selectedStudents[id] ?? false,
                                    onChanged: (val) {
                                      setModalState(() {
                                        selectedStudents[id] = val ?? false;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                    ),

                    // ปุ่มบันทึก
                    SizedBox(
                      child: CustomButton(
                        text: 'บันทึกนักศึกษาที่เลือก',
                        backgroundColor: const Color(0xFF88A8E8),
                        textColor: Colors.white,
                        onPressed: () async {
                          final selected = filteredStudents
                              .where(
                                (s) =>
                                    selectedStudents[s['user_id'].toString()] ==
                                    true,
                              )
                              .toList();

                          if (selected.isEmpty) return;

                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.white,
                              title: const Text('ยืนยันการบันทึก'),
                              content: Text(
                                'คุณต้องการบันทึก ${selected.length} นักศึกษาที่เลือกใช่หรือไม่?',
                              ),
                              actions: [
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFF44336),
                                  ),
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('ยกเลิก'),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF21BA0C),
                                    foregroundColor: const Color(
                                      0xFFFFFFFF,
                                    ), 
                                  ),
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('ตกลง'),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await saveStudents(selected);
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                      ),
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

  Future<void> _fetchCourses() async {
    setState(() => _loading = true);
    try {
      final json = await ApiService.getJson(
        'courses_api.php',
        query: {'user_id': widget.userId, 'type': 'show'},
      );
      if (json['success'] == true && json['data'] is List) {
        final List data = json['data'];
        setState(() {
          _courses
            ..clear()
            ..addAll(
              data
                  .cast<Map>()
                  .map(
                    (e) => {
                      'id': e['id'],
                      'name': e['name'],
                      'code': e['code'],
                      'year': e['year'],
                      'term': e['term'],
                      'section': e['section'],
                      'user_id': e['user_id'],
                    },
                  )
                  .cast<Map<String, dynamic>>(),
            );
        });
      } else {
        _showSnack('ไม่สามารถดึงรายวิชาได้');
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาดในการดึงข้อมูล: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ไปหน้า QR
  void _goToQR(Map<String, dynamic> c) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TeacherQRPage(
          courseId: (c['id'] as num).toInt(),
          courseName: c['name'],
          token: '',
        ),
      ),
    );
  }

  // เปิด BottomSheet เพื่อเพิ่มวิชา (จะ POST ไป PHP และส่งผลกลับ)
  Future<void> _openAddCourseSheet() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddCourseSheet(userId: widget.userId),
      ),
    );

    if (result != null) {
      // เพิ่มเข้า list ทันที หรือจะเรียก _fetchCourses() เพื่อ sync จาก backend ก็ได้
      setState(() => _courses.add(result));
      _showSnack('เพิ่มวิชาเรียบร้อย');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'คลาสเรียน',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF88A8E8)),
            onPressed: _openAddCourseSheet,
            tooltip: 'เพิ่มวิชา',
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? _emptyState()
          : RefreshIndicator(
              onRefresh: _fetchCourses,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                itemCount: _courses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) {
                  final c = _courses[i];

                  return TextBox(
                    title: '${c['code']}  ${c['name']}',
                    subtitle:
                        'ปีการศึกษา ${c['year']} | ภาคเรียน ${c['term']} | Sec ${c['section']}',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailPage(
                            courseId: c['id'].toString(),
                            courseName: c['name']?.toString(),
                            courseCode: c['code']?.toString(),
                          ),
                        ),
                      );
                    },
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ปุ่มเพิ่มนักศึกษา
                        IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_1,
                            color: Color(0xFF9CA3AF),
                          ),
                          onPressed: () {
                            _showAddStudentSheet(
                              c['id'], 
                            );
                          },
                        ),

                        const SizedBox(width: 4),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.menu_book_outlined, size: 72, color: Color(0xFF88A8E8)),
            SizedBox(height: 12),
            Text(
              'ยังไม่มีรายวิชา',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text(
              'กดปุ่ม + มุมขวาบนเพื่อเพิ่มรายวิชาใหม่',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

/// ----------------- BottomSheet ฟอร์มเพิ่มวิชา (POST → PHP) -----------------
class AddCourseSheet extends StatefulWidget {
  final String userId;
  const AddCourseSheet({super.key, required this.userId});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _code = TextEditingController();
  final _credit = TextEditingController();
  final _teacher = TextEditingController();
  final _day = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _room = TextEditingController();
  final _section = TextEditingController();
  final _year = TextEditingController();
  final _term = TextEditingController();
  final _sessions = TextEditingController();

  bool _canSubmit = false;
  bool _submitting = false;
  bool _loadingTeacherName = true;

  static const _borderBlue = Color(0xFF9CA3AF);
  static const _hintGrey = Color(0xFF9CA3AF);

  List<Map<String, dynamic>> _days = [];
  String? _selectedDayId;
  bool _loadingDays = true;

  @override
  void initState() {
    super.initState();
    for (final c in [
      _name,
      _code,
      _credit,
      _teacher,
      _day,
      _start,
      _end,
      _room,
      _section,
      _year,
      _term,
      _sessions,
    ]) {
      c.addListener(_recalcCanSubmit);
    }
    _loadTeacherName();
    _loadDays();
  }

  Future<void> _loadTeacherName() async {
    try {
      // เรียก PHP เพื่อดึงชื่อจาก user_id
      final json = await ApiService.getJson(
        'courses_api.php',
        query: {
          'type': 'teacher_name',
          'user_id': widget.userId, // << ส่ง user_id ปัจจุบัน
        },
      );

      if (json['success'] == true && json['name'] is String) {
        _teacher.text = json['name']; // ใส่ชื่ออาจารย์ให้ auto
      } else {
        // ถ้า backend ไม่ส่ง name กลับมา จะปล่อยให้ผู้ใช้กรอกเอง
        debugPrint('teacher_name not found -> fallback to manual input');
      }
    } catch (e) {
      debugPrint('โหลดชื่ออาจารย์ล้มเหลว: $e');
      // ปล่อยให้ผู้ใช้กรอกเอง
    } finally {
      if (mounted) setState(() => _loadingTeacherName = false);
    }
  }

  Future<void> _loadDays() async {
    try {
      final json = await ApiService.getJson(
        'courses_api.php',
        query: {'type': 'days'},
      );
      if (json['success'] == true && json['data'] is List) {
        setState(() {
          _days = (json['data'] as List)
              .cast<Map>()
              .cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('โหลด “วันที่เรียน” ไม่สำเร็จ')),
      );
    } finally {
      if (mounted) setState(() => _loadingDays = false);
    }
  }

  void _recalcCanSubmit() {
    final ok =
        _name.text.trim().isNotEmpty &&
        _code.text.trim().isNotEmpty &&
        _credit.text.trim().isNotEmpty &&
        _teacher.text.trim().isNotEmpty &&
        _day.text.trim().isNotEmpty &&
        _start.text.trim().isNotEmpty &&
        _end.text.trim().isNotEmpty &&
        _room.text.trim().isNotEmpty &&
        _section.text.trim().isNotEmpty &&
        _year.text.trim().isNotEmpty &&
        _term.text.trim().isNotEmpty &&
        _sessions.text.trim().isNotEmpty;
    if (ok != _canSubmit) setState(() => _canSubmit = ok);
  }

  String? _required(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

  InputDecoration _dec(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: _hintGrey),
      labelStyle: const TextStyle(color: Colors.black87),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderBlue, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF88A8E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
      ),
      errorStyle: const TextStyle(height: 0, color: Colors.transparent),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF9CA3AF), width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderBlue, width: 2),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _credit.dispose();
    _teacher.dispose();
    _day.dispose();
    _start.dispose();
    _end.dispose();
    _room.dispose();
    _section.dispose();
    _year.dispose();
    _term.dispose();
    _sessions.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final res = await showTimePicker(
      context: context,
      initialTime: now,
      initialEntryMode: TimePickerEntryMode.input,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (res != null) {
      final h = res.hour.toString().padLeft(2, '0');
      final m = res.minute.toString().padLeft(2, '0');
      ctrl.text = '$h:$m';
    }
  }

  Future<void> _submitToServer() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      final body = {
        'user_id': widget.userId,
        'name': _name.text.trim(),
        'code': _code.text.trim(),
        'credit': _credit.text
            .trim(), 
        'teacher': _teacher.text.trim(), // ดึงจาก user_id มาก่อนหน้าแล้ว
        'day': _day.text
            .trim(), 
        'day_id': _selectedDayId,
        'start_time': _start.text.trim(),
        'end_time': _end.text.trim(),
        'room': _room.text.trim(),
        'section': _section.text.trim(),
        'year': _year.text.trim(),
        'term': _term.text.trim(),
        'sessions': _sessions.text.trim(), 
      };

      final json = await ApiService.postJson(
        'courses_api.php?type=coursesadd',
        body,
      );

      if (json['success'] == true && json['course'] is Map) {
        final c = (json['course'] as Map).cast<String, dynamic>();
        final result = {
          'id': c['id'] ?? DateTime.now().millisecondsSinceEpoch,
          'name': c['name'] ?? _name.text.trim(),
          'code': c['code'] ?? _code.text.trim(),
          'user_id': c['user_id'] ?? widget.userId,
        };
        if (!mounted) return;
        Navigator.pop(context, result);
      } else {
        _showLocalSnack('เพิ่มวิชาไม่สำเร็จ');
      }
    } catch (e) {
      _showLocalSnack('ส่งข้อมูลล้มเหลว: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _addStudent(String studentId, int courseId) async {
    try {
      final res = await ApiService.addStudentToCourse(
        studentId: studentId,
        courseId: courseId,
      );

      if (res['success'] == true) {
        _showLocalSnack('เพิ่มนักศึกษาเรียบร้อย');
      } else {
        _showLocalSnack(res['message'] ?? 'เพิ่มนักศึกษาไม่สำเร็จ');
      }
    } catch (e) {
      _showLocalSnack('เกิดข้อผิดพลาด: $e');
    }
  }

  Future<String?> _askStudentId(BuildContext context) async {
    final controller = TextEditingController();
    return await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('เพิ่มนักศึกษาเข้าคลาส'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'รหัสนักศึกษา',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  void _showLocalSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.of(context).size.width.clamp(0, 720);
    return Material(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW.toDouble()),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // หัวเรื่อง
                  const Row(
                    children: [
                      Icon(
                        Icons.menu_book_outlined,
                        size: 22,
                        color: Color(0xFF88A8E8),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'เพิ่มคลาสเรียน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _name,
                    decoration: _dec('วิชา'),
                    inputFormatters: [
                      UpperCaseEnglishFormatter(),
                    ],
                    validator: (v) => _required(v, 'กรุณากรอกชื่อวิชา'),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _code,
                          decoration: _dec('รหัสวิชา'),
                          validator: (v) => _required(v, 'กรุณากรอกรหัสวิชา'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _credit,
                          decoration: _dec('หน่วยกิต'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _required(v, 'กรุณากรอกหน่วยกิต'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _year,
                          decoration: _dec('ปีการศึกษา'),
                          validator: (v) => _required(v, 'กรุณากรอกปีการศึกษา'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _term,
                          decoration: _dec('ภาคเรียน'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          validator: (v) => _required(v, 'กรุณากรอกภาคเรียน'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  _loadingTeacherName
                      ? const LinearProgressIndicator(minHeight: 2)
                      : TextFormField(
                          controller: _teacher,
                          readOnly: true, 
                          decoration: _dec('อาจารย์ผู้สอน'),
                          validator: (v) =>
                              _required(v, 'กรุณากรอกชื่ออาจารย์ผู้สอน'),
                        ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    initialValue: _selectedDayId,
                    items: _days.map((d) {
                      final id = d['id'].toString();
                      final name = d['name'].toString();
                      return DropdownMenuItem<String>(
                        value: id,
                        child: Text(name),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedDayId = v;
                        final name = _days
                            .firstWhere((e) => e['id'].toString() == v)['name']
                            .toString();
                        _day.text = name;
                      });
                    },
                    decoration: _dec('วันที่เรียน').copyWith(
                      filled: true,
                      fillColor: const Color.fromARGB(
                        255,
                        255,
                        255,
                        255,
                      ), 
                    ),
                    dropdownColor: const Color.fromARGB(
                      255,
                      255,
                      255,
                      255,
                    ),
                    validator: (v) => (v == null || v.isEmpty)
                        ? 'กรุณาเลือกวันที่เรียน'
                        : null,
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _start,
                          readOnly: true,
                          onTap: () => _pickTime(_start),
                          textAlign: TextAlign.center,
                          decoration: _dec('เวลาเริ่ม'),
                          validator: (v) => _required(v, 'เลือกเวลาเริ่ม'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text('—', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _end,
                          readOnly: true,
                          onTap: () => _pickTime(_end),
                          textAlign: TextAlign.center,
                          decoration: _dec('เวลาสิ้นสุด'),
                          validator: (v) => _required(v, 'เลือกเวลาสิ้นสุด'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _room,
                          decoration: _dec('ห้องเรียน'),
                          inputFormatters: [UpperCaseEnglishFormatter()],
                          validator: (v) => _required(v, 'กรุณากรอกห้องเรียน'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      Expanded(
                        child: TextFormField(
                          controller: _section,
                          decoration: _dec('กลุ่มที่เรียน'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _sessions,
                    decoration: _dec('จำนวนครั้งที่ให้นักศึกษาลาได้'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    validator: (v) => _required(v, 'กรุณากรอกจำนวนครั้ง'),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _submitting
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'ยกเลิก',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: (_canSubmit && !_submitting)
                            ? _submitToServer
                            : null,
                        icon: _submitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline),
                        label: Text(_submitting ? 'กำลังบันทึก…' : 'บันทึก'),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color.fromARGB(
                            255,
                            161,
                            220,
                            182,
                          ),
                          disabledForegroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
