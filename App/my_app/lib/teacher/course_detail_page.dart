import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseName; // รับมาจากหน้าก่อน
  final String courseCode; // รับมาจากหน้าก่อน

  const CourseDetailPage({
    super.key,
    required this.courseName,
    required this.courseCode,
  });

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  static const _borderBlue = Color(0xFF88A8E8);

  // ====== ข้อมูลงานจริง (เริ่ม null รอรับจาก PHP) ======
  String? _credit;
  String? _teacher;
  String? _time; // ex. '17:00 - 20:00'
  String? _room;

  // ชื่อวิชา/รหัสวิชาให้แก้ไขได้ (สำเนาจาก constructor)
  late String _name;
  late String _code;

  // รายชื่อนักศึกษา (เริ่มว่าง รอโหลดจาก PHP)
  final List<Map<String, String>> _students = [];
  late List<Map<String, String>> _filtered;

  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _name = widget.courseName;
    _code = widget.courseCode;

    _filtered = List.of(_students);
    _searchCtl.addListener(_onSearch);

    // TODO: เรียก PHP แล้ว setState ค่ารายละเอียด/รายชื่อนักศึกษา
    // _fetchCourseDetail();
    // _fetchStudents();
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_onSearch);
    _searchCtl.dispose();
    super.dispose();
  }

  // ====== ค้นหา ======
  void _onSearch() {
    final q = _searchCtl.text.trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_students);
      } else {
        _filtered = _students
            .where(
              (s) =>
                  (s['id'] ?? '').contains(q) ||
                  (s['name'] ?? '').toLowerCase().contains(q.toLowerCase()),
            )
            .toList();
      }
    });
  }

  // ====== Dialog/BottomSheet helpers ======
  InputDecoration _fieldDec(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
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
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),
  );

  // ====== ยืนยันการลบ ======
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
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }

  // ====== ฟังก์ชันลบ ======
  void _deleteCourse() async {
    final ok = await _confirmDeleteCourse();
    if (ok == true) {
      // TODO: call PHP ลบรายวิชา แล้วค่อย pop กลับ
      if (!mounted) return;
      Navigator.pop(context, {'deleteCourse': true, 'courseCode': _code});
    }
  }

  void _deleteStudentAt(int index) async {
    final s = _filtered[index];
    final ok = await _confirmDeleteStudent(s['id'] ?? '-', s['name'] ?? '-');
    if (ok == true) {
      // TODO: call PHP ลบนักศึกษาคนนี้
      setState(() {
        _students.removeWhere((e) => e['id'] == s['id']);
        _filtered.removeAt(index);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ ${s['id'] ?? '-'} - ${s['name'] ?? '-'}')),
      );
    }
  }

  // ====== ปุ่มแก้ไขรายวิชา ======
  void _openEditCourse() {
    final nameCtl = TextEditingController(text: _name);
    final codeCtl = TextEditingController(text: _code);
    final creditCtl = TextEditingController(text: _credit ?? '');
    final teacherCtl = TextEditingController(text: _teacher ?? '');
    final timeCtl = TextEditingController(text: _time ?? '');
    final roomCtl = TextEditingController(text: _room ?? '');

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
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
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
                  decoration: _fieldDec('วิชา'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกชื่อวิชา'
                      : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: codeCtl,
                  decoration: _fieldDec('รหัสวิชา'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'กรุณากรอกรหัสวิชา'
                      : null,
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: creditCtl,
                  decoration: _fieldDec('หน่วยกิต'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: teacherCtl,
                  decoration: _fieldDec('อาจารย์ผู้สอน'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: timeCtl,
                  decoration: _fieldDec('เวลา'),
                ),
                const SizedBox(height: 10),

                TextFormField(
                  controller: roomCtl,
                  decoration: _fieldDec('ห้อง'),
                ),

                const SizedBox(height: 14),
                Row(
                  children: [
                    // ปุ่มยกเลิก
                    OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: const Color(0xFFF44336), // ✅ พื้นหลังขาว
                        side: const BorderSide(color: Color(0xFFF44336), width: 1.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12), // ✅ มุมโค้ง
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'ยกเลิก',
                        style: TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // ปุ่มบันทึก
                    FilledButton.icon(
                      onPressed: () {
                        if (!formKey.currentState!.validate()) return;

                        // ✅ จุดเชื่อมต่อ PHP
                        setState(() {
                          _name = nameCtl.text.trim();
                          _code = codeCtl.text.trim();
                          _credit = creditCtl.text.trim().isEmpty
                              ? null
                              : creditCtl.text.trim();
                          _teacher = teacherCtl.text.trim().isEmpty
                              ? null
                              : teacherCtl.text.trim();
                          _time = timeCtl.text.trim().isEmpty
                              ? null
                              : timeCtl.text.trim();
                          _room = roomCtl.text.trim().isEmpty
                              ? null
                              : roomCtl.text.trim();
                        });

                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('บันทึกการแก้ไขเรียบร้อย'),
                          ),
                        );
                      },
                      label: const Text(
                        'บันทึก',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E), // ✅ เขียวสด
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

  // ====== helper แสดง label + value (รองรับหลายบรรทัด) ======
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
              overflow: TextOverflow.visible,
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
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // ---------------- การ์ดรายละเอียดรายวิชา ----------------
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
                  _kv('เวลา', _time),
                  _kv('ห้อง', _room),

                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // ปุ่มลบ (ซ้าย)
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

                      // ปุ่มแก้ไข (ขวา)
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
                          side: const BorderSide(color: Color(0xFFD98C06)),
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

          // ---------------- ช่องค้นหา ----------------
          TextField(controller: _searchCtl, decoration: _searchDeco()),
          const SizedBox(height: 16),

          // ---------------- รายชื่อนักศึกษา ----------------
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
              return TextBox(
                title: s['name'],
                subtitle: s['id'],
                trailing: IconButton(
                  tooltip: 'ลบนักศึกษา',
                  icon: const Icon(Icons.delete, color: Color(0xFFF44336)),
                  onPressed: () => _deleteStudentAt(index),
                ),
              );
            }),
        ],
      ),
    );
  }
}
