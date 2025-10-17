import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // ✅ ใช้ http
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'teacher_qr_page.dart';
// import 'course_detail_page.dart'; // มีอยู่แล้วในโปรเจกต์คุณ

// ---------- ปรับตามเครื่องคุณ ----------
const String apiBase =
    'http://localhost:8000'; // หรือ http://10.0.2.2:8000 สำหรับ Android Emulator

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
          courseName: c['name'] as String,
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
            icon: const Icon(Icons.refresh, color: Color(0xFF88A8E8)),
            onPressed: _fetchCourses,
            tooltip: 'รีเฟรช',
          ),
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
                    title: c['name'],
                    subtitle: c['code'],
                    onTap: () {
                      // ถ้ามีหน้า detail เปิดได้ที่นี่
                      // Navigator.push(...);
                    },
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.qr_code_2,
                        color: Color(0xFF9CA3AF),
                      ),
                      onPressed: () => _goToQR(c),
                      tooltip: 'QR เช็กชื่อ',
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
        _teacher.text = json['name']; // ✅ ใส่ชื่ออาจารย์ให้ auto
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
        borderSide: const BorderSide(color: _borderBlue, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderBlue, width: 2),
      ),
      errorStyle: const TextStyle(height: 0, color: Colors.transparent),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _borderBlue, width: 1.5),
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
    _sessions.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final res = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c!).copyWith(alwaysUse24HourFormat: true),
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
        'credit': _credit.text.trim(), // ถ้าฝั่ง PHP ต้องการ int ก็แปลงเป็น int ที่นี่ได้
        'teacher': _teacher.text.trim(), // ดึงจาก user_id มาก่อนหน้าแล้ว
        'day': _day.text.trim(), // ถ้ามี day_id จาก dropdown ให้ใส่ 'day_id': _selectedDayId
        'day_id': _selectedDayId,
        'start_time': _start.text.trim(),
        'end_time': _end.text.trim(),
        'room': _room.text.trim(),
        'sessions': _sessions.text.trim(), // เช่น "3"
        // ไม่ต้องใส่ 'type' ใน body
      };

      // ✅ เปลี่ยนปลายทางให้ถูก
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
                    validator: (v) => _required(v, 'กรุณากรอกชื่อวิชา'),
                  ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _code,
                          decoration: _dec('รหัสวิชา'),
                          validator: (v) => _required(v, 'กรุณากรอกรหัสวิชา'),
                        ),
                      ),
                      const SizedBox(width: 10),
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
                  const SizedBox(height: 10),

                  _loadingTeacherName
                      ? const LinearProgressIndicator(minHeight: 2)
                      : TextFormField(
                          controller: _teacher,
                          readOnly: true, // ✅ ไม่ให้แก้ (เพราะดึงจาก user_id)
                          decoration: _dec('อาจารย์ผู้สอน'),
                          validator: (v) =>
                              _required(v, 'กรุณากรอกชื่ออาจารย์ผู้สอน'),
                        ),
                  const SizedBox(height: 10),

                  _loadingDays
                      ? const LinearProgressIndicator(minHeight: 2)
                      : DropdownButtonFormField<String>(
                          value: _selectedDayId,
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
                              // อัปเดต controller เดิมเพื่อเข้ากับโค้ดที่ใช้อยู่แล้ว
                              final name = _days
                                  .firstWhere(
                                    (e) => e['id'].toString() == v,
                                  )['name']
                                  .toString();
                              _day.text = name;
                            });
                          },
                          decoration: _dec('วันที่เรียน'),
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'กรุณาเลือกวันที่เรียน'
                              : null,
                        ),
                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _start,
                          readOnly: true,
                          onTap: () => _pickTime(_start),
                          textAlign: TextAlign.center,
                          decoration: _dec('เวลาเริ่ม', hint: 'HH:mm'),
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
                          decoration: _dec('เวลาสิ้นสุด', hint: 'HH:mm'),
                          validator: (v) => _required(v, 'เลือกเวลาสิ้นสุด'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _room,
                    decoration: _dec('ห้องเรียน'),
                    validator: (v) => _required(v, 'กรุณากรอกห้องเรียน'),
                  ),
                  const SizedBox(height: 10),

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
                        child: const Text('ยกเลิก'),
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
