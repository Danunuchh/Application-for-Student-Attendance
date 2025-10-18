// lib/pages/student_scan_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class StudentScanPage extends StatefulWidget {
  const StudentScanPage({super.key});

  @override
  State<StudentScanPage> createState() => _StudentScanPageState();
}

class _StudentScanPageState extends State<StudentScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: [BarcodeFormat.qrCode],
  );

  bool _handled = false;

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) return;
    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null) return;

    _handled = true;
    _controller.stop();

    // รองรับทั้ง JSON {"t":"..."} และสตริงดิบ
    String token;
    try {
      final obj = jsonDecode(raw);
      token = (obj['t'] ?? obj['token'] ?? raw).toString();
    } catch (_) {
      token = raw;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('สแกนได้: $token')), // เดโม: แสดงโทเคนที่อ่านได้
    );
  }

  void _scanAgain() {
    _handled = false;
    _controller.start();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar มีปุ่มกลับแบบในภาพ
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      // กล้องเต็มจอ (ไม่มีกรอบ CustomPainter แล้ว)
      body: MobileScanner(controller: _controller, onDetect: _onDetect),

      // แถบล่างสีฟ้า + ปุ่มกลางวงกลมไอคอน QR (กดเพื่อสแกนอีกครั้ง)
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFD4E2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                _BarIcon(
                  icon: Icons.home_rounded,
                  selected: false,
                  onTap: () => Navigator.pushReplacementNamed(context, '/courses'),
                ),
                Expanded(
                  child: Center(
                    child: InkResponse(
                      onTap: _scanAgain, // แตะเพื่อเริ่มสแกนอีกครั้ง
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(
                              blurRadius: 8,
                              color: Color(0x22000000),
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, size: 28),
                      ),
                    ),
                  ),
                ),
                _BarIcon(
                  icon: Icons.logout_rounded,
                  selected: false,
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ปุ่มในแถบล่าง
class _BarIcon extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _BarIcon({
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 64,
          decoration: selected
              ? BoxDecoration(
                  color: Colors.white.withOpacity(.55),
                  borderRadius: BorderRadius.circular(12),
                )
              : null,
          child: Icon(icon, size: 26),
        ),
      ),
    );
  }
}
