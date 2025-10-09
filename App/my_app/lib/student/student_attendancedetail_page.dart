import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:table_calendar/table_calendar.dart';

/// โมเดลบันทึกการเข้าเรียน (mock)
class AttendanceRecord {
  final DateTime date;
  final String studentId;
  final String studentName;
  final bool present; // true = มาเรียน, false = ไม่ได้เช็คชื่อ
  final String? checkTime; // เช่น "10.00 น."
  AttendanceRecord({
    required this.date,
    required this.studentId,
    required this.studentName,
    required this.present,
    this.checkTime,
  });
}

class AttendanceDetailPage extends StatefulWidget {
  final String courseName; // รับชื่อวิชามาแสดงบนหน้า
  const AttendanceDetailPage({super.key, required this.courseName});

  @override
  State<AttendanceDetailPage> createState() => _AttendanceDetailPageState();
}

class _AttendanceDetailPageState extends State<AttendanceDetailPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late final List<AttendanceRecord> _all; // ข้อมูลทั้งหมด (mock)
  late final Map<DateTime, List<AttendanceRecord>>
  _byDay; // map ไว้ทำ event marker

  @override
  void initState() {
    super.initState();
    // ตัวอย่างข้อมูล (ทำให้หน้าตาเหมือนภาพ)
    _all = [
      AttendanceRecord(
        date: DateTime(DateTime.now().year, 8, 4),
        studentId: '65200020',
        studentName: 'กวิสรา แซ่เชี่ย',
        present: true,
        checkTime: '10.00 น.',
      ),
      AttendanceRecord(
        date: DateTime(DateTime.now().year, 8, 3),
        studentId: '65200020',
        studentName: 'กวิสรา แซ่เชี่ย',
        present: false,
      ),
    ];
    _byDay = _groupByDay(_all);
    _selectedDay = DateTime.now();
  }

  // รวมรายการตามวัน (normalizing key เป็น yyyy-mm-dd)
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
  Widget build(BuildContext context) {
    final outline = const Color(0xFFCDE0F9);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(title: 'ประวัติการเข้าเรียน'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                widget.courseName,
                style: const TextStyle(fontSize: 16, color: Colors.black54),
              ),
            ),
          ),

          // Header เดือน (ปุ่ม ซ้าย/ขวา + ชื่อเดือน)
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

          // ปฏิทิน
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: outline, width: 1.5),
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.fromLTRB(6, 6, 6, 6),
            child: TableCalendar<AttendanceRecord>(
              firstDay: DateTime.utc(2018, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              headerVisible: false, // เราทำ header เองข้างบนแล้ว
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.sunday, // SUN เป็นคอลัมน์แรก
              selectedDayPredicate: (d) =>
                  _selectedDay != null && isSameDay(d, _selectedDay),
              onPageChanged: (f) => setState(() => _focusedDay = f),
              onDaySelected: (sel, foc) => setState(() {
                _selectedDay = sel;
                _focusedDay = foc;
              }),
              availableGestures: AvailableGestures.horizontalSwipe,

              // แสดง marker วันไหนมีข้อมูล
              eventLoader: (day) => _recordsOf(day),

              // ปรับ decoration ให้ไม่ crash (ไม่ผสม circle + borderRadius)
              calendarStyle: CalendarStyle(
                // cells = สี่เหลี่ยมมน (ไม่มี shape)
                defaultDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                weekendDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                outsideDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                disabledDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),
                holidayDecoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                ),

                // today/selected = สี่เหลี่ยมมนเช่นกัน
                todayDecoration: BoxDecoration(
                  border: Border.all(color: outline, width: 1.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                selectedDecoration: BoxDecoration(
                  border: Border.all(color: outline, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),

                // markers = วงกลม (ไม่มี borderRadius)
                markerDecoration: const BoxDecoration(
                  color: Colors.lightBlue,
                  shape: BoxShape.circle,
                ),
                markersAlignment: Alignment.bottomCenter,

                outsideDaysVisible: true,
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.black87),
                weekdayStyle: TextStyle(color: Colors.black87),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // รายการบันทึกของวัน (ตามวันที่เลือก)
          ..._buildCards(day: _selectedDay ?? _focusedDay, outline: outline),
        ],
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

  /// แปลงวันที่เป็น 04/08/68 (ปี พ.ศ. 2 หลัก)
  String _thaiShortDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final buddhist = d.year + 543;
    final yy = (buddhist % 100).toString().padLeft(2, '0');
    return '$dd/$mm/$yy';
  }
}
