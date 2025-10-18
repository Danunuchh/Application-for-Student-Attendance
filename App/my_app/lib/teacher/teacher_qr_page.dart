// lib/pages/teacher_qr_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import 'package:qr_flutter/qr_flutter.dart';

class TeacherQRPage extends StatefulWidget {
  final int courseId;
  final String courseName;

  const TeacherQRPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<TeacherQRPage> createState() => _TeacherQRPageState();
}

class _TeacherQRPageState extends State<TeacherQRPage> {
  String? _token;
  DateTime? _expiresAt;
  Timer? _ticker;
  Duration _remain = Duration.zero;
  bool _loading = false;

  static const String _prefix = 'mock';

  @override
  void initState() {
    super.initState();
    _startSessionMock();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _startSessionMock() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    _applyNewToken(_randomToken());
    setState(() => _loading = false);
  }

  Future<void> _rotateMock() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 250));
    _applyNewToken(_randomToken());
    setState(() => _loading = false);
  }

  String _randomToken() {
    final rnd = Random();
    final body = List.generate(
      12,
      (_) => rnd.nextInt(16).toRadixString(16),
    ).join();
    return '$_prefix${widget.courseId}_$body';
  }

  void _applyNewToken(String token) {
    _token = token;
    _expiresAt = DateTime.now().add(const Duration(minutes: 3));
    _restartTicker();
    setState(() {});
  }

  void _restartTicker() {
    _ticker?.cancel();
    _tick();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_expiresAt == null) return;
    final remain = _expiresAt!.difference(DateTime.now());
    setState(() => _remain = remain.isNegative ? Duration.zero : remain);
  }

  String _fmtRemain() {
    final s = _remain.inSeconds;
    final m = s ~/ 60;
    final r = s % 60;
    return '${m.toString().padLeft(2, '0')}:${r.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: _loading && _token == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // หัวข้อย้ายมา Body
                      const Text(
                        'QR Code เช็คชื่อ',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.courseName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // QR Code
                      if (_token != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF88A8E8),
                              width: 2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                blurRadius: 10,
                                color: Color(0x22000000),
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: QrImageView(
                            data: jsonEncode({'t': _token}),
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 14),

                      // เวลานับถอยหลัง
                      if (_expiresAt != null)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 20,
                              color: Colors.black54,
                            ),
                            Text(
                              'หมดอายุใน ${_fmtRemain()}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 30),

                      // ปุ่ม Refresh
                      CustomButton(
                        text: 'Refresh QR code',
                        loading: _loading,
                        onPressed: _rotateMock,
                        backgroundColor: const Color(0xFF84A9EA),
                        textColor: Colors.white,
                        fontSize: 16, // ฟังก์ชันของคุณ
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
