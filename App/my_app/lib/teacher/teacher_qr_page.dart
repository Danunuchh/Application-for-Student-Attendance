import 'dart:async';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeacherQRPage extends StatefulWidget {
  final int courseId; // ✅ ใช้ id ด้วย
  final String courseName;
  final String token; // ✅ token จาก backend

  const TeacherQRPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.token,
  });

  @override
  State<TeacherQRPage> createState() => _TeacherQRPageState();
}

class _TeacherQRPageState extends State<TeacherQRPage> {
  Timer? _ticker;
  Duration _remain = const Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remain.inSeconds <= 0) {
        _ticker?.cancel();
      } else {
        setState(() {
          _remain -= const Duration(seconds: 1);
        });
      }
    });
  }

  String _fmtRemain() {
    final s = _remain.inSeconds;
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'QR Code เช็คชื่อ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Text(
              widget.courseName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),

            const SizedBox(height: 24),

            /// ✅ แสดง QR จาก token ที่ได้จาก backend
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF88A8E8), width: 2),
                // ❌ ลบ boxShadow ออก
              ),
              child: QrImageView(
                data: widget.token,
                size: 300, // 🔥 จาก 250 → 300
                backgroundColor: Colors.white,
              ),
            ),

          ],
        ),
      ),
    );
  }
}
