// lib/models/day.dart
class Day {
  final int id;
  final String name;
  final String nameEn;

  const Day({
    required this.id,
    required this.name,
    required this.nameEn,
  });

  // Map day_id เป็นวันในสัปดาห์ (1=อาทิตย์, 2=จันทร์, ..., 7=เสาร์)
  static const Map<int, Day> days = {
    1: Day(id: 1, name: 'อาทิตย์', nameEn: 'Sunday'),
    2: Day(id: 2, name: 'จันทร์', nameEn: 'Monday'),
    3: Day(id: 3, name: 'อังคาร', nameEn: 'Tuesday'),
    4: Day(id: 4, name: 'พุธ', nameEn: 'Wednesday'),
    5: Day(id: 5, name: 'พฤหัสบดี', nameEn: 'Thursday'),
    6: Day(id: 6, name: 'ศุกร์', nameEn: 'Friday'),
    7: Day(id: 7, name: 'เสาร์', nameEn: 'Saturday'),
  };
  // หาทุกวันที่ตรงกับ day_id ในช่วง date range
  static List<DateTime> getAllDatesInRange(int dayId, DateTime start, DateTime end) {
    final dates = <DateTime>[];

    // แปลง day_id (1=อาทิตย์) เป็น Dart weekday (7=อาทิตย์)
    final targetWeekday = dayId == 1 ? 7 : dayId - 1;

    // หาวันแรกที่ตรงกับ day_id โดยเริ่มจาก start
    var current = DateTime(start.year, start.month, start.day);
    final currentWeekday = current.weekday;

    // คำนวณจำนวนวันที่ต้องเลื่อนไปข้างหน้า
    int daysToAdd = targetWeekday - currentWeekday;
    if (daysToAdd < 0) {
      daysToAdd += 7; // ถ้าเป็นลบ เพิ่ม 7 วันเพื่อหาวันถัดไป
    }

    current = current.add(Duration(days: daysToAdd));

    // เพิ่มทุกสัปดาห์จนถึง end
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 7));
    }

    return dates;
  }

  // ดึงชื่อวันจาก day_id
  static String? getName(int dayId) {
    return days[dayId]?.name;
  }

  static String? getNameEn(int dayId) {
    return days[dayId]?.nameEn;
  }
}
