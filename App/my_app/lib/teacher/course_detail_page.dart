import 'package:flutter/material.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseName;
  final String courseCode;

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

  // ----- ดัมมี่รายละเอียดวิชา -----
  final String _credit = '3';
  final String _teacher = 'ดร.รัตติกร สมบัติแก้ว';
  final String _time = '17:00 - 20:00';
  final String _room = 'E107';

  // ----- ดัมมี่รายชื่อนศ. (ต้องเป็น List ปกติ เพื่อให้ลบได้) -----
  final List<Map<String, String>> _students = [
    {'id': '65200020', 'name': 'นางสาวกวิสรา เชษเฐียร'},
    {'id': '65200128', 'name': 'นางสาวดนุชน หฤทดงหลาง'},
    {'id': '65200001', 'name': 'นายปิยะพงษ์ ใจดี'},
    {'id': '65200002', 'name': 'นางสาวอาภาภรณ์ ทองดี'},
  ];

  late List<Map<String, String>> _filtered;
  final _searchCtl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filtered = List.of(_students);
    _searchCtl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtl.removeListener(_onSearch);
    _searchCtl.dispose();
    super.dispose();
  }

  void _onSearch() {
    final q = _searchCtl.text.trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = List.of(_students);
      } else {
        _filtered = _students
            .where(
              (s) =>
                  s['id']!.contains(q) ||
                  s['name']!.toLowerCase().contains(q.toLowerCase()),
            )
            .toList();
      }
    });
  }

  Future<bool?> _confirmDeleteStudent(String id, String name) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
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

  void _deleteStudentAt(int filteredIndex) {
    final removed = _filtered[filteredIndex];
    setState(() {
      _students.removeWhere((s) => s['id'] == removed['id']);
      _filtered.removeAt(filteredIndex);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ลบ ${removed['id']} - ${removed['name']}')),
    );
  }

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

  Widget _labelValue(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'คลาสเรียน',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          // การ์ดรายละเอียดวิชา
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
                children: [
                  _labelValue('วิชา', widget.courseName),
                  Row(
                    children: [
                      Expanded(
                        child: _labelValue('รหัสวิชา', widget.courseCode),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: _labelValue('หน่วยกิต', _credit)),
                    ],
                  ),
                  _labelValue('อาจารย์ผู้สอน', _teacher),
                  Row(
                    children: [
                      Expanded(child: _labelValue('เวลา', _time)),
                      const SizedBox(width: 12),
                      Expanded(child: _labelValue('ห้อง', _room)),
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

          // รายชื่อนักศึกษา + ถังขยะสีแดง
          if (_filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Text('ไม่พบนักศึกษาตามที่ค้นหา'),
              ),
            )
          else
            ...List.generate(_filtered.length, (index) {
              final s = _filtered[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: _borderBlue, width: 1.2),
                  ),
                  child: ListTile(
                    title: Text(
                      s['id']!,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(s['name']!),
                    trailing: IconButton(
                      tooltip: 'ลบนักศึกษา',
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        final ok = await _confirmDeleteStudent(
                          s['id']!,
                          s['name']!,
                        );
                        if (ok == true) _deleteStudentAt(index);
                      },
                    ),
                    onTap: () {}, // เผื่ออนาคตเปิดโปรไฟล์นักศึกษา
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
