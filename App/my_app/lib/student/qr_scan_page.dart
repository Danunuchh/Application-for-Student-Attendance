import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/config.dart';

import 'package:geolocator/geolocator.dart';

import 'package:flutter/foundation.dart';

Future<Position?> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  // เปิด location service ไหม
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    debugPrint('Location service disabled');
    return null;
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      debugPrint('Location permission denied');
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    debugPrint('Location permission denied forever');
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

class Student {
  final String userId;
  final String studentId;
  final String studentName;
  final String scheduleId;

  Student({
    required this.userId,
    required this.studentId,
    required this.studentName,
    required this.scheduleId,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      userId: json['user_id'].toString(),
      studentId: json['student_id'].toString(),
      studentName: json['student_name'] ?? '',
      scheduleId: json['schedule_id'].toString(),
    );
  }
}

// ดึง userId ตอนใช้งาน
Future<String?> getUserId() async {
  final prefs = await SharedPreferences.getInstance();
  final userId = prefs.getString('userId');
  debugPrint('getUserId() -> $userId');
  return userId;
}

const String apiBase = baseUrl;

class ApiService {
  static Map<String, String> get _jsonHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json; charset=utf-8',
  };

  static Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$apiBase/$path').replace(queryParameters: query);
    final res = await http.get(uri, headers: _jsonHeaders);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$apiBase/$path');
    final res = await http.post(
      uri,
      headers: _jsonHeaders,
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    return jsonDecode(res.body) as Map<String, dynamic>;
  }
}

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
  bool _loading = false;
  bool _completed = false;
  bool _enableSnackBar = false;

  Map<String, dynamic>? _qrData;

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

  Future<void> _showPopup({
    required String title,
    required String message,
    bool isSuccess = false,
  }) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('ตกลง'),
          ),
        ],
      ),
    );
  }

  Future<void> _initPermission() async {
    if (kIsWeb) {
      _permissionGranted = true;
      _checkingPermission = false;

      _controller = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
        facing: CameraFacing.back,
      );

      if (mounted) setState(() {});
      return;
    }

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
    if (_handling || _completed) return;
    _handling = true;

    try {
      final code = _firstRawValue(capture);
      if (code == null || !mounted) return;

      Map<String, dynamic> qrData;
      try {
        qrData = jsonDecode(code);
      } catch (_) {
        qrData = {};
      }

      if (qrData['qr_id'] == null || qrData['password'] == null) {
        await _showPopup(title: 'QR ไม่ถูกต้อง', message: 'กรุณาลองใหม่');
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId') ?? '';

      if (userId.isEmpty) {
        await _showPopup(
          title: 'ยังไม่ได้ล็อกอิน',
          message: 'กรุณาเข้าสู่ระบบก่อน',
        );
        return;
      }

      await _controller?.stop();

      final now = DateTime.now();

      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      await _fetchQRCodeInfo(
        qrData['qr_id'].toString(),
        qrData['password'].toString(),
        userId,
        formattedDate,
      );
    } finally {
      _handling = false;
    }
  }

  Future<void> _fetchQRCodeInfo(
    String qrCodeId,
    String qrPassword,
    String userId,
    String day,
  ) async {
    setState(() => _loading = true);

    try {
      final payload = {
        'qr_code_id': qrCodeId,
        'qr_password': qrPassword,
        'user_id': userId,
        'day': day,
      };

      final json = await ApiService.postJson('qrcode_info.php', payload);
      debugPrint('QR Info: $json');

      if (json['success'] != true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(json['message'] ?? 'ไม่สามารถดึงข้อมูล QR ได้'),
          ),
        );
        return;
      }

      // แปลง qr_code_id เป็น String ปลอดภัย
      _qrData = Map<String, dynamic>.from(json);
      _qrData!['qr_code_id'] = _qrData!['qr_code_id'].toString();
      _qrData!['time'] = _qrData!['time']?.toString();

      // แปลง students
      final students = (_qrData!['students'] as List<dynamic>? ?? []).map((s) {
        return {
          'student_name': s['student_name'] ?? '-',
          'student_id': s['student_id']?.toString() ?? '-',
        };
      }).toList();

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('ยืนยันการเช็คชื่อ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ชื่อวิชา : ${_qrData!['course_name'] ?? '-'}'),
                Text('ชื่ออาจารย์ : ${_qrData!['teacher_name'] ?? '-'}'),
                Text('เวลาเรียน : ${_qrData!['time'] ?? '-'}'),
                Text('วันที่ : ${_qrData!['day'] ?? '-'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFF44336),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('ปิด'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF21BA0C),
                foregroundColor: const Color(0xFFFFFFFF),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                // ส่ง qr_code_id เป็น String
                _confirmAndSaveQRCode(_qrData!['qr_code_id']);
              },
              child: const Text('ยืนยัน'),
            ),
          ],
        ),
      );
    } catch (e, st) {
      debugPrint('❌ _fetchQRCodeInfo failed: $e');
      debugPrint(st.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _confirmAndSaveQRCode(String qrCodeId) async {
    if (!_loading) setState(() => _loading = true);

    try {
      final userId = await getUserId();

      if (userId == null || userId.isEmpty) {
        await _showPopup(
          title: 'ข้อผิดพลาด',
          message: 'กรุณาล็อกอินก่อนสแกน QR',
        );
        return;
      }

      final now = DateTime.now();

      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final position = await getCurrentLocation();

      if (position == null) {
        setState(() => _loading = false);

        await _showPopup(
          title: 'ไม่สามารถดึงตำแหน่งได้',
          message: 'กรุณาเปิด GPS แล้วลองใหม่อีกครั้ง',
        );
        return;
      }

      final payload = {
        'qr_code_id': _qrData!['qr_code_id'].toString(),
        'qr_password': _qrData!['qr_password'].toString(),
        'user_id': userId.toString(),
        'day': formattedDate,
        'time': formattedTime,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'type': 'save',
      };

      final json = await ApiService.postJson('qrcode_info.php', payload);

      if (json['success'] != true) {
        final msg = json['message']?.toString() ?? '';

        if (msg == 'OUT_OF_RANGE') {
          final distance = json['distance']?.toString() ?? '';

          await _showPopup(
            title: 'อยู่นอกระยะ',
            message: distance.isNotEmpty
                ? 'คุณอยู่ห่างจากจุดเช็คชื่อ ${distance} เมตร\nไม่สามารถเช็คชื่อได้'
                : 'คุณอยู่นอกระยะ 50 เมตร\nไม่สามารถเช็คชื่อได้',
          );
        } else {
          await _showPopup(
            title: 'เกิดข้อผิดพลาด',
            message: msg.isNotEmpty ? msg : 'ไม่สามารถเช็คชื่อได้',
          );
        }

        return;
      }
      await _showPopup(
        title: 'เช็คชื่อสำเร็จ',
        message: 'ระบบได้บันทึกเวลาเรียบร้อยแล้ว',
        isSuccess: true,
      );
      _completed = true; 

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      await _showPopup(
        title: 'เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ',
        message: 'กรุณาลองใหม่อีกครั้ง',
      );
    } finally {
      if (mounted) setState(() => _loading = false);
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
        title: 'สแกน QR Code',
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
          : (!_permissionGranted && !kIsWeb)
          ? _PermissionDeniedView(onOpenSettings: () => openAppSettings())
          : c == null
          ? const Center(
              child: Text(
                'ไม่สามารถเริ่มกล้องได้',
                style: TextStyle(color: Colors.white),
              ),
            )
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
          const Icon(
            Icons.camera_alt_outlined,
            color: Colors.white70,
            size: 56,
          ),
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
