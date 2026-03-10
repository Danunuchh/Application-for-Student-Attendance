import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/app_calendar.dart';
import 'package:my_app/config.dart';

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
    final time = json['attendance_time'];
    final presentBool = time != null && time.toString().isNotEmpty;

    DateTime parsedDate;
    final d = json['day'];
    if (d is String) {
      parsedDate = DateTime.tryParse(d) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    return AttendanceRecord(
      date: parsedDate,
      studentId: (json['student_id'] ?? '') as String,
      studentName: (json['student_name'] ?? '') as String,
      present: presentBool,
      checkTime: time?.toString(),
    );
  }
}

class AttendanceDetailPage extends StatefulWidget {
  final String courseName;
  final String courseId;

  const AttendanceDetailPage({
    super.key,
    required this.courseName,
    required this.courseId,
  });

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  final DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  bool _loading = false;
  String? _errorMessage;
  List<AttendanceRecord> _records = [];

  /// แปลง _records เป็น Map<DateTime, List<String>> สำหรับ marker
  Map<DateTime, List<String>> get _attendanceEvents {
    Map<DateTime, List<String>> map = {};
    for (var record in _records) {
      final key = DateTime(
        record.date.year,
        record.date.month,
        record.date.day,
      );
      map.putIfAbsent(key, () => []);
      map[key]!.add(record.studentId);
    }
    return map;
  }

  @override
  void initState() {
    super.initState();
    // โหลดข้อมูลวันแรก (วันนี้) อัตโนมัติ
    _fetchAttendanceForDay(_focusedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.courseName,
                style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
              ),
            ),
          ),

          // ===== ใช้ AppCalendar =====
          AppCalendar<String>(
            events: _attendanceEvents,
            initialFocusedDay: _focusedDay,
            initialSelectedDay: _selectedDay,
            onDaySelected: (day) async {
              setState(() {
                _selectedDay = day;
                _records = [];
                _errorMessage = null;
              });
              await _fetchAttendanceForDay(day);
            },
            onMonthChanged: (month) {
              // สามารถ fetch summary เดือนนี้ได้ถ้าต้องการ
              print('เดือนเปลี่ยน: $month');
            },
          ),

          const SizedBox(height: 18),

          if (_loading) const Center(child: CircularProgressIndicator()),

          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ),

          ..._buildCards(),
        ],
      ),
    );
  }

  Future<void> _fetchAttendanceForDay(DateTime day) async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final dateStr =
        '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';

    final payload = {
      'course_id': widget.courseId,
      'date': dateStr,
      'type': 'teacher',
    };

    try {
      final uri = Uri.parse('${baseUrl}/get_attandance.php');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: payload,
      );

      if (resp.statusCode != 200) {
        throw Exception('HTTP ${resp.statusCode}');
      }

      final data = json.decode(resp.body);
      List<AttendanceRecord> loaded = [];

      if (data is List) {
        loaded = data
            .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (data is Map && data['data'] is List) {
        loaded = (data['data'] as List)
            .map((e) => AttendanceRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }

      setState(() => _records = loaded);
    } catch (e) {
      setState(() {
        _errorMessage = 'ไม่สามารถโหลดข้อมูลได้: $e';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Widget> _buildCards() {
    final Color presentColor = const Color(0xFF34D399); // เขียว
    final Color absentColor = const Color(0xFFF87171); // แดง
    final Color cardBorder = const Color(0xFF84A9EA);
    final Color cardShadow = const Color(0x0D000000);

    if (_records.isEmpty) {
      return [
        const SizedBox(height: 8),
        Center(
          child: Text(
            'ไม่มีข้อมูลการเช็คชื่อในวันนี้',
            style: TextStyle(color: const Color(0xFF9CA3AF), fontSize: 14),
          ),
        ),
      ];
    }

    return _records.map((r) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Card(
          color: Colors.white,
          // surfaceTintColor: Colors.transparent,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: cardBorder, width: 1.5),
          ),
          // shadowColor: cardShadow,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                // ขวา: เวลาเช็คชื่อ
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: r.checkTime != null 
                        ? presentColor.withOpacity(0.1)
                        : absentColor.withOpacity(0.1),
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
    }).toList();
  }
}
