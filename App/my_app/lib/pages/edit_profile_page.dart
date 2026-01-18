import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String? _resolvedUserId; // ✅ userId ที่ใช้จริงหลังเช็ค/ดึงจาก prefs

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
    _init(); // ✅ resolve userId แล้วค่อยโหลดข้อมูล
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

  // ✅ ดึง userId จาก constructor หรือ SharedPreferences
  Future<void> _init() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      var uid = widget.userId.trim();

      // ถ้าไม่ได้ส่งมาจากหน้า Home (กรณี hot restart / ไม่มีพารามิเตอร์)
      if (uid.isEmpty) {
        final prefs = await SharedPreferences.getInstance();
        uid = (prefs.getString('userId') ?? '').trim();
      }

      if (uid.isEmpty) {
        throw Exception('ไม่พบ userId (กรุณาเข้าสู่ระบบใหม่)');
      }

      _resolvedUserId = uid;
      await _fetch(); // โหลดข้อมูลโปรไฟล์จริง
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _fetch() async {
    if (_resolvedUserId == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final p = await ProfileService.fetchProfile(
        userId: _resolvedUserId!,
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
    if (_resolvedUserId == null) {
      setState(() => _error = 'ไม่พบ userId สำหรับบันทึก');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final payload = UserProfile(
        id: _resolvedUserId!,
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
        userId: _resolvedUserId!,
        role: widget.role,
        payload: payload,
      );

      if (!mounted) return;
      setState(() => _isEditing = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ')));
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
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
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
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: CustomAppBar(
        title: 'แก้ไขโปรไฟล์',
        // actions: [
        //   if (!_isEditing)
        //     IconButton(
        //       icon: const Icon(Icons.edit),
        //       onPressed: () => setState(() => _isEditing = true),
        //     )
        //   else
        //     IconButton(
        //       icon: const Icon(Icons.check),
        //       onPressed: _save,
        //     ),
        // ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _title('Email'),
                TextFormField(
                  controller: _email,
                  readOnly: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  keyboardType: TextInputType.none,
                  focusNode: FocusNode(canRequestFocus: false),
                  decoration: _field('Email'),
                  // readOnly: !_isEditing,
                  // keyboardType: TextInputType.emailAddress,
                  // decoration: _field('Email'),
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
                    readOnly: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.none,
                    focusNode: FocusNode(canRequestFocus: false),
                    decoration: _field('รหัสนักศึกษา'),
                  ),
                ],

                if (widget.role == 'teacher') ...[
                  _title('รหัสอาจารย์'),
                  TextFormField(
                    controller: _teacherCode,
                    readOnly: true,
                    showCursor: false,
                    enableInteractiveSelection: false,
                    keyboardType: TextInputType.none,
                    focusNode: FocusNode(canRequestFocus: false),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'แก้ไขโปรไฟล์',
                        onPressed: () => setState(() => _isEditing = true),
                        backgroundColor: const Color.fromARGB(
                          255,
                          248,
                          172,
                          51,
                        ),
                        textColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: 'บันทึกข้อมูล',
                        onPressed: () async {
                          await _save(); // ✅ บันทึกข้อมูล
                          setState(
                            () => _isEditing = false,
                          ); // ✅ ออกจากโหมดแก้ไข
                        },
                        backgroundColor: const Color(0xFF21BA0C),
                        textColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
