// lib/student/student_attendancedetail_page.dart
import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// โมเดลบันทึกการเข้าเรียน
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
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      present: json['present'] as bool,
      checkTime: json['checkTime'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'studentId': studentId,
    'studentName': studentName,
    'present': present,
    'checkTime': checkTime,
  };
}

class AttendanceDetailPage extends StatefulWidget {
  final String courseName;
  final String courseId;
  final String userId; // ✅ เพิ่มตรงนี้

  const AttendanceDetailPage({
    super.key,
    required this.courseName,
    required this.courseId,
    required this.userId, // ✅ ต้องใส่ required
  });

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _loading = false;
  List<AttendanceRecord> _records = [];
  late Map<DateTime, List<AttendanceRecord>> _byDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime(
      _focusedDay.year,
      _focusedDay.month,
      _focusedDay.day,
    );
    _fetchAttendance();
  }

  Future<void> _fetchAttendance() async {
    setState(() => _loading = true);
    try {
      final url = Uri.parse('http://192.168.0.111:8000/get_attandance.php')
          .replace(
            queryParameters: {
              'course_id': widget.courseId, // ✅ เปลี่ยน courseId → course_id
              'type': 'student',
              'user_id': widget.userId,
            },
          );

      final resp = await http.get(url);

      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as List<dynamic>;
        _records = data
            .map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
            .toList();
        _byDay = _groupByDay(_records);
      } else {
        _showSnack('เกิดข้อผิดพลาดในการดึงข้อมูล: ${resp.statusCode}');
      }
    } catch (e) {
      _showSnack('เกิดข้อผิดพลาด: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Map<DateTime, List<AttendanceRecord>> _groupByDay(
    List<AttendanceRecord> list,
  ) {
    final map = <DateTime, List<AttendanceRecord>>{};
    for (final r in list) {
      final k = DateTime(r.date.year, r.date.month, r.date.day);
      map.putIfAbsent(k, () => []).add(r);
    }
    return map;
  }

  List<AttendanceRecord> _recordsOf(DateTime day) {
    final k = DateTime(day.year, day.month, day.day);
    return _byDay[k] ?? const [];
  }

  @override
  @override
  Widget build(BuildContext context) {
    const outline = Color(0xFFCDE0F9);
    const primary = Color(0xFF4A86E8);
    return Scaffold(
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Center(
                  child: Text(
                    widget.courseName,
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ),

                // Header เดือน
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month - 1,
                            1,
                          );
                        });
                      },
                    ),
                    Text(
                      _monthName(_focusedDay.month),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      splashRadius: 20,
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        setState(() {
                          _focusedDay = DateTime(
                            _focusedDay.year,
                            _focusedDay.month + 1,
                            1,
                          );
                        });
                      },
                    ),
                  ],
                ),

                // ===== ปฏิทิน =====
                Container(
                  decoration: BoxDecoration(
                    //ตกแต่งปฏิทิน
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFFA6CAFA),
                      width: 1.5, // ✅ เส้นขอบหนา 2
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 6,
                        spreadRadius: 2, // ✅ เงาชัดขึ้น
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: TableCalendar<AttendanceRecord>(
                    firstDay: DateTime.utc(2018, 1, 1),
                    lastDay: DateTime.utc(2100, 12, 31),
                    focusedDay: _focusedDay,
                    headerVisible: false,
                    calendarFormat: CalendarFormat.month,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    selectedDayPredicate: (d) =>
                        _selectedDay != null && isSameDay(d, _selectedDay),
                    onPageChanged: (f) => setState(() => _focusedDay = f),
                    onDaySelected: (sel, foc) => setState(() {
                      _selectedDay = sel;
                      _focusedDay = foc;
                    }),
                    availableGestures: AvailableGestures.horizontalSwipe,
                    eventLoader: (d) => _recordsOf(d),

                    // custom cell (ไม่มีเงาสี่เหลี่ยม)
                    calendarBuilders: CalendarBuilders(
                      defaultBuilder: (context, day, _) =>
                          _buildDayCell(day, Colors.black87),
                      outsideBuilder: (context, day, _) =>
                          _buildDayCell(day, Colors.black38),
                      todayBuilder: (context, day, _) => _buildDayCell(
                        day,
                        Colors.black87,
                        borderColor: outline,
                      ),
                      selectedBuilder: (context, day, _) =>
                          _buildDayCell(day, Colors.white, bgColor: primary),
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return const SizedBox.shrink();
                        // จุดบอกว่ามีข้อมูลเช็คชื่อ
                        return Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Color(0xFF4A86E8),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    daysOfWeekStyle: const DaysOfWeekStyle(
                      weekendStyle: TextStyle(color: Colors.black87),
                      weekdayStyle: TextStyle(color: Colors.black87),
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                ..._buildCards(
                  day: _selectedDay ?? _focusedDay,
                  outline: outline,
                ),
              ],
            ),
    );
  }

  // === cell แบบวงกลม ===
  Widget _buildDayCell(
    DateTime day,
    Color textColor, {
    Color? bgColor,
    Color? borderColor,
  }) {
    final isCircle = bgColor != null || borderColor != null;
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: isCircle
            ? BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
                border: borderColor != null
                    ? Border.all(color: borderColor, width: 1.5)
                    : null,
              )
            : const BoxDecoration(),
        alignment: Alignment.center,
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w500,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCards({required DateTime day, required Color outline}) {
    final records = _recordsOf(day);
    if (records.isEmpty) {
      return [
        const SizedBox(height: 8),
        Center(
          child: Text(
            'ไม่มีข้อมูลการเช็คชื่อในวันนี้',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ];
    }
    return records.map((r) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Material(
          color: Colors.white,
          elevation: 2,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: outline, width: 1.2),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ซ้าย: วันที่ + รายชื่อนักศึกษา
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _thaiShortDate(r.date),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${r.studentId} ${r.studentName}',
                        style: const TextStyle(fontSize: 14.5),
                      ),
                    ],
                  ),
                ),
                // ขวา: เวลา หรือ “ไม่ได้เช็คชื่อ”
                Text(
                  r.present ? (r.checkTime ?? '') : 'ไม่ได้เช็คชื่อ',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: r.present ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  String _monthName(int m) {
    const en = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return en[m];
  }

  String _thaiShortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final buddhist = d.year + 543;
    final yy = (buddhist % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}
