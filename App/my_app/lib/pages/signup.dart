import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import './login_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  static const Color kPrimary = Color(0xFF84A9EA);
  static const Color kPrimaryLight = Color(0xFF84A9EA);
  static const Color kShadow = Color(0x1A000000);
  static const Color kBorder = Color(0xFF84A9EA);
  static const Color kFocused = Color(0xFF88A8E8);
  static const Color kBtn = Color(0xFF84A9EA);
  static const Color kBottom = Color(0xFFA6CAFA);

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _customTitleCtrl = TextEditingController();

  static const String kOtherTitle = 'อื่นๆ (ระบุ)';
  final List<String> _titles = const ['นาย', 'นางสาว', kOtherTitle];
  String? _prefix;
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _signingUp = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    _customTitleCtrl.dispose();
    super.dispose();
  }

  InputDecoration _deco(String hint) => InputDecoration(
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kBorder, width: 1.4),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: kBorder, width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
    ),
  );

  Future<void> _sendToServer() async {
    final url = Uri.parse('http://localhost:8000/signup_api.php'); //10.0.2.2
    final data = {
      'prefix': _prefix == kOtherTitle ? _customTitleCtrl.text.trim() : _prefix,
      'full_name': _nameCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text.trim(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        if (result['success'] == true) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('ลงทะเบียนสำเร็จ')));
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message'] ?? 'เกิดข้อผิดพลาด')),
          );
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('อีเมลนี้ถูกใช้งานแล้ว')));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _onSignUp() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final needCustom = _prefix == kOtherTitle;
    final customOk = !needCustom || _customTitleCtrl.text.trim().isNotEmpty;

    if (!formOk || !customOk) {
      setState(() {});
      return;
    }

    setState(() => _signingUp = true);
    await _sendToServer();
    setState(() => _signingUp = false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Center(
                      child: SizedBox(
                        height: size.height * 0.26,
                        child: AspectRatio(
                          aspectRatio: 16 / 10,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Image.asset(
                              'assets/signup1.png',
                              height: 230,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                flex: 5,
                                child: DropdownButtonFormField<String>(
                                  value: _prefix,
                                  isExpanded: true,
                                  decoration: _deco('คำนำหน้า').copyWith(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                  dropdownColor: Colors.white,
                                  items: _titles
                                      .map(
                                        (t) => DropdownMenuItem(
                                          value: t,
                                          child: Text(
                                            t,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (v) {
                                    setState(() {
                                      _prefix = v;
                                      if (_prefix != kOtherTitle) {
                                        _customTitleCtrl.clear();
                                      }
                                    });
                                  },
                                  validator: (v) =>
                                      v == null ? 'เลือกคำนำหน้า' : null,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Flexible(
                                flex: 10,
                                child: TextFormField(
                                  controller: _nameCtrl,
                                  textInputAction: TextInputAction.next,
                                  decoration: _deco('ชื่อ-นามสกุล'),
                                  validator: (v) =>
                                      (v == null || v.trim().length < 3)
                                      ? 'กรุณากรอกชื่อ'
                                      : null,
                                ),
                              ),
                            ],
                          ),
                          if (_prefix == kOtherTitle) ...[
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _customTitleCtrl,
                              textInputAction: TextInputAction.next,
                              decoration: _deco('ระบุคำนำหน้าเอง'),
                              validator: (_) {
                                if (_prefix == kOtherTitle &&
                                    _customTitleCtrl.text.trim().isEmpty) {
                                  return 'โปรดระบุคำนำหน้าที่ต้องการ';
                                }
                                return null;
                              },
                            ),
                          ],
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            decoration: _deco('อีเมล'),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'กรอกอีเมล';
                              final ok =
                                  RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(v.trim()) &&
                                  v.trim().endsWith('@kmitl.ac.th');
                              return ok ? null : 'กรุณากรอกอีเมล @kmitl.ac.th';
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: _obscure1,
                            textInputAction: TextInputAction.next,
                            decoration: _deco('รหัสผ่าน').copyWith(
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure1 = !_obscure1),
                                icon: Icon(
                                  _obscure1
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (v) => (v != null && v.length >= 6)
                                ? null
                                : 'รหัสผ่านอย่างน้อย 6 ตัว',
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _confirmCtrl,
                            obscureText: _obscure2,
                            decoration: _deco('ยืนยันรหัสผ่าน').copyWith(
                              suffixIcon: IconButton(
                                onPressed: () =>
                                    setState(() => _obscure2 = !_obscure2),
                                icon: Icon(
                                  _obscure2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                            validator: (v) => (v == _passwordCtrl.text)
                                ? null
                                : 'รหัสผ่านไม่ตรงกัน',
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: CustomButton(
                              text: 'ลงทะเบียน',
                              onPressed: _onSignUp,
                              backgroundColor: kPrimary, // ใช้สีหลักของแอป
                              textColor: Colors.white, // ตัวอักษรสีขาว
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 140,
                vertical: 30,
              ),
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
                  // ✅ เปลี่ยนจาก ElevatedButton → CustomButton
                  child: CustomButton(
                    text: 'เข้าสู่ระบบ',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
                        ),
                      );
                    },
                    backgroundColor: kPrimary, // สีหลักของแอป
                    textColor: Colors.white,
                    fontSize: 16,
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
