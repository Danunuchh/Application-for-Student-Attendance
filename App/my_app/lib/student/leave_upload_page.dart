import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaveUploadPage extends StatefulWidget {
  const LeaveUploadPage({super.key});

  @override
  State<LeaveUploadPage> createState() => _LeaveUploadPageState();
}

class _LeaveUploadPageState extends State<LeaveUploadPage> {
  final _formKey = GlobalKey<FormState>();
  String? _leaveType; // "ลากิจ" | "ลาป่วย"
  DateTime? _date;
  final _noteCtrl = TextEditingController();
  PlatformFile? _picked;
  bool _submitting = false;

  // ===== Theme tokens (โทนเดียวกันทุกคอนโทรล) =====
  static const _borderBlue = Color(0xFFBFD6FF);
  static const _chevronGrey = Color(0xFF6B7280);
  static const _ink = Color(0xFF1F2937);
  static const _hintGrey = Color(0xFF9CA3AF);
  static const _panelBg = Color(0xFFF6FAFF);
  static const _chipBg = Color.fromARGB(255, 254, 254, 254);
  static const _greenText = Color(0xFF16A34A);

  static const _radius = 20.0;
  static const _padV = 12.0;
  static const _padH = 16.0;
  static const _borderWidth = 1.5;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      allowedExtensions: const ['pdf', 'jpeg', 'png'],
    );
    if (res != null && res.files.isNotEmpty) {
      setState(() => _picked = res.files.single);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final first = DateTime(now.year - 1, 1, 1);
    final last = DateTime(now.year + 1, 12, 31);
    final d = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: first,
      lastDate: last,
      helpText: 'เลือกวันที่ลา',
      confirmText: 'ตกลง',
      cancelText: 'ยกเลิก',
      locale: const Locale('th', 'TH'),
    );
    if (d != null) setState(() => _date = d);
  }

  String _formatDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _submit() async {
    if (_leaveType == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกประเภทการลา')));
      return;
    }
    if (_date == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกวันที่ลา')));
      return;
    }
    if (_picked == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('กรุณาแนบไฟล์')));
      return;
    }

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('ส่งข้อมูลสำเร็จ'),
        content: Text(
          'ประเภท: $_leaveType\n'
          'วันที่ลา: ${_formatDate(_date!)}\n'
          'ไฟล์: ${_picked!.name}'
          '${_noteCtrl.text.isNotEmpty ? '\nหมายเหตุ: ${_noteCtrl.text}' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );

    setState(() {
      _leaveType = null;
      _date = null;
      _picked = null;
      _noteCtrl.clear();
      _submitting = false;
    });
  }

  // ====== ชุดตกแต่งกรอบอินพุตให้เหมือนกันทุกตัว ======
  InputDecoration _inputDecoration({String? hint, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: _hintGrey),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: _padH,
      vertical: _padV,
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.white, // ✅ มีพื้นหลังตลอด
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: _borderBlue, width: _borderWidth),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: _borderBlue, width: _borderWidth),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(_radius),
      borderSide: const BorderSide(color: _borderBlue, width: _borderWidth), // ✅ ไม่หนาขึ้น ไม่เปลี่ยนสี
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, // ปิด overlay ตอนเลื่อน
        foregroundColor: _ink,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'แนบไฟล์การลา',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      backgroundColor: Colors.white,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // แนบไฟล์ (โทนเดียวกับหน้า)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: const Color.from(alpha: 1, red: 1, green: 1, blue: 1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: SvgPicture.asset(
                      'assets/file.svg',
                      width: 36,
                      height: 36,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'แนบไฟล์ที่นี่',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 10,
                      ),
                      backgroundColor: const Color(0xFFBFD6FF),
                      foregroundColor: _ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    onPressed: _pickFile,
                    child: Text(_picked == null ? 'เลือกไฟล์' : 'เปลี่ยนไฟล์'),
                  ),
                  if (_picked != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _picked!.name,
                      style: const TextStyle(fontSize: 12, color: _chevronGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ประเภทการลา (Dropdown ลูกศรลง – กรอบฟ้า)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'ประเภทการลา',
                style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            InputDecorator(
              decoration: _inputDecoration().copyWith(
                filled: true,
                fillColor: Colors.white, // ✅ สีพื้นหลังกล่อง Dropdown
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _leaveType,
                  hint: const Text(
                    'เลือกประเภทการลา',
                    style: TextStyle(color: _hintGrey),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _chevronGrey,
                  ),
                  dropdownColor: const Color.fromARGB(255, 255, 255, 255), // ✅ สีพื้นหลังของเมนูที่แสดงออกมา
                  items: const [
                    DropdownMenuItem(
                      value: 'ลากิจ',
                      child: Text('ลากิจ'),
                    ),
                    DropdownMenuItem(
                      value: 'ลาป่วย',
                      child: Text('ลาป่วย'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _leaveType = v),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // วันที่ลา (แตะทั้งแถว เปิด DatePicker – โทนเดียวกัน)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'วันที่ลา',
                style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(_radius),
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 22,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_radius),
                    border: Border.all(color: const Color(0xFFBFD6FF), width: _borderWidth),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.event_outlined,
                        color: _chevronGrey,
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _date == null ? 'เลือกวันที่' : _formatDate(_date!),
                        style: TextStyle(
                          color: _date == null ? _hintGrey : _ink,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded, 
                        color: _chevronGrey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // หมายเหตุ (กรอบ/ขนาดเหมือนกัน)
            const Text(
              'หมายเหตุ',
              style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _noteCtrl,
              maxLines: 4,
              style: const TextStyle(color: _ink, fontSize: 14),
              decoration: _inputDecoration(
                hint: 'ระบุรายละเอียดเพิ่มเติม (ถ้ามี)',
              ),
            ),

            const SizedBox(height: 18),

            // ปุ่ม "ยืนยัน" เป็นตัวหนังสือสีเขียวอย่างเดียว
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _submitting ? null : _submit,
                style: TextButton.styleFrom(
                  foregroundColor: _greenText,
                  padding: EdgeInsets.zero,
                ),
                child: Text(
                  _submitting ? 'กำลังส่ง…' : 'ยืนยัน',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
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
