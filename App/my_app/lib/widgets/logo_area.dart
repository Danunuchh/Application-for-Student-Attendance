import 'package:flutter/material.dart';

class LogoArea extends StatelessWidget {
  const LogoArea({super.key});

  @override
  Widget build(BuildContext context) {
    // โซนโลโก้จำลองให้คล้ายภาพ: ก้อนฟ้า + ข้อความ "Uni Check"
    return SizedBox(
      width: 340,
      height: 240,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // ก้อนฟ้า (blob) ขอบน้ำเงิน
          Container(
            width: 320,
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F1FF),
              borderRadius: BorderRadius.circular(120),
              border: Border.all(color: const Color(0xFF4A86E8), width: 3),
            ),
          ),
          // ข้อความ
          Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                "Uni",
                style: TextStyle(
                  fontSize: 72,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  height: 0.9,
                ),
              ),
              SizedBox(height: 8),
              Text(
                "Check",
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                  height: 0.9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
