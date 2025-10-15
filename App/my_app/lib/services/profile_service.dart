// lib/services/profile_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/models/user_profile.dart';
import 'package:my_app/services/api_service.dart';
import 'api_service.dart';

class ProfileService {
  // role: 'student' หรือ 'teacher'
  static String _path(String role) {
    return role == 'teacher' ? '/api/teachers' : '/api/students';
  }

  static Future<UserProfile> fetchProfile({
    required String userId,
    required String role,
  }) async {
    final uri = ApiService.uri('${_path(role)}/$userId');
    final headers = await ApiService.authHeaders();
    final res = await ApiService.client().get(uri, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('โหลดโปรไฟล์ล้มเหลว (${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    return UserProfile.fromJson(data);
  }

  static Future<void> updateProfile({
    required String userId,
    required String role,
    required UserProfile payload,
  }) async {
    final uri = ApiService.uri('${_path(role)}/$userId');
    final headers = await ApiService.authHeaders();
    final res = await ApiService.client().put(
      uri,
      headers: headers,
      body: jsonEncode(payload.toJson()),
    );
    if (res.statusCode != 200) {
      throw Exception('บันทึกโปรไฟล์ล้มเหลว (${res.statusCode})');
    }
  }
}
