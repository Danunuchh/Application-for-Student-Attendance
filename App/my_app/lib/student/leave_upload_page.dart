import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/components/button.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/student/approval_detail_page.dart';

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

  // ===== Theme tokens =====
  static const _borderBlue = Color(0xFFA6CAFA);
  static const _chevronGrey = Color(0xFF6B7280);
  static const _ink = Color(0xFF1F2937);
  static const _hintGrey = Color(0xFF9CA3AF);
  static const _greenText = Color(0xFF16A34A);

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true, // ✅ ขอ bytes มาด้วยถ้าระบบให้
      allowedExtensions: const ['pdf', 'jpeg', 'png', 'jpg'],
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

      // 🎨 ใช้ธีมสีฟ้า
      builder: (context, child) {
        final base = Theme.of(context);
        return Theme(
          data: base.copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4A86E8), // ฟ้าเข้ม (วงกลมวันที่เลือก)
              onPrimary: Colors.white, // สีตัวหนังสือบนวงกลม
              surface: Color.fromARGB(
                255,
                255,
                255,
                255,
              ), // พื้นหลังของ dialog (ฟ้าอ่อน)
              onSurface: Color(0xFF1F2937), // สีข้อความปกติ
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF4A86E8), // ปุ่มตกลง / ยกเลิก
                textStyle: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            datePickerTheme: const DatePickerThemeData(
              headerBackgroundColor: Color(0xFF4A86E8), // หัวปฏิทิน (เดือน/ปี)
              headerForegroundColor: Colors.white, // ตัวหนังสือบนหัว
              todayForegroundColor: MaterialStatePropertyAll(Color(0xFF4A86E8)),
              todayBackgroundColor: MaterialStatePropertyAll(Color(0x204A86E8)),
              rangePickerBackgroundColor: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
            ),
            dialogBackgroundColor: const Color(0xFFFFFFFF),
          ),
          child: child!,
        );
      },
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
    await Future<void>.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;

    // ✅ เตรียม payload ที่จะส่งต่อไปหน้า detail
    final item = <String, dynamic>{
      "date": _formatDate(_date!), // เช่น 2025-08-01
      "subject": "ใบลา", // ถ้าคุณมีวิชา/ชื่อเรื่องจริงๆ ค่อยเปลี่ยนตรงนี้
      "status": "รออนุมัติ",
      "students": "", // กรอกได้ตามจริง
      "leaveType": _leaveType!,
      "reason": _noteCtrl.text,
      "fileName": _picked!.name,
      "filePath": _picked!.path, // ✅ ใช้แสดงไฟล์จาก path
      "fileBytes": _picked!.bytes, // ✅ หรือใช้ bytes ถ้ามี (บางแพลตฟอร์ม)
    };

    // ไปหน้าแสดงรายละเอียดที่เราปรับให้รองรับไฟล์จริงไว้แล้ว
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ApprovalDetailPage(item: item)),
    );

    // (option) เคลียร์ฟอร์มหลังกลับมา
    if (!mounted) return;
    setState(() {
      _leaveType = null;
      _date = null;
      _picked = null;
      _noteCtrl.clear();
      _submitting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _date == null ? 'เลือกวันที่' : _formatDate(_date!);

    return Scaffold(
      appBar: const CustomAppBar(title: 'แนบไฟล์การลา'),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // ===== แนบไฟล์ =====
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
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
                      'assets/fileupload.svg',
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
                  CustomButton(
                    text: _picked == null ? 'เลือกไฟล์' : 'เปลี่ยนไฟล์',
                    onPressed: _pickFile,
                    backgroundColor: const Color(0xFFA6CAFA), // สีพื้นเดิม
                    textColor: _ink, // สีข้อความเดิม
                    fontSize: 15,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ===== ประเภทการลา =====
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'ประเภทการลา',
                style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFA6CAFA), width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _leaveType,
                  hint: const Text(
                    'เลือกประเภทการลา',
                    style: TextStyle(color: _hintGrey),
                  ),
                  isExpanded: true,
                  icon: const Icon(Icons.chevron_right, color: _chevronGrey),
                  dropdownColor: Colors.white,
                  items: const [
                    DropdownMenuItem(value: 'ลากิจ', child: Text('ลากิจ')),
                    DropdownMenuItem(value: 'ลาป่วย', child: Text('ลาป่วย')),
                  ],
                  onChanged: (v) => setState(() => _leaveType = v),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== วันที่ลา =====
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'วันที่ลา',
                style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 18,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _borderBlue, width: 1.5),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 6,
                      spreadRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Text(
                      dateText,
                      style: TextStyle(
                        color: _date == null ? _hintGrey : _ink,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: _chevronGrey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ===== หมายเหตุ =====
            const Text(
              'หมายเหตุ',
              style: TextStyle(fontWeight: FontWeight.w600, color: _ink),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _borderBlue, width: 1.5),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextFormField(
                controller: _noteCtrl,
                maxLines: 4,
                style: const TextStyle(color: _ink, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'ระบุรายละเอียดเพิ่มเติม (ถ้ามี)',
                  hintStyle: TextStyle(color: _hintGrey),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ===== ปุ่มยืนยัน =====
            Align(
              alignment: Alignment.centerRight,
              child: CustomButton(
                text: _submitting ? 'กำลังส่ง…' : 'ยืนยัน',
                onPressed: _submitting ? null : _submit,
                backgroundColor: const Color(0xFFA6CAFA), // ✅ ใช้สีเดียวกับปุ่มเดิม
                textColor: const Color.fromARGB(255, 0, 0, 0),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
