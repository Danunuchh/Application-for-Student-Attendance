import 'package:flutter/material.dart';

class AddTeacherPage extends StatefulWidget {
  const AddTeacherPage({super.key});

  @override
  State<AddTeacherPage> createState() => _AddTeacherPageState();
}

class _AddTeacherPageState extends State<AddTeacherPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  static const _blueBorder = Color(0xFFB0C4DE);
  static const _shadow = Color(0x1A000000);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'เพิ่มอาจารย์',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            width: 360,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _blueBorder),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _label('ชื่อ - สกุล'),
                  _field(controller: _name, hint: 'เช่น ดร.สมชาย ใจดี'),
                  const SizedBox(height: 16),

                  _label('เบอร์โทรศัพท์'),
                  _field(controller: _phone, keyboardType: TextInputType.phone),
                  const SizedBox(height: 16),

                  _label('อีเมล'),
                  _field(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 20),

                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_name.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('กรอกชื่ออาจารย์'),
                            ),
                          );
                          return;
                        }
                        // ส่งกลับไปหน้า list
                        Navigator.pop<Map<String, dynamic>>(context, {
                          "name": _name.text.trim(),
                          "phone": _phone.text.trim(),
                          "email": _email.text.trim(),
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 2,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: const BorderSide(color: _blueBorder),
                        ),
                      ),
                      child: const Text('เพิ่ม'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 14.5)),
  );

  Widget _field({
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 10,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _blueBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
          borderSide: const BorderSide(color: _blueBorder, width: 1.4),
        ),
      ),
    );
  }
}
