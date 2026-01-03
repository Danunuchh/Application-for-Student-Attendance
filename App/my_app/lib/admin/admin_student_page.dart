import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class AdminStudentPage extends StatefulWidget {
  const AdminStudentPage({super.key});

  @override
  State<AdminStudentPage> createState() => _AdminStudentPageState();
}

class _AdminStudentPageState extends State<AdminStudentPage> {
  static const Color _borderBlue = Color(0xFF88A8E8);

  int? _selectedYear;

  /// ====== ช่องค้นหา ======
  InputDecoration _searchDeco(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 1.5),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _borderBlue, width: 2),
    ),
    suffixIcon: const Icon(Icons.search),
  );

  /// ====== InputDecoration ใช้ใน Modal ======
  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      borderSide: const BorderSide(color: Color(0xFF4A86E8), width: 2),
    ),
  );

  /// ====== Modal เพิ่มนักศึกษา ======
  void _openAddStudentModal() {
    final formKey = GlobalKey<FormState>();
    final studentIdCtl = TextEditingController();
    final nameCtl = TextEditingController();

    bool canSave = false;

    void checkCanSave() {
      canSave =
          studentIdCtl.text.trim().isNotEmpty && nameCtl.text.trim().isNotEmpty;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'เพิ่มนักศึกษา',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),

                    /// รหัสนักศึกษา
                    TextFormField(
                      controller: studentIdCtl,
                      decoration: _dec('รหัสนักศึกษา'),
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        setModalState(() {
                          checkCanSave();
                        });
                      },
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกรหัสนักศึกษา'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    /// ชื่อ–นามสกุล
                    TextFormField(
                      controller: nameCtl,
                      decoration: _dec('ชื่อ – นามสกุล'),
                      onChanged: (_) {
                        setModalState(() {
                          checkCanSave();
                        });
                      },
                      validator: (v) => v == null || v.trim().isEmpty
                          ? 'กรุณากรอกชื่อ–นามสกุล'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    Row(
                      children: [
                        /// ยกเลิก
                        OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'ยกเลิก',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const Spacer(),

                        /// บันทึก (จาง → เข้ม)
                        FilledButton.icon(
                          onPressed: () {
                            if (!canSave) return;

                            if (!formKey.currentState!.validate()) return;

                            final studentId = studentIdCtl.text.trim();
                            final fullName = nameCtl.text.trim();

                            // TODO: เรียก API เพิ่มนักศึกษา
                            // print(studentId);
                            // print(fullName);

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('เพิ่มนักศึกษาเรียบร้อย'),
                              ),
                            );
                          },
                          label: const Text(
                            'บันทึก',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          icon: const Icon(Icons.check_circle_outline),
                          style: FilledButton.styleFrom(
                            backgroundColor: canSave
                                ? const Color(0xFF22C55E) // เขียวเข้ม
                                : const Color.fromARGB(255, 188, 246, 219), // 🟢 เขียวจาง
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// ====== UI หลัก ======
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'นักศึกษา',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF88A8E8)),
            onPressed: _openAddStudentModal,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ชั้นปี',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                final year = i + 1;
                final selected = _selectedYear == year;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selected ? _borderBlue : Colors.white,
                      foregroundColor: selected ? Colors.white : Colors.black,
                      side: const BorderSide(color: _borderBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => setState(() => _selectedYear = year),
                    child: Text('ปี $year'),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            /// ช่องค้นหาอยู่ล่างชั้นปี
            TextField(decoration: _searchDeco('รหัสนักศึกษา')),
          ],
        ),
      ),
    );
  }
}
