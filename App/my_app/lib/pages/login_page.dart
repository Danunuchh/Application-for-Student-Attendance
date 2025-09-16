import 'package:flutter/material.dart';
import './signup.dart';
import '../teacher/courses_page.dart'; // NEW: หน้าคลาสเรียน
import 'home_pages.dart';

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
      borderSide: const BorderSide(color: kFocused, width: 2),
    ),
  );

  // NEW: ฟังก์ชันเข้าสู่ระบบ (mock) แล้วไปหน้า "คลาสเรียน"
  Future<void> _login() async {
    
    // ตรวจช่องว่างแบบง่ายๆ ดัก Error
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณากรอกอีเมลและรหัสผ่าน')));
      return;
    }

    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 600)); // mock แทน API
    if (!mounted) return;

    // ไปหน้า "คลาสเรียน" และปิดหน้า login (ย้อนกลับไม่ได้)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()), //HomePage  //CoursesPage
    );
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
                          'assets/login.png',
                          height: 250,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 80, color: kBorder),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
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
                        onPressed: () {},
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
                    // ปุ่มเข้าสู่ระบบ
                    Center(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login, // NEW
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          elevation: 6,
                          shadowColor: kPrimary.withOpacity(0.6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24), // มุมโค้ง
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 26, // ระยะรอบข้อความ
                            vertical: 10,
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text(
                                'เข้าสู่ระบบ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            Container(
              // ส่วนของปุ่ม "ลงทะเบียน"
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
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimary,
                          elevation: 4,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          'ลงทะเบียน',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
