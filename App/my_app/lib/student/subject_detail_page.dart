import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/models/subject.dart';

class SubjectDetailPage extends StatelessWidget {
  final Subject subject;

  const SubjectDetailPage({
    super.key,
    required this.subject,
  });

  static const Color _borderBlue = Color(0xFF88A8E8);
  static const double _labelW = 110;

  Widget _kv(String label, String? value, {int? maxLines}) {
    final display =
        (value == null || value.trim().isEmpty) ? '-' : value;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _labelW,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              display,
              softWrap: true,
              maxLines: maxLines,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ข้อมูลรายวิชา'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        children: [
          Card(
            color: Colors.white,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(
                color: _borderBlue,
                width: 1.2,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _kv('วิชา', subject.title, maxLines: 3),
                  _kv('รหัสวิชา', subject.code),
                  _kv('หน่วยกิต', subject.credits),
                  _kv('อาจารย์ผู้สอน', subject.teacher, maxLines: 2),
                  _kv('ปีการศึกษา', subject.year),
                  _kv('ภาคเรียน', subject.term),
                  _kv('เวลา', subject.time),
                  _kv('ห้องเรียน', subject.room),
                  _kv('กลุ่มที่เรียน', subject.section),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
