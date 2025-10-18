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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final c = _controller;
    if (c == null) return;
    if (state == AppLifecycleState.paused) {
      c.stop();
    } else if (state == AppLifecycleState.resumed) {
      if (_permissionGranted) c.start();
    }
  }

  Future<void> _initPermission() async {
    final status = await Permission.camera.request();

    if (!mounted) return;
    _permissionGranted = status.isGranted;
    _checkingPermission = false;

    if (_permissionGranted) {
      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
        torchEnabled: false,
      );
    } else {
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
                  : MobileScanner(
                      controller: c,
                      onDetect: _onDetect,
                      fit: BoxFit.cover,
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
