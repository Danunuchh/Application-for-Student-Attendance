import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/models/subject.dart'; // ✅ ใช้ Subject จากโมเดลกลาง

class SubjectDetailPage extends StatelessWidget {
  final Subject subject;
  const SubjectDetailPage({super.key, required this.subject});

  static const _ink = Color(0xFF1F2937);
  static const _border = Color(0xFFCFE0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'ข้อมูลรายวิชา'),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(  //ตกแต่งกรอบข้อมูลรายวิชา
              color: Colors.white,
              border: Border.all(
                color: const Color(0xFF84A9EA),
                width: 1.5, // ✅ เส้นขอบหนา 2
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 6,
                  spreadRadius: 2, // ✅ เงาชัดขึ้น
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "วิชา",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: _ink,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 รหัสวิชา & หน่วยกิต
              LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 360;
                  final pairGap = narrow ? 12.0 : 16.0;
                  final child = [
                    _KV(k: "รหัสวิชา", v: subject.code),
                    _KV(k: "หน่วยกิต", v: subject.credits),
                  ];
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        child[0],
                        SizedBox(height: pairGap),
                        child[1],
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: child[0]),
                      const SizedBox(width: 16),
                      Expanded(child: child[1]),
                    ],
                  );
                },
              ),

              const SizedBox(height: 20),

              const Text(
                "อาจารย์ผู้สอน",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject.teacher,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.normal,
                  color: _ink,
                ),
              ),

              const SizedBox(height: 20),

              // 🔹 เวลา & ห้อง
              LayoutBuilder(
                builder: (context, c) {
                  final narrow = c.maxWidth < 360;
                  final child = [
                    _KV(k: "เวลา", v: subject.time),
                    _KV(k: "ห้อง", v: subject.room),
                  ];
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        child[0],
                        const SizedBox(height: 12),
                        child[1],
                      ],
                    );
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: child[0]),
                      const SizedBox(width: 16),
                      Expanded(child: child[1]),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String k;
  final String v;
  const _KV({required this.k, required this.v});

  static const _ink = SubjectDetailPage._ink;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold, // ✅ หัวข้อเป็นตัวหนา
            color: _ink,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          v.isEmpty ? '-' : v,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.normal, // ✅ ค่าเป็นตัวธรรมดา
            color: _ink,
          ),
        ),
      ],
    );
  }
}
