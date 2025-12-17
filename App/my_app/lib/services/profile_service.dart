// lib/services/profile_service.dart
import 'dart:convert';
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/api_service.dart';

// หมายเหตุ:
// - ApiService.uri(String path) ควรคืนค่า Uri ที่รวม baseUrl + path
// - ApiService.authHeaders() ควรคืน header พื้นฐาน (เช่น Authorization, Cookie ฯลฯ)
// - ApiService.client() คืน http.Client (ถ้ามี cookie manager/keep-alive ก็จัดในนี้)

class ProfileService {
  static const String _showPath = '/Services/profile_api.php';
  static const String _updatePath = '/Services/profile_api.php';

  /// ดึงโปรไฟล์จาก PHP:
  /// GET /api/profile_show.php?user_id=123&role=student
  static Future<UserProfile> fetchProfile({
    required String userId,
    required String role,
  }) async {
    // สร้าง URL พร้อม query
    final baseUri = Uri.parse('http://localhost:8000/profile_api.php');
    final uri = baseUri.replace(
      queryParameters: {'type': 'show', 'user_id': userId, 'role': role},
    );

    // รวม headers (เพิ่ม Accept: application/json)
    final headers = {
      ...(await ApiService.authHeaders()),
      'Accept': 'application/json',
    };

    final res = await ApiService.client().get(uri, headers: headers);

    if (res.statusCode != 200) {
      throw Exception('โหลดโปรไฟล์ล้มเหลว (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! Map || data['success'] != true) {
      // ดึง message จาก PHP ถ้ามี
      final msg = (data is Map)
          ? (data['message']?.toString() ?? 'โหลดโปรไฟล์ล้มเหลว')
          : 'โหลดโปรไฟล์ล้มเหลว';
      throw Exception(msg);
    }

    return UserProfile.fromJson(data['data'] as Map<String, dynamic>);
  }

  static Future<void> updateProfile({
    required String userId,
    required String role,
    required UserProfile payload,
  }) async {
    // final baseUri = Uri.parse('http://localhost:8000/profile_api.php');
    final uri = Uri.parse('http://localhost:8000/profile_api.php');

    final bodyMap = <String, dynamic>{
      'type': 'update',
      'id': userId,
      'role': role,
      'username': payload.username,
      'email': payload.email,
      'firstName': payload.firstName,
      'lastName': payload.lastName,
      'phone': payload.phone,
      'address': payload.address,
    };

    if (role == 'student') {
      bodyMap['studentId'] = payload.studentId ?? '';
    } else if (role == 'teacher') {
      bodyMap['studentId'] = payload.studentId ?? '';
    }

    final headers = {
      ...(await ApiService.authHeaders()),
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // ใช้ POST เพื่อให้ PHP อ่าน json_input() ได้สะดวก
    final res = await ApiService.client().post(
      uri,
      headers: headers,
      body: jsonEncode(bodyMap),
    );

    if (res.statusCode != 200) {
      throw Exception('บันทึกโปรไฟล์ล้มเหลว (${res.statusCode})');
    }

    final data = jsonDecode(res.body);
    if (data is! Map || data['success'] != true) {
      final msg = (data is Map)
          ? (data['message']?.toString() ?? 'บันทึกโปรไฟล์ล้มเหลว')
          : 'บันทึกโปรไฟล์ล้มเหลว';
      throw Exception(msg);
    }
  }
}
