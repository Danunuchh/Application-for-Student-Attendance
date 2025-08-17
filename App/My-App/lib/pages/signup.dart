import 'package:flutter/material.dart';
import './login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // สีโทนเดียวกับภาพ
  static const Color kPrimary = Color(0xFF84A9EA); //ปุ่มลงทะเบียน
  static const Color kPrimaryLight = Color(0xFF84A9EA);
  static const Color kShadow = Color(0x1A000000);
  static const Color kBorder = Color(0xFF84A9EA); // เส้นกรอบช่อง
  static const Color kFocused = Color(0xFF88A8E8); //โฟกัสเมื่อกดที่ช่อง
  static const Color kBtn = Color(0xFF84A9EA); // ปุ่ม login 
  static const Color kBottom = Color(0xFFA6CAFA); // แถบล่าง

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
        fillColor: Colors.white, //สีกล่องข้อความทั้งหมด
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
                            child: Container(
                              child: Image.asset(
                                'assets/signup.png',
                                height: 250,
                                fit: BoxFit.contain,
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
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                  ),
                                  dropdownColor: Colors.white, // ทำให้พื้นหลัง dropdown เป็นสีขาว
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
                                      (v == null || v.trim().length < 3) //ให้กรอกชื่อมากกว่า 3
                                          ? 'กรุณากรอกชื่อ'
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
                                selectedColor: const Color(0xFFA6CAFA),
                                backgroundColor: Colors.white,
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
                                selectedColor: const Color(0xFFA6CAFA),
                                backgroundColor: Colors.white,
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
                          // เพิ่ม SizedBox เพื่อเพิ่มระยะห่าง
                          const SizedBox(height: 24),
                          Center(
                            child: ElevatedButton(
                              onPressed: _onSignUp,
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
                              child: const Text(
                                'ลงทะเบียน',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 1,
                                  color: Colors.white,
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
            ),
            Container(  //แถบล่าง
              padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 30),
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
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginPage(),
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
                      'เข้าสู่ระบบ',
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
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
