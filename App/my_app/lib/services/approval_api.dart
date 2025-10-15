// lib/services/approvals_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

enum ApprovalStatus { approved, rejected, pending }

ApprovalStatus _mapStatus(String s) {
  switch (s.toLowerCase()) {
    case 'approved':
    case 'approve':
      return ApprovalStatus.approved;
    case 'rejected':
    case 'reject':
      return ApprovalStatus.rejected;
    default:
      return ApprovalStatus.pending;
  }
}

class ApprovalItemDto {
  final String id;
  final DateTime date;
  final String title;
  final ApprovalStatus status;

  ApprovalItemDto({
    required this.id,
    required this.date,
    required this.title,
    required this.status,
  });
}

class ApprovalDetailDto {
  final String id;
  final DateTime date;
  final String subject;
  final String students;   // ข้อความรวม
  final String leaveType;
  final String reason;
  final ApprovalStatus status;

  ApprovalDetailDto({
    required this.id,
    required this.date,
    required this.subject,
    required this.students,
    required this.leaveType,
    required this.reason,
    required this.status,
  });
}

class ApprovalsApi {
  final String baseUrl;
  final http.Client _client;

  ApprovalsApi(this.baseUrl, {http.Client? client}) : _client = client ?? http.Client();

  /// ดึงรายการที่รออนุมัติของอาจารย์คนนี้
  Future<List<ApprovalItemDto>> fetchApprovalsList(String teacherId) async {
    final uri = Uri.parse('$baseUrl/approvals?teacher_id=$teacherId');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final data = jsonDecode(res.body);
    if (data is! List) throw Exception('Invalid JSON (expected List)');

    return data.map<ApprovalItemDto>((e) {
      return ApprovalItemDto(
        id: e['id'].toString(),
        date: DateTime.parse(e['date'] as String),
        title: e['subject'] as String,
        status: _mapStatus(e['status'] as String),
      );
    }).toList();
  }

  /// ดึงรายละเอียดเอกสาร
  Future<ApprovalDetailDto> fetchApprovalDetail(String approvalId) async {
    final uri = Uri.parse('$baseUrl/approvals/$approvalId');
    final res = await _client.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final e = jsonDecode(res.body);
    return ApprovalDetailDto(
      id: e['id'].toString(),
      date: DateTime.parse(e['date'] as String),
      subject: e['subject'] as String,
      students: e['students_text'] as String, // ให้ API รวมข้อความมาแล้ว เช่น "6520... ณนุช & ..."
      leaveType: e['leave_type'] as String,
      reason: e['reason'] as String,
      status: _mapStatus(e['status'] as String),
    );
  }

  /// อนุมัติ
  Future<bool> approve(String approvalId) async {
    final uri = Uri.parse('$baseUrl/approvals/$approvalId/approve');
    final res = await _client.post(uri);
    return res.statusCode == 200;
  }

  /// ไม่อนุมัติ
  Future<bool> reject(String approvalId) async {
    final uri = Uri.parse('$baseUrl/approvals/$approvalId/reject');
    final res = await _client.post(uri);
    return res.statusCode == 200;
  }
}
