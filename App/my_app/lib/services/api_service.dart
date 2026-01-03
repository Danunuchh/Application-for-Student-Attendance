// lib/services/api_mock.dart
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
// N: นำ import config.dart มาใช้แทนการ hardcode baseUrl ซ้ำ
import 'package:my_app/config.dart';
/// ==========================
/// MOCK API (จำลอง Backend)
/// ==========================
class ApiMock {
  /// จำลองการเริ่ม session ของวิชา
  static Future<Map<String, dynamic>> startSession(int courseId) async {
    await Future.delayed(const Duration(milliseconds: 400)); // จำลองดีเลย์
    final now = DateTime.now();
    return {
      'sessionId': now.millisecondsSinceEpoch % 100000, // mock session id
      'token': 'mock_${courseId}_${now.millisecondsSinceEpoch}',
      'expiresAt': now
          .add(const Duration(minutes: 2))
          .toIso8601String(), // หมดอายุ 2 นาที
    };
  }

  /// จำลองการขอ Token ใหม่ (หมุนรอบใหม่)
  static Future<Map<String, dynamic>> rotateToken(int sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return {
      'token': 'mock_rot_${sessionId}_${now.millisecondsSinceEpoch}',
      'expiresAt': now.add(const Duration(minutes: 2)).toIso8601String(),
    };
  }
}


/// ==========================
/// REAL API CLIENT (เชื่อมต่อจริง)
/// ==========================
class ApiService {
  // N: ลบ baseUrl ที่ซ้ำออก เพราะใช้จาก config.dart แทน
  // เดิม: static const String baseUrl = 'http://10.0.2.2:8000/api';
  // ตอนนี้: ใช้ baseUrl จาก config.dart + '/api' เวลาเรียก

  /// ดึง token ที่บันทึกไว้ตอน login
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// สร้าง header พร้อม token
  static Future<Map<String, String>> authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// สร้าง URI เต็ม (path เช่น `/courses_api.php`)
  /// N: ใช้ baseUrl จาก config.dart + path โดยตรง (ไม่มี /api)
  static Uri uri(String path) => Uri.parse('$baseUrl$path');

  /// คืน client (สามารถใช้ร่วมกับ package http)
  static http.Client client() => http.Client();

  /// ตัวอย่าง: ดึงข้อมูลรายวิชา (จริง)
  /// N: ตัวอย่างการใช้งาน uri() ที่ใช้ baseUrl จาก config.dart
  static Future<http.Response> fetchCourses() async {
    final headers = await authHeaders();
    final uri = ApiService.uri('/student/courses');
    final res = await client().get(uri, headers: headers);
    return res;
  }
}
