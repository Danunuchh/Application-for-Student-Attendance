import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/components/upper_case_english_formatter.dart';
import 'package:my_app/config.dart';

/// ปรับให้ตรงกับเครื่อง/เซิร์ฟเวอร์ของคุณ
const String apiBase = baseUrl; // Android Emulator ใช้ http://10.0.2.2:8000

class CourseDetailPage extends StatefulWidget {
  final String courseId; // ✅ รับ id ที่หน้า list ส่งมา
  final String? courseName; // optional
  final String? courseCode; // optional

  const CourseDetailPage({
    super.key,
    required this.courseId,
    this.courseName,
    this.courseCode,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  static const _borderBlue = Color(0xFF88A8E8);

  // ====== ข้อมูลจากฐานข้อมูล ======
  String? _day;
  String? _section;
  String? _credit;
  String? _teacher;
  String? _time; // ex. '17:00 - 20:00'
  String? _room;
  String? _sessions;

  // ชื่อวิชา/รหัสวิชา (ตั้งต้นจากที่ส่งมา แล้ว override ด้วยข้อมูลจาก DB ถ้ามี)
  late String _name;
  late String _code;

  // รายชื่อนักศึกษา
  final List<Map<String, String>> _students = [];
  List<Map<String, String>> _filtered = [];

  // โหลด/ค้นหา
  bool _loading = true;
  final _searchCtl = TextEditingController();

  Future<void> _deleteCourseFromServer() async {
    final res = await http.post(
      Uri.parse('$apiBase/courses_api.php?type=delete_course'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'course_id': widget.courseId}),
    );

    final json = jsonDecode(res.body);
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'delete failed');
    }
  }

