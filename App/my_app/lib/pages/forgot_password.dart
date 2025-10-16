import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key, this.onSubmit});

  /// ถ้าต้องการต่อกับ backend ให้ส่ง callback นี้มา
  final Future<void> Function(String email, String newPassword)? onSubmit;

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _hidePass = true;
  bool _hideConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกอีเมล';
    final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
    if (!ok) return 'รูปแบบอีเมลไม่ถูกต้อง';
    return null;
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'กรุณากรอกรหัสผ่านใหม่';
    if (v.length < 6) return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
    return null;
  }

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'กรุณายืนยันรหัสผ่าน';
    if (v != _passCtrl.text) return 'รหัสผ่านไม่ตรงกัน';
    return null;
  }

  Future<void> _handleSubmit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    if (widget.onSubmit != null) {
      setState(() => _submitting = true);
      try {
        await widget.onSubmit!.call(_emailCtrl.text.trim(), _passCtrl.text);
      } finally {
        if (mounted) setState(() => _submitting = false);
      }
    }
    // ไม่ใช้ snackbar ตามที่ตั้งใจ — เปลี่ยนหน้าหรือ pop ได้จากภายนอก
  }

  InputDecoration _decorate(
    String hint, {
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xFF84A9EA), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final isNarrow = mq.size.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // โลโก้ในกรอบเส้นฟ้า
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 22,
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/forgot1.png',
                          height: 230,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.image, size: 80),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Padding(
                      padding: EdgeInsets.only(left: 4, bottom: 12),
                      child: Text(
                        'ตั้งค่ารหัสผ่านใหม่',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937), // เทาเข้มอ่านง่าย
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // อีเมล
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                      decoration: _decorate('อีเมล'),
                    ),
                    const SizedBox(height: 20),

                    // รหัสผ่านใหม่
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _hidePass,
                      validator: _validatePass,
                      decoration: _decorate(
                        'รหัสผ่านใหม่',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hidePass = !_hidePass),
                          icon: Icon(
                            _hidePass ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ยืนยันรหัสผ่าน
                    TextFormField(
                      controller: _confirmCtrl,
                      obscureText: _hideConfirm,
                      validator: _validateConfirm,
                      decoration: _decorate(
                        'ยืนยันรหัสผ่าน',
                        suffixIcon: IconButton(
                          onPressed: () =>
                              setState(() => _hideConfirm = !_hideConfirm),
                          icon: Icon(
                            _hideConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),

                    // ปุ่มสีเขียว (ตัวอักษรสีเขียว ตามภาพ)
                    CustomButton(
                      text: 'บันทึกรหัสผ่านใหม่',
                      onPressed: _handleSubmit,
                      backgroundColor: const Color(0xFF84A9EA),
                      textColor: const Color.fromARGB(255, 255, 255, 255),
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
