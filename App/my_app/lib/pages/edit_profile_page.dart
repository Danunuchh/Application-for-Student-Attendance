// lib/pages/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  // controllers (dummy เริ่มต้น)
  final _username = TextEditingController(text: 'p_user');
  final _email = TextEditingController(text: 'p_user@email.com');
  final _firstName = TextEditingController(text: 'พีระพัฒน์');
  final _lastName = TextEditingController(text: 'อรุณศรี');
  final _phone = TextEditingController(text: '0812345678');
  final _address = TextEditingController(
    text: '233 หมู่ 9 ตำบลวังหิน อ.บางขัน จ.นครศรีธรรมราช',
  );

  // โทนสี/สไตล์ให้คล้ายภาพที่สอง
  static const Color _primary = Color(0xFF9BBDF9); // ฟ้าพาสเทลปุ่มใหญ่
  static const Color _accent = Color(0xFF6A9BF5); // เส้นขอบ input
  static const Color _ink = Color(0xFF1F2937); // สีตัวอักษรหลัก

  InputDecoration _field(String hint) => InputDecoration(
    hintText: hint,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: Color(0xFFAFC7FA), width: 1.8),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _accent, width: 2),
    ),
  );

  Widget _title(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8, top: 18),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const CustomAppBar(title: 'แก้ไขโปรไฟล์'),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: GestureDetector(
            // แตะพื้นหลังเพื่อซ่อนคีย์บอร์ด
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero / Illustration + Avatar ปุ่มเปลี่ยนรูป
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        // วงกลมรูปโปรไฟล์ + ไอคอนดินสอ
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 18,
                                    offset: Offset(0, 10),
                                    color: Color(0x1A000000),
                                  ),
                                ],
                                border: Border.all(
                                  color: const Color(0xFFE3ECFF),
                                ),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 56,
                                color: _accent,
                              ),
                            ),
                            Positioned(
                              bottom: -6,
                              right: -6,
                              child: Material(
                                color: _accent,
                                borderRadius: BorderRadius.circular(20),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(20),
                                  onTap: () {
                                    // TODO: เปิด image picker ถ้าจะใช้จริง (image_picker)
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'เปลี่ยนรูปโปรไฟล์ (ตัวอย่าง)',
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'เปลี่ยนรูปโปรไฟล์',
                          style: TextStyle(color: _accent),
                        ),
                      ],
                    ),
                  ),

                  // ฟอร์ม
                  _title('Username'),
                  TextFormField(
                    controller: _username,
                    decoration: _field('Username'),
                  ),

                  _title('Email'),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _field('Email'),
                    validator: (v) => (v == null || !v.contains('@'))
                        ? 'รูปแบบอีเมลไม่ถูกต้อง'
                        : null,
                  ),

                  _title('ชื่อจริง'),
                  TextFormField(
                    controller: _firstName,
                    decoration: _field('ชื่อจริง'),
                  ),

                  _title('นามสกุล'),
                  TextFormField(
                    controller: _lastName,
                    decoration: _field('นามสกุล'),
                  ),

                  _title('เบอร์โทรศัพท์'),
                  TextFormField(
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    decoration: _field('เบอร์โทรศัพท์'),
                  ),

                  _title('ที่อยู่'),
                  TextFormField(
                    controller: _address,
                    maxLines: 3,
                    decoration: _field('ที่อยู่'),
                  ),

                  const SizedBox(height: 24),

                  // ปุ่ม “บันทึกข้อมูล”
                  Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(0, 10),
                          color: Color(0x33000000),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: ส่งข้อมูลไป backend
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'บันทึกข้อมูลโปรไฟล์เรียบร้อย (dummy)',
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'บันทึกข้อมูล',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ปุ่ม “ยกเลิกการแก้ไข”
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'ยกเลิกการแก้ไข',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
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
}
