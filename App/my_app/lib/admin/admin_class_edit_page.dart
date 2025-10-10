import 'package:flutter/material.dart';

//หน้าแก้ไขวันเวลาเรียน
class ClassEditPage extends StatefulWidget {
  const ClassEditPage({
    super.key,
    required this.name,
    required this.code,
    this.credits = '3',
    this.teacher = '',
    this.startTime = '17:00',
    this.endTime = '20:00',
    this.room = '',
    this.attendCount = '',
  });

  final String name;
  final String code;
  final String credits;
  final String teacher;
  final String startTime;
  final String endTime;
  final String room;
  final String attendCount;

  @override
  State<ClassEditPage> createState() => _ClassEditPageState();
}

class _ClassEditPageState extends State<ClassEditPage> {
  static const _blue = Color(0xFFB0C4DE);
  static const _shadow = Color(0x1A000000);

  late final TextEditingController _nameC;
  late final TextEditingController _codeC;
  late final TextEditingController _creditC;
  late final TextEditingController _teacherC;
  late final TextEditingController _startC;
  late final TextEditingController _endC;
  late final TextEditingController _roomC;
  late final TextEditingController _attendC;

  @override
  void initState() {
    super.initState();
    _nameC = TextEditingController(text: widget.name);
    _codeC = TextEditingController(text: widget.code);
    _creditC = TextEditingController(text: widget.credits);
    _teacherC = TextEditingController(text: widget.teacher);
    _startC = TextEditingController(text: widget.startTime);
    _endC = TextEditingController(text: widget.endTime);
    _roomC = TextEditingController(text: widget.room);
    _attendC = TextEditingController(text: widget.attendCount);
  }

  @override
  void dispose() {
    _nameC.dispose();
    _codeC.dispose();
    _creditC.dispose();
    _teacherC.dispose();
    _startC.dispose();
    _endC.dispose();
    _roomC.dispose();
    _attendC.dispose();
    super.dispose();
  }

  InputDecoration _input({String? hint}) => InputDecoration(
    isDense: true,
    hintText: hint,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _blue),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: _blue, width: 1.4),
    ),
  );

  Widget _label(String text) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text));

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
          'คลาสเรียน',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: 360,
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _blue),
              boxShadow: const [
                BoxShadow(color: _shadow, blurRadius: 6, offset: Offset(0, 3)),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // วิชา
                _label('วิชา :'),
                TextField(controller: _nameC, decoration: _input()),
                const SizedBox(height: 14),

                // รหัสวิชา / หน่วยกิต
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('รหัสวิชา :'),
                          TextField(controller: _codeC, decoration: _input()),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('หน่วยกิต :'),
                          TextField(
                            controller: _creditC,
                            keyboardType: TextInputType.number,
                            decoration: _input(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // อาจารย์ผู้สอน
                _label('อาจารย์ผู้สอน :'),
                TextField(controller: _teacherC, decoration: _input()),
                const SizedBox(height: 14),

                // เวลาเรียน / ห้องเรียน
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('เวลาเรียน :'),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _startC,
                                  decoration: _input(hint: '17:00'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text('-', style: TextStyle(fontSize: 16)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _endC,
                                  decoration: _input(hint: '20:00'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('ห้องเรียน :'),
                          TextField(
                            controller: _roomC,
                            decoration: _input(hint: 'E107'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                _label('จำนวนครั้งที่เข้าเรียน :'),
                SizedBox(
                  width: 110,
                  child: TextField(
                    controller: _attendC,
                    keyboardType: TextInputType.number,
                    decoration: _input(),
                  ),
                ),
                const SizedBox(height: 14),

                // ปุ่มด้านล่าง: ลบ / แก้ไข / บันทึก
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _actionBtn(
                      icon: Icons.delete_outline,
                      onTap: () {
                        // TODO: ใส่ลบจริงเมื่อเชื่อมฐานข้อมูล
                        Navigator.pop(context, {
                          'deleted': true,
                          'code': _codeC.text,
                        });
                      },
                    ),
                    const SizedBox(width: 10),
                    _actionBtn(
                      icon: Icons.edit_outlined,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('โหมดแก้ไข (เดโม่)')),
                        );
                      },
                    ),
                    const SizedBox(width: 10),
                    _actionBtn(
                      icon: Icons.check,
                      onTap: () {
                        // บันทึก/ส่งค่ากลับ
                        Navigator.pop(context, {
                          'name': _nameC.text.trim(),
                          'code': _codeC.text.trim(),
                          'credits': _creditC.text.trim(),
                          'teacher': _teacherC.text.trim(),
                          'start': _startC.text.trim(),
                          'end': _endC.text.trim(),
                          'room': _roomC.text.trim(),
                          'attendCount': _attendC.text.trim(),
                        });
                      },
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

  Widget _actionBtn({required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [BoxShadow(color: Colors.white, blurRadius: 0)],
          ),
          child: Icon(icon, size: 22, color: Colors.black87),
        ),
      ),
    );
  }
}
