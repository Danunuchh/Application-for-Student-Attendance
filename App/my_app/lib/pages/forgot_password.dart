import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/config.dart';
import 'package:my_app/pages/reset_password_page.dart';
import 'package:my_app/pages/login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.onSubmit});

  /// เรียกหลังจาก OTP ผ่านแล้ว
  final Future<void> Function(String email, String otp)? onSubmit;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();

  bool _otpSent = false;
  bool _sendingOtp = false;
  bool _submitting = false;

  // ---------- palette ----------
  static const Color _hintGrey = Color(0xFF9CA3AF);
  static const Color _borderBlue = Color(0xFF9CA3AF);

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  // ---------- Validators ----------
  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    if (!ok) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String? _validateOtp(String? v) {
    if (!_otpSent) return null;
    if (v == null || v.isEmpty) return 'กรุณากรอกรหัสยืนยัน';
    if (v.length != 6) return 'รหัสต้องเป็นตัวเลข 6 หลัก';
    return null;
  }

  // ---------- ขอรหัส OTP ----------
  Future<void> _sendOtp() async {
    if (_validateEmail(_emailCtrl.text) != null) {
      _formKey.currentState?.validate();
      return;
    }

    setState(() => _sendingOtp = true);

    try {
      final url = Uri.parse('${baseUrl}/forgot_password_api.php');

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _emailCtrl.text.trim()}),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        setState(() => _otpSent = true);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'ส่งรหัสแล้ว')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'ส่งรหัสไม่สำเร็จ')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
      );
    } finally {
      if (mounted) setState(() => _sendingOtp = false);
    }
  }

  // ---------- ขั้นตอนต่อไป ----------
  Future<void> _handleSubmit() async {
    if (!_otpSent) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาขอรหัสยืนยันก่อน')));
      return;
    }

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    try {
      final url = Uri.parse('${baseUrl}/verify_otp_api.php');

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _emailCtrl.text.trim(),
          'otp': _otpCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        // ✅ OTP ถูก → ไปหน้าเปลี่ยนรหัสผ่าน
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordPage(email: _emailCtrl.text.trim()),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'OTP ไม่ถูกต้อง')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่ได้')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // ---------- InputDecoration ----------
  InputDecoration _dec(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderBlue, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF88A8E8), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
      ),
      suffixIcon: suffix,
      errorStyle: const TextStyle(height: 0),
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF000000), size: 18),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
            );
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/logoadmin.png',
                      height: 220,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.image, size: 80),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'ลืมรหัสผ่าน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Email + ขอรหัส ----------
                    TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            decoration: _dec('อีเมล'),
                          ),
                        const SizedBox(width: 12),
                  
                    // ---------- OTP ----------
                    if (_otpSent) ...[
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _otpCtrl,
                        keyboardType: TextInputType.number,
                        validator: _validateOtp,
                        decoration: _dec('รหัสยืนยัน (OTP)', hint: '6 หลัก'),
                      ),
                    ],
                    const SizedBox(height: 28),

                    Row(
                      children: [
                        Expanded(
                          child: CustomButton(
                            text: 'ขอรหัส OTP',
                            onPressed: _sendingOtp ? null : _sendOtp,
                            loading: _sendingOtp, // ✅ ใช้ตัวนี้ถูกต้อง
                            backgroundColor: const Color(0xFF4A86E8),
                            textColor: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            text: 'ยืนยัน OTP',
                            onPressed: _submitting ? null : _handleSubmit,
                            loading: _submitting,
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
        ),
      ),
    );
  }
}
