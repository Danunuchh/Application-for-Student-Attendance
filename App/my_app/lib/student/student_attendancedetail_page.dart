import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/app_calendar.dart';
import 'package:my_app/components/app_calendar_theme.dart';
import 'package:my_app/config.dart';

/// =====================
/// MODEL
/// =====================
class AttendanceRecord {
  final DateTime date;
  final String studentId;
  final String studentName;
  final bool present;
  final String? checkTime;

  const AttendanceRecord({
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.present,
    this.checkTime,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    final t =
        json['attendance_time'] ?? json['checkTime'] ?? json['check_time'];

    final dateRaw =
        json['day'] ?? json['date'] ?? json['class_time'] ?? json['time'];

    final parsedDate =
        DateTime.tryParse(dateRaw?.toString() ?? '') ?? DateTime.now();

    return AttendanceRecord(
      date: parsedDate,
      studentId: (json['student_id'] ?? json['studentId'] ?? '').toString(),
      studentName: (json['student_name'] ?? json['studentName'] ?? '')
          .toString(),
      present: t != null && t.toString().isNotEmpty,
      checkTime: t?.toString(),
    );
  }
}

/// =====================
/// PAGE
/// =====================
class AttendanceDetailPage extends StatefulWidget {
  final String courseName;
  final String courseId;
  final String userId;

  const AttendanceDetailPage({
    super.key,
    required this.courseName,
    required this.courseId,
    required this.userId,
  });

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  /// ❗️เริ่มต้นยังไม่เลือกวัน → today จะเป็นวงกลมขอบ
  DateTime? _selectedDay;
  DateTime _focusedDay = DateTime.now();

  bool _loading = false;

  final Map<DateTime, List<AttendanceRecord>> _events = {};

  DateTime _key(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void initState() {
    super.initState();
    _fetchMonth(_focusedDay);
    // ยังไม่โหลดจนกว่าจะเลือกวัน
  }

  /// =====================
  /// API
  /// =====================
  Future<void> _fetchAttendance(DateTime day) async {
    setState(() => _loading = true);
    try {
      final dateStr =
          '${day.year.toString().padLeft(4, '0')}-'
          '${day.month.toString().padLeft(2, '0')}-'
          '${day.day.toString().padLeft(2, '0')}';

      final url = Uri.parse('${baseUrl}get_attandance.php').replace(
        queryParameters: {
          'course_id': widget.courseId,
          'type': 'student',
          'user_id': widget.userId,
          'date': dateStr,
        },
      );

      final resp = await http.post(url);
      if (resp.statusCode != 200) return;

      final decoded = json.decode(resp.body);
      final list = decoded is List ? decoded : (decoded['data'] as List? ?? []);

      final records = list
          .whereType<Map>()
          .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      setState(() {
        _events[_key(day)] = records;
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<AttendanceRecord> _recordsOf(DateTime day) {
    return _events[_key(day)] ?? [];
  }

  Future<void> _fetchMonth(DateTime focused) async {
    // เอาเดือน/ปี ปัจจุบัน
    final year = focused.year;
    final month = focused.month;

    final firstDay = DateTime(year, month, 1);
    final lastDay = DateTime(year, month + 1, 0);

    try {
      final url = Uri.parse('${baseUrl}get_attandance.php').replace(
        queryParameters: {
          'course_id': widget.courseId,
          'type': 'student',
          'user_id': widget.userId,
          'start_date':
              '${firstDay.year}-${firstDay.month.toString().padLeft(2, '0')}-01',
          'end_date':
              '${lastDay.year}-${lastDay.month.toString().padLeft(2, '0')}-${lastDay.day}',
        },
      );

      final resp = await http.post(url);
      if (resp.statusCode != 200) return;

      final decoded = json.decode(resp.body);
      final list = decoded is List ? decoded : (decoded['data'] as List? ?? []);

      final Map<DateTime, List<AttendanceRecord>> monthEvents = {};

      for (final item in list) {
        if (item is! Map) continue;

        final record = AttendanceRecord.fromJson(
          Map<String, dynamic>.from(item),
        );

        final key = _key(record.date);
        monthEvents.putIfAbsent(key, () => []).add(record);
      }

      setState(() {
        _events.addAll(monthEvents); // ⭐ สำคัญ: เติม event ลง calendar
      });
    } catch (e) {
      debugPrint('fetchMonth error: $e');
    }
  }

  /// =====================
  /// UI
  /// =====================
  @override
  Widget build(BuildContext context) {
    final records = _selectedDay != null
        ? _recordsOf(_selectedDay!)
        : <AttendanceRecord>[];

    return Scaffold(
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Text(
              widget.courseName,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),

          /// ===== AppCalendar (เหมือนอีกหน้า) =====
          AppCalendar<AttendanceRecord>(
            key: ValueKey(_events.length), // ⭐ สำคัญ
            events: _events,
            initialFocusedDay: _focusedDay,
            initialSelectedDay: _selectedDay,
            onDaySelected: (day) {
              setState(() {
                _selectedDay = day;
                _focusedDay = day;
              });
              _fetchAttendance(day);
            },
            onMonthChanged: (focused) {
              _fetchMonth(focused);
            },
          ),
          const SizedBox(height: 18),

          if (_selectedDay == null)
            const Center(
              child: Text(
                'กรุณาเลือกวันที่จากปฏิทิน',
                style: TextStyle(color: AppCalendarTheme.sub),
              ),
            )
          else if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (records.isEmpty)
            const Center(
              child: Text(
                'ไม่มีข้อมูลการเช็คชื่อในวันนี้',
                style: TextStyle(color: AppCalendarTheme.sub),
              ),
            )
          else
            ...records.map(_buildCard),
        ],
      ),
    );
  }

  /// =====================
  /// CARD
  /// =====================
  Widget _buildCard(AttendanceRecord r) {
    final Color presentColor = const Color(0xFF34D399); // เขียว
    final Color absentColor = const Color(0xFFF87171); // แดง
    final Color bgPresent = presentColor.withOpacity(0.2); // พื้นหลังเขียวอ่อน
    final Color bgAbsent = absentColor.withOpacity(0.2); // พื้นหลังแดงอ่อน

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Material(
        color: Colors.white,
        elevation: 2,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF84A9EA), width: 1.2),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              // ซ้าย: รหัส + ชื่อ
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.studentId,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.studentName,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              // ขวา: เวลาเช็คชื่อ หรือ "ไม่ได้เช็คชื่อ"
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: r.checkTime != null
                      ? bgPresent
                      : bgAbsent, // ✅ พื้นหลังอ่อน
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  r.checkTime ?? 'ไม่ได้เช็คชื่อ',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: r.checkTime != null ? presentColor : absentColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
