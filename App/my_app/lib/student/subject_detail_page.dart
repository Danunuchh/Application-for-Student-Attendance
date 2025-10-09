import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

class Subject {
  final String title;
  final String code;
  final String credits;
  final String teacher;
  final String time;
  final String room;

  const Subject({
    required this.title,
    required this.code,
    required this.credits,
    required this.teacher,
    required this.time,
    required this.room,
  });
}

class SubjectDetailPage extends StatelessWidget {
  final Subject subject;
  const SubjectDetailPage({super.key, required this.subject});

  static const _ink = Color(0xFF1F2937);
  static const _border = Color(0xFFCFE0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'ข้อมูลรายวิชา'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("วิชา", style: TextStyle(fontSize: 14, color: _ink)),
              const SizedBox(height: 4),
              Text(
                subject.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // รหัสวิชา & หน่วยกิต
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _kv("รหัสวิชา", subject.code),
                  _kv("หน่วยกิต", subject.credits),
                ],
              ),
              const SizedBox(height: 16),

              const Text(
                "อาจารย์ผู้สอน",
                style: TextStyle(fontSize: 14, color: _ink),
              ),
              const SizedBox(height: 4),
              Text(
                subject.teacher,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _kv("เวลา", subject.time),
                  _kv("ห้อง", subject.room),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _kv(String k, String v) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(k, style: const TextStyle(fontSize: 14, color: _ink)),
      const SizedBox(height: 4),
      Text(
        v,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
    ],
  );
}
