import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class AddCoursePage extends StatefulWidget {
  const AddCoursePage({super.key});

  @override
  State<AddCoursePage> createState() => _AddCoursePageState();
}

class _AddCoursePageState extends State<AddCoursePage> {
  // controllers (dummy)
  final _name = TextEditingController(text: 'DATA MINING');
  final _code = TextEditingController(text: '11256043');
  final _credit = TextEditingController(text: '3');
  final _teacher = TextEditingController(text: 'ดร.รัตติกร สมบัติแก้ว');
  final _start = TextEditingController(text: '17:00');
  final _end = TextEditingController(text: '20:00');
  final _room = TextEditingController(text: 'E107');
  final _sessions = TextEditingController();

  static const _borderBlue = Color(0xFF88A8E8);

  InputDecoration _inputDec() => InputDecoration(
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),
  );

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

  void _save() {
    // ส่งค่ากลับไปเพิ่มในลิสต์
    Navigator.pop(context, {
      'id': DateTime.now().millisecondsSinceEpoch,
      'name': _name.text.trim(),
      'code': _code.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'เพิ่มคลาสเรียน'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: _borderBlue, width: 1.2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _RowField(
                  label: 'วิชา :',
                  child: TextField(controller: _name, decoration: _inputDec()),
                ),

                const SizedBox(height: 8),
                // รหัสวิชา + หน่วยกิต (Responsive)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _RowField(
                        label: 'รหัสวิชา :',
                        child: TextField(
                          controller: _code,
                          decoration: _inputDec(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: _RowField(
                        label: 'หน่วยกิต :',
                        labelMaxWidth: 72,
                        child: TextField(
                          controller: _credit,
                          decoration: _inputDec(),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                _RowField(
                  label: 'อาจารย์ผู้สอน :',
                  child: TextField(
                    controller: _teacher,
                    decoration: _inputDec(),
                  ),
                ),

                const SizedBox(height: 8),
                // เวลาเรียน + ห้องเรียน (Responsive)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _RowField(
                        label: 'เวลาเรียน :',
                        child: Row(
                          children: [
                            Flexible(
                              child: TextField(
                                controller: _start,
                                decoration: _inputDec(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('-', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Flexible(
                              child: TextField(
                                controller: _end,
                                decoration: _inputDec(),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RowField(
                        label: 'ห้องเรียน :',
                        child: TextField(
                          controller: _room,
                          decoration: _inputDec(),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                _RowField(
                  label: 'จำนวนครั้งที่ให้นักเรียน :',
                  child: TextField(
                    controller: _sessions,
                    decoration: _inputDec(),
                    keyboardType: TextInputType.number,
                  ),
                ),

                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {},
                      tooltip: 'ลบ',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.orange),
                      onPressed: () {},
                      tooltip: 'แก้ไข',
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: _save,
                      tooltip: 'บันทึก',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// แถวมาตรฐาน: "Label : [Widget]" (แก้ overflow ด้วย Flexible + maxWidth)
class _RowField extends StatelessWidget {
  final String label;
  final Widget child;

  /// จำกัดความกว้างสูงสุดของ label เพื่อไม่กินพื้นที่ input มากเกินไป
  final double labelMaxWidth;

  const _RowField({
    required this.label,
    required this.child,
    this.labelMaxWidth = 110,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: labelMaxWidth),
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(child: child),
      ],
    );
  }
}
