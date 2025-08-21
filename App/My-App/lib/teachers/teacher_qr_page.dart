// lib/pages/teacher_qr_page.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
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
  // ====== STATE ======
  String? _token; // โทเคน (mock)
  DateTime? _expiresAt; // เวลาหมดอายุ
  Timer? _ticker; // นับถอยหลัง
  Duration _remain = Duration.zero;
  bool _loading = false;

  static const String _prefix = 'mock';

  @override
  void initState() {
    super.initState();
    _startSessionMock(); // เริ่มแล้วเจน QR ทันที (จำลอง)
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  // ====== MOCK SERVICES ======
  Future<void> _startSessionMock() async {
    setState(() => _loading = true);
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // จำลองรอเซิร์ฟเวอร์
    _applyNewToken(_randomToken());
    setState(() => _loading = false);
  }

  Future<void> _rotateMock() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(milliseconds: 250));
    _applyNewToken(_randomToken());
    setState(() => _loading = false);
  }

  // สร้าง token ใหม่แบบสุ่ม
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
    _expiresAt = DateTime.now().add(
      const Duration(minutes: 2),
    ); // หมดอายุ 2 นาที
    _restartTicker();
    setState(() {});
  }

  void _restartTicker() {
    _ticker?.cancel();
    _tick(); // อัปเดตครั้งแรก
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
    final title = 'QR เช็คชื่อ — ${widget.courseName}';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis, // กันชื่อวิชายาว
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
            ), // กันแถวล้นจอใหญ่/เล็ก
            child: _loading && _token == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_token != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF88A8E8),
                              width: 1.2,
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
                            data: jsonEncode({
                              't': _token,
                            }), // QR เก็บ {"t": token}
                            version: QrVersions.auto,
                            size: 250,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      const SizedBox(height: 14),

                      // ⛑ เปลี่ยนจาก Row -> Wrap กัน overflow แน่นอน
                      if (_expiresAt != null)
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              size: 18,
                              color: Colors.black54,
                            ),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 320),
                              child: Text(
                                'หมดอายุใน ${_fmtRemain()}',
                                style: const TextStyle(color: Colors.black54),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                softWrap: false,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 16),
                      FilledButton.tonal(
                        onPressed: _loading ? null : _rotateMock,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('หมุนโทเคนใหม่ (Mock)'),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
