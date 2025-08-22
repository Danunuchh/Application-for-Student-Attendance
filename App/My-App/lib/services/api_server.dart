// lib/services/api_mock.dart
class ApiMock {
  static Future<Map<String, dynamic>> startSession(int courseId) async {
    await Future.delayed(
      const Duration(milliseconds: 400),
    ); // จำลองรอเซิร์ฟเวอร์
    final now = DateTime.now();
    return {
      'sessionId': now.millisecondsSinceEpoch % 100000, // mock session id
      'token': 'mock_${courseId}_${now.millisecondsSinceEpoch}',
      'expiresAt': now
          .add(const Duration(minutes: 2))
          .toIso8601String(), // หมดอายุ 2 นาที
    };
  }

  static Future<Map<String, dynamic>> rotateToken(int sessionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    return {
      'token': 'mock_rot_${sessionId}_${now.millisecondsSinceEpoch}',
      'expiresAt': now.add(const Duration(minutes: 2)).toIso8601String(),
    };
  }
}
