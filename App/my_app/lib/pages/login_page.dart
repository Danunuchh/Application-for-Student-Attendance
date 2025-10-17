import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_home_page.dart';
import 'package:my_app/components/button.dart';
import 'package:my_app/pages/forgot_password.dart';
import 'package:my_app/pages/signup.dart';
import 'package:my_app/teacher/teacher_home_pages.dart';
import 'package:my_app/student/student_home_pages.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscure = true;

  // NEW: controller + loading state
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  bool _loading = false;

  // เพิ่มสีจากหน้า SignUpPage
  static const Color kPrimary = Color(0xFF84A9EA);
  static const Color kPrimaryLight = Color(0xFFAEC8F2);
  static const Color kShadow = Color(0x1A000000);
  static const Color kBorder = Color(0xFF88A8E8);
  static const Color kFocused = Color(0xFF88A8E8); //โฟกัสเมื่อกดที่ช่อง
  static const Color kBtn = Color(0xFFA7C7FF);
  static const Color kBottom = Color(0xFFA6CAFA);

  InputDecoration _fieldDeco(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kPrimary, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
    ),
  );

  // เปลี่ยนส่วนนี้ใน _login()
  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final url = Uri.parse('http://localhost:8000/login_api.php');  //10.0.2.2
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': pass}),
      );

      final data = jsonDecode(res.body);

    if (data['success'] == true) {
      final role = data['role_id'];
      final userId = data['user_id'];

      // เก็บสำหรับนำทาง/UI
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId.toString());
      await prefs.setString('role', role.toString());

      // นำทางตาม role (ของคุณถูกแล้ว)
      if (role == 'student') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => StudentHomePage(userId: userId.toString())));
      } else if (role == 'teacher') {
        Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => TeacherHomePage(userId: userId.toString())));
      } else if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin_home',
          arguments: {'userId': userId.toString()});
      }
    } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'เข้าสู่ระบบไม่สำเร็จ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    // NEW: ล้าง controller
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // image
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 22,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/login1.png',
                          height: 230,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 80, color: kBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      controller: _emailCtrl, // NEW
                      keyboardType: TextInputType.emailAddress,
                      decoration: _fieldDeco('อีเมล'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passCtrl, // NEW
                      obscureText: _obscure,
                      decoration: _fieldDeco('รหัสผ่าน').copyWith(
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _obscure = !_obscure),
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ForgotPasswordPage(), // ✅ ไปหน้านี้
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'ลืมรหัสผ่าน ?',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),

                  Center(
                    child: CustomButton(
                      text: 'เข้าสู่ระบบ',
                      onPressed: _loading ? null : _login,
                      loading: _loading,
                      backgroundColor: const Color(0xFF84A9EA),
                      textColor: Colors.white,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ✅ ส่วนล่าง (เฉพาะปุ่ม "ลงทะเบียน" เปลี่ยนเป็น CustomButton)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            decoration: const BoxDecoration(
              color: kBottom,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(22),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "ยังไม่มีบัญชีผู้ใช้?",
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                    const SizedBox(width: 8),

                    // ✅ ปุ่มลงทะเบียน (ใช้ CustomButton)
                    CustomButton(
                      text: 'ลงทะเบียน',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SignUpPage(),
                          ),
                        );
                      },
                      backgroundColor: kPrimary,
                      textColor: Colors.white,
                      fontSize: 15,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      )
    );
  }
}