import 'package:flutter/material.dart';
import './login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // สีโทนเดียวกับภาพ
  static const Color kBorder = Color(0xFF88A8E8); // เส้นกรอบช่อง
  static const Color kFocused = Color(0xFF648CE0); // โฟกัส
  static const Color kBtn = Color(0xFFA7C7FF); // ปุ่ม
  static const Color kBottom = Color(0x99AECDFE); // แถบล่างโปร่ง

  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _customTitleCtrl = TextEditingController();

  // ฟอร์มเพิ่มเติม
  static const String kOtherTitle = 'อื่นๆ (ระบุ)';
  final List<String> _titles = const ['นาย', 'นางสาว', kOtherTitle];
  String? _title; // คำนำหน้า
  String? _gender; // 'ชาย' หรือ 'หญิง'
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
      borderSide: const BorderSide(color: kFocused, width: 2),
    ),
  );

  Future<void> _onSignUp() async {
    final formOk = _formKey.currentState?.validate() ?? false;
    final needCustom = _title == kOtherTitle;
    final customOk = !needCustom || _customTitleCtrl.text.trim().isNotEmpty;

    if (!formOk || _gender == null || !customOk) {
      setState(() {});
      return;
    }

    setState(() => _signingUp = true);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    setState(() => _signingUp = false);
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ (ทดสอบ)')));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // ปิดการแสดงปุ่ม back ที่อัตโนมัติ
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // ใช้ pop เพื่อย้อนกลับไปหน้าล็อกอิน
          },
        ),
        title: const Text('สมัครสมาชิก'),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 170),
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
                          child: Container(
                            color: const Color(0xFFEFF5FF),
                            child: Image.asset(
                              'assets/illustrations/signup.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image,
                                size: 80,
                                color: kBorder,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                                value: _title,
                                isExpanded: true,
                                decoration: _deco('คำนำหน้า').copyWith(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 10,
                                  ),
                                ),
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
                                    _title = v;
                                    if (_title != kOtherTitle) {
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
                                    ? 'กรอกชื่ออย่างน้อย 3 ตัวอักษร'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        if (_title == kOtherTitle) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _customTitleCtrl,
                            textInputAction: TextInputAction.next,
                            decoration: _deco('ระบุคำนำหน้าเอง'),
                            validator: (_) {
                              if (_title == kOtherTitle &&
                                  _customTitleCtrl.text.trim().isEmpty) {
                                return 'โปรดระบุคำนำหน้าที่ต้องการ';
                              }
                              return null;
                            },
                          ),
                        ],

                        const SizedBox(height: 14),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              'เพศ',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('ชาย'),
                              selected: _gender == 'ชาย',
                              onSelected: (_) =>
                                  setState(() => _gender = 'ชาย'),
                              selectedColor: kBtn,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: kBorder),
                              ),
                            ),
                            ChoiceChip(
                              label: const Text('หญิง'),
                              selected: _gender == 'หญิง',
                              onSelected: (_) =>
                                  setState(() => _gender = 'หญิง'),
                              selectedColor: kBtn,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: kBorder),
                              ),
                            ),
                          ],
                        ),
                        if (_gender == null)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                'โปรดเลือกเพศ',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: _deco('อีเมล'),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรอกอีเมล';
                            final ok = RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(v.trim());
                            return ok ? null : 'รูปแบบอีเมลไม่ถูกต้อง';
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
                                    ? Icons.visibility
                                    : Icons.visibility_off,
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
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                          validator: (v) => (v == _passwordCtrl.text)
                              ? null
                              : 'รหัสผ่านไม่ตรงกัน',
                        ),
                        const SizedBox(height: 22),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signingUp ? null : _onSignUp,
                            style: ElevatedButton.styleFrom(
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: kBtn,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              shadowColor: Colors.black26,
                            ),
                            child: _signingUp
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                    ),
                                  )
                                : const Text(
                                    'ลงทะเบียน',
                                    style: TextStyle(
                                      fontSize: 18,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
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
                    child: ElevatedButton(
                      onPressed: () {
                        // เปลี่ยนกลับไปที่หน้าล็อกอิน
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: kBtn,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                      ),
                      child: const Text(
                        'เข้าสู่ระบบ',
                        style: TextStyle(fontSize: 16, letterSpacing: 0.2),
                      ),
                    ),
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
