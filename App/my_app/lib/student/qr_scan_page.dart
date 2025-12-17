import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:my_app/config.dart'; 

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
  debugPrint('getUserId() -> $userId'); // ✅ เพิ่ม debug
  return userId;
}

const String apiBase = '${baseUrl}';

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
        Map<String, dynamic> qrData;
        try {
          final outer = jsonDecode(code) as Map<String, dynamic>;
          qrData = jsonDecode(outer['t'] as String) as Map<String, dynamic>;
        } catch (_) {
          qrData = {};
        }

        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('userId') ?? '';
        final today = DateTime.now();
        final dayString =
            "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

        if (qrData.isEmpty) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('QR Code ไม่ถูกต้อง')));
          return;
        }

        // แปลง qr_code_id และ qr_password เป็น String ป้องกัน type error
        qrData['qr_code_id'] = qrData['qr_code_id']?.toString() ?? '';
        qrData['qr_password'] = qrData['qr_password']?.toString() ?? '';

        debugPrint('QR Data: $qrData $userId $dayString');

        _qrData = qrData;

        // ดึง user_id จาก SharedPreferences

        if (userId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('กรุณาล็อกอินก่อนสแกน QR')),
          );
          return;
        }

        // ส่ง qr_code_id พร้อม user_id
        await _fetchQRCodeInfo(qrData['qr_code_id'], userId, dayString);
        Navigator.pop(context);
      }
    } finally {
      _handling = false;
    }
  }

  Future<void> _fetchQRCodeInfo(
    String qrCodeId,
    String userId,
    String day,
  ) async {
    setState(() => _loading = true);

    try {
      final payload = {'qr_code_id': qrCodeId, 'user_id': userId, 'day': day};

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
          title: const Text('ยืนยันการเช็คชื่อ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ชื่อวิชา: ${_qrData!['course_name'] ?? '-'}'),
                Text('ชื่ออาจารย์: ${_qrData!['teacher_name'] ?? '-'}'),
                Text('เวลาเรียน: ${_qrData!['time'] ?? '-'}'),
                Text('วันที่: ${_qrData!['day'] ?? '-'}'),
                const SizedBox(height: 12),
                const Text(
                  'รายชื่อนักศึกษา:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...students.map(
                  (s) => Text('${s['student_name']} (${s['student_id']})'),
                ),
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
      final userId = await getUserId(); // ตรวจสอบว่ามีค่า
      if (userId == null || userId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('กรุณาล็อกอินก่อนสแกน QR')),
        );
        return;
      }

      final now = DateTime.now();
      final formattedDate =
          "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";

      final payload = {
        'qr_code_id': _qrData!['qr_code_id'].toString(), // แปลงเป็น String
        'user_id': userId.toString(), // แปลงเป็น String
        'day': formattedDate, // ต้องใช้ key 'day' ให้ตรงกับ PHP
        'time': formattedTime,
        'type': 'save',
      };

      debugPrint('Sending payload: $payload');

      final json = await ApiService.postJson('qrcode_info.php', payload);
      debugPrint('QR Save Response: $json');

      // แปลง students เป็น List<Student>
      final students =
          (json['students'] as List<dynamic>?)
              ?.map((s) => Student.fromJson(s))
              .toList() ??
          [];

      final bool success = json['success'] == true;
      final String message =
          (json['message'] ?? (success ? 'บันทึกสำเร็จ' : 'บันทึกไม่สำเร็จ'))
              .toString();

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));

      // ตัวอย่าง: ใช้งาน students
      if (students.isNotEmpty) {
        for (var s in students) {
          debugPrint(
            'Student: ${s.studentName} (${s.studentId}), Schedule: ${s.scheduleId}',
          );
        }
      }
    } catch (e) {
      debugPrint('❌ _confirmAndSaveQRCode failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ')),
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
          : !_permissionGranted
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