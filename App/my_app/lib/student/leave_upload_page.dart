import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

import 'package:my_app/components/button.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/config.dart';

const String apiBase = baseUrl;

class LeaveUploadPage extends StatefulWidget {
  const LeaveUploadPage({super.key});

  @override
  State<LeaveUploadPage> createState() => _LeaveUploadPageState();
}

class _LeaveUploadPageState extends State<LeaveUploadPage> {
  String? _studentId;
  String? _leaveType;
  String? _selectedCourseId;
  DateTime? _date;
  final TextEditingController _noteCtrl = TextEditingController();
  PlatformFile? _picked;
  bool _submitting = false;

  List<Map<String, dynamic>> _courses = [];
  bool _loadingCourses = true;

  static const Color _ink = Color(0xFF1F2937);

  @override
  void initState() {
    super.initState();
    _loadStudentId();
    _loadCourses();
  }

  Future<void> _loadStudentId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _studentId = prefs.getString('userId');
    });
  }

  // ===== โหลดรายวิชาของนักศึกษา =====
  Future<void> _loadCourses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      if (userId == null) return;

      final res = await http.get(
        Uri.parse('$apiBase/courses_api.php?type=show_student&user_id=$userId'),
      );

      if (res.statusCode == 200) {
        final json = jsonDecode(res.body);
        if (json['success'] == true && json['data'] is List) {
          setState(() {
            _courses = List<Map<String, dynamic>>.from(json['data']);
          });
        }
      }
    } catch (e) {
      debugPrint('โหลดรายวิชาล้มเหลว: $e');
    } finally {
      if (mounted) setState(() => _loadingCourses = false);
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  // ===== เลือกไฟล์ =====
  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: kIsWeb,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );

    if (res != null && res.files.isNotEmpty) {
      setState(() => _picked = res.files.single);
    }
  }

  Future<void> _confirmSubmit() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('ยืนยันการส่งใบลา'),
          content: const Text('ต้องการส่งเอกสารการลานี้ใช่หรือไม่'),
          actions: [
            TextButton(
              child: const Text('ยกเลิก'),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21BA0C),
                foregroundColor: Colors.white,
              ),
              child: const Text('ยืนยัน'),
              onPressed: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      _submit();
    }
  }

  // ===== เลือกวันที่ =====
  Future<void> _pickDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('th', 'TH'),
    );
    if (d != null) setState(() => _date = d);
  }

  String _formatDate(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  // ===== ส่งข้อมูล =====
  Future<void> _submit() async {
    if (_studentId == null ||
        _selectedCourseId == null ||
        _leaveType == null ||
        _date == null ||
        _picked == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกข้อมูลให้ครบ')));
      return;
    }

    setState(() => _submitting = true);

    try {
      final uri = Uri.parse('$apiBase/file_manage.php');
      final request = http.MultipartRequest('POST', uri);

      request.fields['userId'] = _studentId!;
      request.fields['course_id'] = _selectedCourseId!;
      request.fields['leave_type'] = _leaveType!;
      request.fields['leave_date'] = _formatDate(_date!);
      request.fields['reason'] = _noteCtrl.text;

      if (kIsWeb) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            _picked!.bytes!,
            filename: _picked!.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            _picked!.path!,
            filename: _picked!.name,
          ),
        );
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('อัปโหลดสำเร็จ')));
        _clearForm();
      } else {
        throw Exception(respStr);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('ผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _clearForm() {
    setState(() {
      _leaveType = null;
      _selectedCourseId = null;
      _date = null;
      _picked = null;
      _noteCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null ? 'เลือกวันที่' : _formatDate(_date!);

    InputDecoration _inputStyle(String label) {
      return InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF84A9EA), width: 2),
        ),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(title: 'แนบไฟล์การลา'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ================= แนบไฟล์ =================
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                SvgPicture.asset('assets/fileupload.svg', height: 64),
                const SizedBox(height: 12),
                Text(
                  _picked?.name ?? 'ยังไม่ได้เลือกไฟล์',
                  style: const TextStyle(
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'เลือกไฟล์',
                  onPressed: _pickFile,
                  backgroundColor: const Color(0xFFA6CAFA),
                  textColor: Colors.black,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ================= รายวิชา =================
          _loadingCourses
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _selectedCourseId,
                  decoration: _inputStyle('เลือกรายวิชา'),
                  items: _courses.map((c) {
                    return DropdownMenuItem<String>(
                      value: c['id'].toString(),
                      child: Text('${c['code']}  ${c['name']}'),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCourseId = v),
                ),

          const SizedBox(height: 20),

          // ================= ประเภทการลา =================
          DropdownButtonFormField<String>(
            value: _leaveType,
            decoration: _inputStyle('ประเภทการลา'),
            items: const [
              DropdownMenuItem(value: 'ลากิจ', child: Text('ลากิจ')),
              DropdownMenuItem(value: 'ลาป่วย', child: Text('ลาป่วย')),
            ],
            onChanged: (v) => setState(() => _leaveType = v),
          ),

          const SizedBox(height: 20),

          // ================= วันที่ =================
          InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: _inputStyle('วันที่ลา'),
              child: Text(dateText, style: const TextStyle(fontSize: 15)),
            ),
          ),

          const SizedBox(height: 20),

          // ================= หมายเหตุ =================
          TextField(
            controller: _noteCtrl,
            maxLines: 3,
            decoration: _inputStyle('หมายเหตุ'),
          ),

          const SizedBox(height: 24),

          Align(
            alignment: Alignment.centerRight,
            child: CustomButton(
              text: _submitting ? 'กำลังส่ง...' : 'ยืนยัน',
              onPressed: _submitting ? null : _confirmSubmit,
              backgroundColor: const Color(0xFF21BA0C),
              textColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
