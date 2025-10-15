import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_app/components/custom_appbar.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  final _formKey = GlobalKey<FormState>();

  // controllers (ว่างไว้เพื่อเชื่อม PHP)
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _credit = TextEditingController();
  final _teacher = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  final _room = TextEditingController();
  final _sessions = TextEditingController();

  bool _canSubmit = false; // ✅ ปุ่มบันทึกจะเปิดเมื่อกรอกครบเท่านั้น

  static const _borderBlue = Color(0xFF9CA3AF);
  static const _hintGrey = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    // ฟังการเปลี่ยนแปลงทุกช่อง เพื่อตรวจว่ากรอกครบหรือยัง
    for (final c in [
      _name, _code, _credit, _teacher, _start, _end, _room, _sessions
    ]) {
      c.addListener(_recalcCanSubmit);
    }
  }

  void _recalcCanSubmit() {
    final ok = _name.text.trim().isNotEmpty &&
        _code.text.trim().isNotEmpty &&
        _credit.text.trim().isNotEmpty &&
        _teacher.text.trim().isNotEmpty &&
        _start.text.trim().isNotEmpty &&
        _end.text.trim().isNotEmpty &&
        _room.text.trim().isNotEmpty &&
        _sessions.text.trim().isNotEmpty;
    if (ok != _canSubmit) {
      setState(() => _canSubmit = ok);
    }
  }

  String? _required(String? v, String msg) =>
      (v == null || v.trim().isEmpty) ? msg : null;

InputDecoration _dec(String label, {String? hint, Widget? suffix}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    hintStyle: const TextStyle(color: _hintGrey),
    labelStyle: const TextStyle(color: Colors.black87),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

    // ปกติ
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),

    // ❌ ซ่อน error ทั้งข้อความและสีกรอบ
    errorStyle: const TextStyle(height: 0, color: Colors.transparent),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),

    suffixIcon: suffix,
  );
}

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _credit.dispose();
    _teacher.dispose();
    _start.dispose();
    _end.dispose();
    _room.dispose();
    _sessions.dispose();
    super.dispose();
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final now = TimeOfDay.now();
    final res = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (c, child) => MediaQuery(
        data: MediaQuery.of(c!).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (res != null) {
      final h = res.hour.toString().padLeft(2, '0');
      final m = res.minute.toString().padLeft(2, '0');
      ctrl.text = '$h:$m'; // ✅ ตัว listener จะไปเปิด/ปิดปุ่มให้เอง
    }
  }

  void _save() {
    // ป้องกันซ้ำอีกชั้น: ถ้าไม่ผ่าน validate จะไม่ pop
    if (!_formKey.currentState!.validate()) return;

    Navigator.pop(context, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _name.text.trim(),
      'code': _code.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: const CustomAppBar(title: 'เพิ่มคลาสเรียน'),
      body: LayoutBuilder(
        builder: (context, cons) {
          final twoCols = cons.maxWidth >= 560;
          final gap = twoCols ? 14.0 : 10.0;

          Widget colPair(Widget a, Widget b) => twoCols
              ? Row(children: [Expanded(child: a), SizedBox(width: gap), Expanded(child: b)])
              : Column(children: [a, SizedBox(height: gap), b]);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 5,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: Color(0xFF88A8E8), width: 1.5),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Form(
                  child: Column(
                    children: [
                      // หัวเรื่อง
                      Row(
                        children: const [
                          Icon(Icons.menu_book_outlined, size: 22, color: _borderBlue),
                          SizedBox(width: 8),
                          Text('ข้อมูลรายวิชา',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // วิชา
                      TextFormField(
                        controller: _name,
                        decoration: _dec('วิชา'),
                        validator: (v) => _required(v, 'กรุณากรอกชื่อวิชา'),
                      ),
                      SizedBox(height: gap),

                      // รหัสวิชา + หน่วยกิต
                      colPair(
                        TextFormField(
                          controller: _code,
                          decoration: _dec('รหัสวิชา'),
                          validator: (v) => _required(v, 'กรุณากรอกรหัสวิชา'),
                        ),
                        TextFormField(
                          controller: _credit,
                          decoration: _dec('หน่วยกิต'),
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          validator: (v) => _required(v, 'กรุณากรอกหน่วยกิต'),
                        ),
                      ),
                      SizedBox(height: gap),

                      // อาจารย์ผู้สอน
                      TextFormField(
                        controller: _teacher,
                        decoration: _dec('อาจารย์ผู้สอน'),
                        validator: (v) => _required(v, 'กรุณากรอกชื่ออาจารย์ผู้สอน'),
                      ),
                      SizedBox(height: gap),

                      // เวลา + ห้องเรียน
                      colPair(
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _start,
                                readOnly: true,
                                onTap: () => _pickTime(_start),
                                textAlign: TextAlign.center,
                                decoration: _dec('เวลาเริ่ม', hint: 'HH:mm'),
                                validator: (v) => _required(v, 'เลือกเวลาเริ่ม'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('—', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextFormField(
                                controller: _end,
                                readOnly: true,
                                onTap: () => _pickTime(_end),
                                textAlign: TextAlign.center,
                                decoration: _dec('เวลาสิ้นสุด', hint: 'HH:mm'),
                                validator: (v) => _required(v, 'เลือกเวลาสิ้นสุด'),
                              ),
                            ),
                          ],
                        ),
                        TextFormField(
                          controller: _room,
                          decoration: _dec('ห้องเรียน'),
                          validator: (v) => _required(v, 'กรุณากรอกห้องเรียน'),
                        ),
                      ),
                      SizedBox(height: gap),

                      // จำนวนครั้งที่ให้นักศึกษาลาได้
                      TextFormField(
                        controller: _sessions,
                        decoration: _dec('จำนวนครั้งที่ให้นักศึกษาลาได้'),
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        validator: (v) => _required(v, 'กรุณากรอกจำนวนครั้ง'),
                      ),

                      const SizedBox(height: 16),

                      // ปุ่มล่าง
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          // ✅ ปุ่มบันทึกจะถูก disable จนกรอกครบทุกช่อง
                          FilledButton.icon(
                            onPressed: _canSubmit ? _save : null,
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text('บันทึก'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: const Color(0xFF22C55E),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color.fromARGB(255, 161, 220, 182), // สีตอนปุ่มปิด
                              disabledForegroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
