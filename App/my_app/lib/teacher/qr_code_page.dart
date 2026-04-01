import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/teacher/teacher_qr_page.dart';
import 'package:my_app/config.dart';
import 'package:flutter/foundation.dart';

const String apiBase = baseUrl;

Future<Position> _getCurrentLocation() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('กรุณาเปิด GPS ก่อนใช้งาน');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }

  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('ไม่ได้รับอนุญาต Location');
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );
}

class QrCodePage extends StatefulWidget {
  final String userId;
  const QrCodePage({super.key, required this.userId});

  @override
  State<QrCodePage> createState() => _QrCodePageState();
}

class _QrCodePageState extends State<QrCodePage> {
  final List<Map<String, dynamic>> _courses = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    setState(() => _loading = true);

    try {
      final uri = Uri.parse(
        '$apiBase/courses_api.php',
      ).replace(queryParameters: {'user_id': widget.userId, 'type': 'show'});

      final res = await http.get(uri);
      final json = jsonDecode(res.body);

      if (json['success'] == true && json['data'] is List) {
        setState(() {
          _courses
            ..clear()
            ..addAll(List<Map<String, dynamic>>.from(json['data']));
        });
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ยิง API สร้าง QR แค่ครั้งเดียว
  Future<void> _createQrAndGo(Map<String, dynamic> course) async {
    setState(() => _loading = true);

    try {
      final now = DateTime.now();

      double? lat;
      double? lng;

      // ถ้าไม่ใช่เว็บ ให้ดึงตำแหน่ง
      if (!kIsWeb) {
        try {
          final pos = await _getCurrentLocation();
          lat = pos.latitude;
          lng = pos.longitude;
        } catch (e) {
          print("GPS error: $e");
        }
      }

      // ส่ง lat/long ไป backend เพื่อบันทึก
      final res = await http.post(
        Uri.parse('$apiBase/qrcode.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'course_id': int.parse(course['id'].toString()),
          'date': now.toIso8601String(),
          'latitude': lat,
          'longitude': lng,
        }),
      );

      final data = jsonDecode(res.body);

      if (data['success'] != true) {
        throw Exception("Create QR failed");
      }

      // QR มีแค่ id + password เท่านั้น
      final qrPayload = jsonEncode({
        'qr_id': data['qr_code_id'],
        'password': data['qr_password'],
      });

      if (!mounted) return;

      setState(() => _loading = false);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => TeacherQRPage(
            courseId: int.parse(course['id'].toString()),
            courseName: course['name']?.toString() ?? "",
            token: qrPayload,
          ),
        ),
      );
    } catch (e, stack) {
      print("QR ERROR: $e");
      print(stack);
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'คลาสเรียน'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _courses.isEmpty
          ? const Center(child: Text('ยังไม่มีรายวิชา'))
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _courses.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final c = _courses[i];

                return TextBox(
                  title: '${c['code']}  ${c['name']}',
                  subtitle:
                      'ปีการศึกษา ${c['year']} | เทอม ${c['term']} | Sec ${c['section']}',
                  trailing: IconButton(
                    icon: SvgPicture.asset(
                      'assets/qr_code.svg',
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () => _createQrAndGo(c),
                  ),
                );
              },
            ),
    );
  }
}
