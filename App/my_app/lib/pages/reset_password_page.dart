import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/config.dart';
import 'package:my_app/pages/login_page.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;

  const ResetPasswordPage({super.key, required this.email});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _submitting = false;
  bool _obscure1 = true;
  bool _obscure2 = true;

  static const Color _hintGrey = Color(0xFF9CA3AF);
  static const Color _borderBlue = Color(0xFF9CA3AF);

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  // ---------- Validators ----------
  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่านใหม่';
    if (v.length < 6) return 'รหัสผ่านอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
    if (v != _passwordCtrl.text) return 'รหัสผ่านไม่ตรงกัน';
    return null;
  }

  // ---------- เปลี่ยนรหัสผ่าน ----------
  Future<void> _handleResetPassword() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _submitting = true);

    try {
      final url = Uri.parse('${baseUrl}reset_password_api.php');

      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.email,
          'new_password': _passwordCtrl.text.trim(),
        }),
      );

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['success'] == true) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('เปลี่ยนรหัสผ่านสำเร็จ')));

        if (!mounted) return;

        Future.delayed(const Duration(milliseconds: 300), () {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginPage()),
            (route) => false,
          );
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['message'] ?? 'เปลี่ยนรหัสผ่านไม่สำเร็จ'),
          ),
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
  InputDecoration _dec(String label, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      hintStyle: const TextStyle(color: _hintGrey),
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
                      'เปลี่ยนรหัสผ่าน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ---------- Password ----------
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure1,
                      validator: _validatePassword,
                      decoration: _dec(
                        'รหัสผ่านใหม่',
                        suffix: IconButton(
                          icon: Icon(
                            _obscure1 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscure1 = !_obscure1),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ---------- Confirm Password ----------
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: _obscure2,
                      validator: _validateConfirm,
                      decoration: _dec(
                        'ยืนยันรหัสผ่านใหม่',
                        suffix: IconButton(
                          icon: Icon(
                            _obscure2 ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () =>
                              setState(() => _obscure2 = !_obscure2),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ---------- Submit ----------
                    CustomButton(
                      text: 'ยืนยันการเปลี่ยนรหัสผ่าน',
                      onPressed: _submitting ? null : _handleResetPassword,
                      loading: _submitting,
                      backgroundColor: const Color(0xFF21BA0C),
                      textColor: Colors.white,
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