Future<void> _updateCourseToServer({
  required String name,
  required String code,
  String? credit,
  String? teacher,
  String? day,
  String? time,
  String? room,
  String? section,
  String? sessions,
}) async {
    final res = await http.post(
      Uri.parse('$apiBase/courses_api.php?type=update_course'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'course_id': widget.courseId,
        'name': name,
        'code': code,
        'credit': credit ?? '',
        'teacher': teacher ?? '',
        'day': day ?? '',
        'time': time ?? '',
        'room': room ?? '',
        'section': section ?? '',
        'sessions': sessions ?? '',
      }),
    );
    final json = jsonDecode(res.body);
    if (json['success'] != true) {
      throw Exception(json['message'] ?? 'update failed');
    }
  }

  @override
  void initState() {
    super.initState();
    _name = widget.courseName ?? '-';
    _code = widget.courseCode ?? '-';
    _filtered = List.of(_students);
    _searchCtl.addListener(_onSearch);

    _fetchCourseDetail(); // 👈 ดึงข้อมูลด้วย courseId
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_onSearch);
    _searchCtl.dispose();
    super.dispose();
  }

  // ====== HTTP helper ======
  Future<Map<String, dynamic>> _getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$apiBase/$path').replace(queryParameters: query);
    final res = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json; charset=utf-8',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final data = jsonDecode(res.body);
    if (data is Map<String, dynamic>) return data;
    throw Exception('Invalid JSON shape');
  }

  // ====== ดึงรายละเอียดรายวิชาจาก MySQL ผ่าน PHP ======
  Future<void> _fetchCourseDetail() async {
    setState(() => _loading = true);
    try {
      final json = await _getJson(
        'courses_api.php',
        query: {'type': 'detail', 'course_id': widget.courseId},
      );

      // เดิม: if (json['success'] == true) { ... }
      // ใหม่: เช็คว่ามี course จริง
      if (json['course'] is Map) {
        final Map course = json['course'] as Map;

        final name = (course['name'] ?? _name).toString();
        final code = (course['code'] ?? _code).toString();
        final credit = (course['credit'] ?? '').toString();
        final teacher = (course['teacher'] ?? '').toString();
        final day = (course['day'] ?? '').toString();
        final time = (course['time'] ?? '').toString();
        final room = (course['room'] ?? '').toString();
        final section = (course['section'] ?? '').toString();
        final sessions = (course['sessions'] ?? '').toString();

        // 👇 JSON จริงของคุณ: { user_id, name, student_id }
        final List stuList = (json['students'] is List)
            ? (json['students'] as List)
            : const [];
        final students = stuList.map<Map<String, String>>((e) {
          final m = (e as Map);
          return {
            // เก็บทั้งคู่ให้ชัดเจน
            'user_id': (m['user_id'] ?? '').toString(),
            'student_id': (m['student_id'] ?? '').toString(),
            'name': (m['name'] ?? '').toString(),
          };
        }).toList();

        setState(() {
          _name = name.isEmpty ? _name : name;
          _code = code.isEmpty ? _code : code;

          _credit = credit.isEmpty ? null : credit;
          _teacher = teacher.isEmpty ? null : teacher;
          _day = day.isEmpty ? null : day;
          _time = time.isEmpty ? null : time;
          _room = room.isEmpty ? null : room;
          _section = section.isEmpty ? null : section;
          _sessions = sessions.isEmpty ? null : sessions;

          _students
            ..clear()
            ..addAll(students);
          _filtered = List.of(_students);
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('รูปแบบข้อมูลไม่ถูกต้อง (ไม่มี course)'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาดในการโหลด: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ====== ค้นหา ======
  void _onSearch() {
    final q = _searchCtl.text.trim();
    // ถ้าไม่ใช่ตัวเลข ให้ไม่ค้นหา
    if (q.isNotEmpty && !RegExp(r'^\d+$').hasMatch(q)) {
      setState(() {
        _filtered = [];
      });
      return;
    }

    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_students);
      } else {
        _filtered = _students
            .where(
              (s) =>
                  (s['student_id'] ?? '').contains(q) ||
                  (s['user_id'] ?? '').contains(q),
            )
            .toList();
      }
    });
  }

  // ====== Dialog/BottomSheet helpers ======
  InputDecoration _dec(String label, {String? hint, Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        hintText: hint,
        isDense: true,
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
        labelStyle: const TextStyle(color: Colors.black87),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
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
          borderSide: const BorderSide(color: Color(0xFFF44336), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _borderBlue, width: 2),
        ),
        suffixIcon: suffix,
      );

  Future<bool?> _confirmDeleteCourse() {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ลบรายวิชา'),
        content: Text('ยืนยันการลบรายวิชา\n$_code - $_name\nหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDeleteStudent(String id, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('ลบนักศึกษา'),
        content: Text('ยืนยันการลบ $id\n$name หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ยกเลิก'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFF44336)),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  void _deleteCourse() async {
    final ok = await _confirmDeleteCourse();
    if (ok != true) return;

    try {
      await _deleteCourseFromServer();

      if (!mounted) return;
      Navigator.pop(context, {
        'deleteCourse': true,
        'courseId': widget.courseId,
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ลบรายวิชาเรียบร้อย')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    }
  }

  void _deleteStudentAt(int index) async {
    final s = _filtered[index];
    final ok = await _confirmDeleteStudent(
      s['student_id'] ?? '-',
      s['name'] ?? '-',
    );
    if (ok != true) return;

    try {
      final res = await http.post(
        Uri.parse('$apiBase/courses_api.php?type=delete_student'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_id': widget.courseId,
          'user_id': s['user_id'],
        }),
      );

      final json = jsonDecode(res.body);
      if (json['success'] == true) {
        setState(() {
          _students.removeWhere((e) => e['user_id'] == s['user_id']);
          _filtered.removeAt(index);
        });

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ลบ ${s['student_id']} สำเร็จ')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ลบไม่สำเร็จ: $e')));
    }
  }

  // ====== ปุ่มแก้ไขรายวิชา (client-side setState; ถ้าต้องการ update DB ให้โพสต์เพิ่ม) ======
  void _openEditCourse() {
    final nameCtl = TextEditingController(text: _name);
    final codeCtl = TextEditingController(text: _code);
    final creditCtl = TextEditingController(text: _credit ?? '');
    final teacherCtl = TextEditingController(text: _teacher ?? '');
    final dayCtl = TextEditingController(text: _day ?? '');
    final timeCtl = TextEditingController(text: _time ?? '');
    final roomCtl = TextEditingController(text: _room ?? '');
    final sectionCtl = TextEditingController(text: _section ?? '');
    final sessionsCtl = TextEditingController(text: _sessions ?? '');

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
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
                  'แก้ไขรายวิชา',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: nameCtl,
                  decoration: _dec('วิชา'),
                  inputFormatters: [
                    UpperCaseEnglishFormatter(),
                  ],
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกชื่อวิชา'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: codeCtl,
                  decoration: _dec('รหัสวิชา'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกรหัสวิชา'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: creditCtl,
                  decoration: _dec('หน่วยกิต'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: teacherCtl,
                  decoration: _dec('อาจารย์ผู้สอน'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: dayCtl,
                  decoration: _dec('วันที่เรียน'),
                ),
                const SizedBox(height: 10),
                TextFormField(controller: timeCtl, decoration: _dec('เวลา')),
                const SizedBox(height: 10),
                TextFormField(
                  controller: roomCtl,
                  decoration: _dec('ห้องเรียน'),
                  inputFormatters: [
                    UpperCaseEnglishFormatter(),
                  ],
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sectionCtl,
                  decoration: _dec('กลุ่มที่เรียน'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: sessionsCtl,
                  decoration: _dec('จำนวนครั้งที่ให้นักศึกษาลาได้'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336),
                        side: const BorderSide(
                          color: Color(0xFFF44336),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: () async {
                        if (!formKey.currentState!.validate()) return;

                        try {
                          await _updateCourseToServer(
                            name: nameCtl.text.trim(),
                            code: codeCtl.text.trim(),
                            credit: creditCtl.text.trim(),
                            teacher: teacherCtl.text.trim(),
                            day: dayCtl.text.trim(),
                            time: timeCtl.text.trim(),
                            room: roomCtl.text.trim(),
                            section: sectionCtl.text.trim(),
                            sessions: sessionsCtl.text.trim(),
                          );

                          setState(() {
                            _name = nameCtl.text.trim();
                            _code = codeCtl.text.trim();
                            _credit = creditCtl.text.trim().isEmpty
                                ? null
                                : creditCtl.text.trim();
                            _teacher = teacherCtl.text.trim().isEmpty
                                ? null
                                : teacherCtl.text.trim();
                            _day = dayCtl.text.trim().isEmpty
                                ? null
                                : dayCtl.text.trim();
                            _time = timeCtl.text.trim().isEmpty
                                ? null
                                : timeCtl.text.trim();
                            _room = roomCtl.text.trim().isEmpty
                                ? null
                                : roomCtl.text.trim();
                            _section = sectionCtl.text.trim().isEmpty
                                ? null
                                : sectionCtl.text.trim();
                            _sessions = sessionsCtl.text.trim().isEmpty
                                ? null
                                : sessionsCtl.text.trim();
                          });

                          if (!mounted) return;
                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('บันทึกการแก้ไขเรียบร้อย'),
                            ),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('บันทึกไม่สำเร็จ: $e')),
                          );
                        }
                      },

                      label: const Text(
                        'บันทึก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
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
  }

  // ====== ช่องค้นหา ======
  InputDecoration _searchDeco() => InputDecoration(
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

  // ====== helper แสดง label + value ======
  static const double _labelW = 110;
  Widget _kv(String label, String? value, {int? maxLines}) {
    final display = (value == null || value.trim().isEmpty) ? '-' : value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelW,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              softWrap: true,
              maxLines: maxLines,
              style: const TextStyle(fontWeight: FontWeight.w600, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ====== UI ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'คลาสเรียน'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              children: [
                // การ์ดรายละเอียดรายวิชา
                Card(
                  color: Colors.white,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _borderBlue, width: 1.2),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _kv('วิชา', _name, maxLines: 3),
                        _kv('รหัสวิชา', _code),
                        _kv('หน่วยกิต', _credit),
                        _kv('อาจารย์ผู้สอน', _teacher, maxLines: 2),
                        _kv('วันที่เรียน', _day),
                        _kv('เวลา', _time),
                        _kv('ห้องเรียน', _room),
                        _kv('กลุ่มที่เรียน', _section),
                        _kv('จำนวนครั้งที่ลาได้', _sessions),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _deleteCourse,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              label: const Text(
                                'ลบรายวิชา',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.tonalIcon(
                              onPressed: _openEditCourse,
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Color(0xFFD98C06),
                              ),
                              label: const Text(
                                'แก้ไขรายวิชา',
                                style: TextStyle(color: Color(0xFFD98C06)),
                              ),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.white,
                                side: const BorderSide(
                                  color: Color(0xFFD98C06),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ช่องค้นหา
                TextField(controller: _searchCtl, decoration: _searchDeco()),
                const SizedBox(height: 16),

                // รายชื่อนักศึกษา
                if (_filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Text('ยังไม่มีรายชื่อนักศึกษา'),
                    ),
                  )
                else
                  ...List.generate(_filtered.length, (index) {
                    final s = _filtered[index];
                    // แทนที่เดิม
                    return TextBox(
                      title: s['name'],
                      subtitle: s['student_id'], // ✅ โชว์รหัสนักศึกษา
                      trailing: IconButton(
                        tooltip: 'ลบนักศึกษา',
                        icon: const Icon(
                          Icons.delete,
                          color: Color(0xFFF44336),
                        ),
                        onPressed: () => _deleteStudentAt(index),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}
