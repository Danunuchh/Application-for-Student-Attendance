import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/components/custom_appbar.dart';

class QRScanPage extends StatefulWidget {
  const QRScanPage({super.key});

  @override
  State<QRScanPage> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> with WidgetsBindingObserver {
  static const Color _blue = Color(0xFFA6CAFA);

  // ✅ สร้าง controller แบบ lazy (หลังอนุญาตค่อยสร้าง)
  MobileScannerController? _controller;

  bool _handling = false;
  bool _torchOn = false;
  bool _permissionGranted = false;
  bool _checkingPermission = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  // ✅ จัดการ lifecycle: pause/resume กล้องเวลาแอปเข้า/ออก foreground
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;
    if (state == AppLifecycleState.paused) {
      c.stop();
    } else if (state == AppLifecycleState.resumed) {
      // เริ่มใหม่เฉพาะตอนกลับมาและมี permission แล้ว
      if (_permissionGranted) c.start();
    }
  }

  Future<void> _initPermission() async {
    // ขอสิทธิ์กล้อง
    final status = await Permission.camera.request();

    if (!mounted) return;
    _permissionGranted = status.isGranted;
    _checkingPermission = false;

    // ถ้าให้สิทธิ์แล้ว "ค่อย" สร้าง controller
    if (_permissionGranted) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    } else {
      // ถ้าไม่ให้สิทธิ์ แจ้งเตือนครั้งเดียวพอ
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาอนุญาตการใช้กล้องเพื่อสแกน QR')),
      );
    }

    if (mounted) setState(() {});
  }

  String? _firstRawValue(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return null;
    for (final b in capture.barcodes) {
      final v = b.rawValue;
      if (v != null && v.isNotEmpty) return v;
    }
    return null;
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_handling) return;
    _handling = true;

    try {
      final code = _firstRawValue(capture);
      if (code != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('สแกนสำเร็จ: $code')),
        );
        await Future.delayed(const Duration(milliseconds: 800));
        // Navigator.pop(context, code);
      }
    } finally {
      _handling = false;
    }
  }

  Future<void> _toggleTorch() async {
    final c = _controller;
    if (c == null) return;
    try {
      await c.toggleTorch();
      if (!mounted) return;
      setState(() => _torchOn = !_torchOn);
    } catch (_) {
      // ถ้าอุปกรณ์ไม่มีแฟลช จะโยน error มา — เงียบไว้หรือจะแจ้งเตือนก็ได้
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ไม่สามารถเปิดไฟฉายได้บนอุปกรณ์นี้')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: CustomAppBar(
        title: 'สแกน QR',
        actions: [
          IconButton(
            tooltip: 'สลับกล้อง',
            icon: const Icon(Icons.cameraswitch, color: Colors.white),
            onPressed: c == null ? null : () => c.switchCamera(),
          ),
          IconButton(
            tooltip: 'ไฟฉาย',
            icon: Icon(
              _torchOn ? Icons.flash_on : Icons.flash_off,
              color: _torchOn ? Colors.yellowAccent : Colors.white,
            ),
            onPressed: c == null ? null : _toggleTorch,
          ),
        ],
      ),
      body: _checkingPermission
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : !_permissionGranted
              ? _PermissionDeniedView(onOpenSettings: () => openAppSettings())
              : c == null
                  ? const Center(
                      child: Text('ไม่สามารถเริ่มกล้องได้',
                          style: TextStyle(color: Colors.white)))
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        // ✅ แสดงกล้องหลังอนุญาตเท่านั้น
                        MobileScanner(
                          controller: c,
                          onDetect: _onDetect,
                          fit: BoxFit.cover,
                        ),
                        IgnorePointer(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double boxSize =
                                  constraints.maxWidth * 0.74;
                              final double topSpacing =
                                  constraints.maxHeight * 0.10;
                              return Column(
                                children: [
                                  SizedBox(height: topSpacing),
                                  Center(
                                    child: SizedBox(
                                      width: boxSize,
                                      height: boxSize,
                                      child: CustomPaint(
                                        painter: _ScanFramePainter(
                                          color: _blue,
                                          cornerStroke: 9,
                                          laserStroke: 6,
                                          cornerLen: 54,
                                          inset: 18,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _PermissionDeniedView extends StatelessWidget {
  final VoidCallback onOpenSettings;
  const _PermissionDeniedView({required this.onOpenSettings});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 56),
          const SizedBox(height: 12),
          const Text(
            'ไม่ได้รับอนุญาตให้ใช้กล้อง',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: onOpenSettings,
            child: const Text('เปิดการตั้งค่า'),
          ),
        ],
      ),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final Color color;
  final double cornerStroke;
  final double laserStroke;
  final double cornerLen;
  final double inset;

  _ScanFramePainter({
    required this.color,
    required this.cornerStroke,
    required this.laserStroke,
    required this.cornerLen,
    required this.inset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pCorner = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerStroke
      ..strokeCap = StrokeCap.round;

    final pLaser = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = laserStroke
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;

    final l = inset;
    final r = w - inset;
    final t = inset;
    final b = h - inset;

    void drawCorner({
      required Offset hStart,
      required bool toRight,
      required Offset vStart,
      required bool toDown,
    }) {
      canvas.drawLine(
        hStart,
        hStart + Offset(toRight ? cornerLen : -cornerLen, 0),
        pCorner,
      );
      canvas.drawLine(
        vStart,
        vStart + Offset(0, toDown ? cornerLen : -cornerLen),
        pCorner,
      );
    }

    drawCorner(hStart: Offset(l, t), toRight: true,  vStart: Offset(l, t), toDown: true);
    drawCorner(hStart: Offset(r, t), toRight: false, vStart: Offset(r, t), toDown: true);
    drawCorner(hStart: Offset(l, b), toRight: true,  vStart: Offset(l, b), toDown: false);
    drawCorner(hStart: Offset(r, b), toRight: false, vStart: Offset(r, b), toDown: false);

    final midY = h / 2;
    canvas.drawLine(Offset(l, midY), Offset(r, midY), pLaser);
  }

  @override
  bool shouldRepaint(covariant _ScanFramePainter old) {
    return color != old.color ||
        cornerStroke != old.cornerStroke ||
        laserStroke != old.laserStroke ||
        cornerLen != old.cornerLen ||
        inset != old.inset;
  }
}
