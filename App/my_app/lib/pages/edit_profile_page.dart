// lib/pages/edit_profile_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;
  final String role; // 'student' หรือ 'teacher'
  const EditProfilePage({super.key, required this.userId, required this.role});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool _loading = true;
  String? _error;
  bool _isEditing = false;

  // controllers
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _studentId = TextEditingController(); // เฉพาะ student
  final _teacherCode = TextEditingController(); // เฉพาะ teacher
  final _phone = TextEditingController();
  final _address = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetch(); // โหลดข้อมูลจริง
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _studentId.dispose();
    _teacherCode.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = null; });
    try {
      final p = await ProfileService.fetchProfile(
        userId: widget.userId,
        role: widget.role,
      );
      _username.text = p.username;
      _email.text = p.email;
      _firstName.text = p.firstName;
      _lastName.text = p.lastName;
      _phone.text = p.phone;
      _address.text = p.address;
      _studentId.text = p.studentId ?? '';
      _teacherCode.text = p.teacherCode ?? '';
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      final payload = UserProfile(
        id: widget.userId,
        username: _username.text.trim(),
        email: _email.text.trim(),
        firstName: _firstName.text.trim(),
        lastName: _lastName.text.trim(),
        phone: _phone.text.trim(),
        address: _address.text.trim(),
        studentId: widget.role == 'student' ? _studentId.text.trim() : null,
        teacherCode: widget.role == 'teacher' ? _teacherCode.text.trim() : null,
      );
      await ProfileService.updateProfile(
        userId: widget.userId,
        role: widget.role,
        payload: payload,
      );
      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')),
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  InputDecoration _field(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFAFC7FA), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFF6A9BF5), width: 2),
    ),
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 18),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        appBar: CustomAppBar(title: 'แก้ไขโปรไฟล์'),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'แก้ไขโปรไฟล์'),
        body: Center(child: Text('เกิดข้อผิดพลาด: $_error')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FF),
      appBar: CustomAppBar(
        title: 'แก้ไขโปรไฟล์',
        // ปุ่มแก้ไข/ยืนยัน อยู่ที่ AppBar ก็ได้
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _save,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title('Username'),
                TextFormField(
                  controller: _username,
                  readOnly: !_isEditing,
                  decoration: _field('Username'),
                ),
                _title('Email'),
                TextFormField(
                  controller: _email,
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _field('Email'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'รูปแบบอีเมลไม่ถูกต้อง'
                      : null,
                ),
                _title('ชื่อจริง'),
                TextFormField(
                  controller: _firstName,
                  readOnly: !_isEditing,
                  decoration: _field('ชื่อจริง'),
                ),
                _title('นามสกุล'),
                TextFormField(
                  controller: _lastName,
                  readOnly: !_isEditing,
                  decoration: _field('นามสกุล'),
                ),

                if (widget.role == 'student') ...[
                  _title('รหัสนักศึกษา'),
                  TextFormField(
                    controller: _studentId,
                    readOnly: !_isEditing,
                    decoration: _field('รหัสนักศึกษา'),
                  ),
                ],

                if (widget.role == 'teacher') ...[
                  _title('รหัสอาจารย์'),
                  TextFormField(
                    controller: _teacherCode,
                    readOnly: !_isEditing,
                    decoration: _field('รหัสอาจารย์'),
                  ),
                ],

                _title('เบอร์โทรศัพท์'),
                TextFormField(
                  controller: _phone,
                  readOnly: !_isEditing,
                  keyboardType: TextInputType.phone,
                  decoration: _field('เบอร์โทรศัพท์'),
                ),
                _title('ที่อยู่'),
                TextFormField(
                  controller: _address,
                  readOnly: !_isEditing,
                  maxLines: 3,
                  decoration: _field('ที่อยู่'),
                ),

                const SizedBox(height: 24),

                // ปุ่มล่างทางเลือก (ถ้าไม่ใช้ปุ่มบน AppBar)
                if (_isEditing) ...[
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9BBDF9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      setState(() => _isEditing = false);
                      _fetch(); // โหลดทับคืนค่าเดิม
                    },
                    child: const Text('ยกเลิกการแก้ไข'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
