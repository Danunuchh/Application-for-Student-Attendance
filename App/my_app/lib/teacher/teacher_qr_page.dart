import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:my_app/components/button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:http/http.dart' as http; // ✅ ใช้ http

import 'package:my_app/config.dart'; 

const String apiBase =
    //'http://10.0.2.2:8000'; // หรือ http://10.0.2.2:8000 สำหรับ Android Emulator
    '${baseUrl}'; // หรือ http://10.0.2.2:8000 สำหรับ Android Emulator

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

  // ✅ ย้ายเมธอดนี้เข้ามาในคลาส และยังเป็น static ได้
  static Future<Map<String, dynamic>> addStudentToCourse({
    required String studentId,
    required int courseId,
  }) async {
    final body = {'student_id': studentId, 'course_id': courseId};
    return await postJson('courses_api.php?type=add_student', body);
  }
}

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
    _fetchQRCode();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  static final Map<String, Future<Map<String, dynamic>?>> _inflightRequests =
      {};

  /// ส่งข้อมูลไปเซิร์ฟเวอร์เพื่อขอ qr_code (เดิม)
  Future<Map<String, dynamic>?> _sendQRCodeData(dynamic courseId) async {
    // ถ้ามี token ที่ยังไม่หมดอายุ ให้ใช้ token เดิมเลย (ไม่ยิง request)
    if (_token != null && _expiresAt != null) {
      final now = DateTime.now();
      if (_expiresAt!.isAfter(now)) {
        debugPrint('⏱ Using cached token (not calling API)');
        // _token เป็น jsonEncode ของ {'qr_code_id':..., 'qr_password':...}
        try {
          final cached = jsonDecode(_token!);
          if (cached is Map<String, dynamic>) {
            // จำลอง response shape ที่ API คืน (อย่างน้อยต้องมี qr_code_id + qr_password)
            return {
              'success': true,
              'qr_code_id': cached['qr_code_id'],
              'qr_password': cached['qr_password'],
            };
          }
        } catch (_) {
          // ถ้า decode ไม่ได้ ให้ไปเรียก API ปกติ
          debugPrint('⚠️ Cached token decode failed, will call API');
        }
      } else {
        debugPrint('⌛ Cached token expired, will call API');
      }
    }

    setState(() => _loading = true);

    final String courseIdStr = courseId?.toString() ?? '';

    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final Map<String, dynamic> data = {
      'course_id': courseIdStr,
      'date': formattedDate,
    };

    try {
      final json = await ApiService.postJson('qrcode.php', data);

      if (json['success'] == true) {
        return json;
      } else {
        final String msg = json['message'] ?? 'ส่งข้อมูลไม่สำเร็จ';
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(msg)));
        return null;
      }
    } catch (e) {
      debugPrint('❌ _sendQRCodeData failed: $e');
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('เชื่อมต่อเซิร์ฟเวอร์ไม่สำเร็จ')),
        );
      return null;
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Wrapper ที่ป้องกันการเรียก API พร้อมกันซ้ำๆ (key = courseId|date)
  Future<Map<String, dynamic>?> _sendQRCodeDataSafe(dynamic courseId) {
    final String courseIdStr = courseId?.toString() ?? '';

    final now = DateTime.now();
    final formattedDate =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final key = '$courseIdStr|$formattedDate';

    // ถ้ามี request อยู่ ให้ reuse future นั้น
    if (_inflightRequests.containsKey(key)) {
      debugPrint('⏳ Reusing inflight request for $key');
      return _inflightRequests[key]!;
    }

    // ถ้า cached token ยัง valid, _sendQRCodeData จะ return cached result โดยไม่ยิง API
    final future = _sendQRCodeData(courseId).whenComplete(() {
      _inflightRequests.remove(key);
      debugPrint('🧹 Inflight request removed for $key');
    });

    _inflightRequests[key] = future;
    debugPrint('🔒 Added inflight request for $key');

    return future;
  }

  /// ปรับ _fetchQRCode ให้ใช้ _sendQRCodeDataSafe และไม่สร้างซ้ำเมื่อมี token ที่ยังใช้งานได้
  Future<void> _fetchQRCode() async {
    // ถ้ามี token และยังไม่หมดอายุ ให้ใช้เลยโดยไม่เรียก API
    if (_token != null &&
        _expiresAt != null &&
        _expiresAt!.isAfter(DateTime.now())) {
      debugPrint('✅ Token still valid — using local token, no API call');
      // รีสตาร์ท ticker เผื่อยังไม่ทำ
      _restartTicker();
      return;
    }

    if (mounted) setState(() => _loading = true);

    final response = await _sendQRCodeDataSafe(widget.courseId);

    if (response != null && response['success'] == true) {
      // สร้าง QR จาก qr_code_id + qr_password
      final qrData = {
        'qr_code_id': response['qr_code_id'],
        'qr_password': response['qr_password'],
      };
      _token = jsonEncode(qrData);
      _expiresAt = DateTime.now().add(const Duration(minutes: 3));
      _restartTicker();
    }

    if (mounted) setState(() => _loading = false);
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
                      /*if (_expiresAt != null)
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
                      const SizedBox(height: 30),*/

                      // ปุ่ม Refresh
                      /*CustomButton(
                        text: 'Refresh QR code',
                        loading: _loading,
                        onPressed: _fetchQRCode,
                        backgroundColor: const Color(0xFF84A9EA),
                        textColor: Colors.white,
                        fontSize: 16,
                      ),*/
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}