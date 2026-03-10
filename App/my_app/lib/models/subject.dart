// lib/models/subject.dart
class Subject {
  final String id;
  final String title;
  final String code;
  final String credits;
  final String section;
  final String year;
  final String term;
  final String teacher;
  final String time;   // เช่น "17:00 - 20:00"
  final String room;

  const Subject({
    required this.id,
    required this.title,
    required this.code,
    required this.credits,
    required this.section,
    required this.year,
    required this.term,
    required this.teacher,
    required this.time,
    required this.room,
  });

  // ดึงจาก JSON (API/DB)
  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: (json['id'] ?? '').toString(),
        title: (json['title'] ?? '').toString(),
        code: (json['code'] ?? '').toString(),
        credits: (json['credits'] ?? '').toString(),
        section: (json['section'] ?? '').toString(),
        year: (json['year'] ?? '').toString(),
        term: (json['term'] ?? '').toString(),
        teacher: (json['teacher'] ?? '').toString(),
        time: (json['time'] ?? '').toString(),
        room: (json['room'] ?? '').toString(),
      );

  // แปลงเป็น JSON (ส่งกลับ API/DB)
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'code': code,
        'credits': credits,
        'section': section,
        'year': year,
        'term': term,
        'teacher': teacher,
        'time': time,
        'room': room,
      };

  // แก้ไขเฉพาะบาง field ได้สะดวก
  Subject copyWith({
    String? id,
    String? title,
    String? code,
    String? credits,
    String? section,
    String? year,
    String? term,
    String? teacher,
    String? time,
    String? room,
  }) {
    return Subject(
      id: id ?? this.id,
      title: title ?? this.title,
      code: code ?? this.code,
      credits: credits ?? this.credits,
      section: section ?? this.section,
      year: year ?? this.year,
      term: term ?? this.term,
      teacher: teacher ?? this.teacher,
      time: time ?? this.time,
      room: room ?? this.room,
    );
  }

  @override
  String toString() =>
      'Subject(title: $title, code: $code, credits: $credits, section: $section, year: $year, term: $term, teacher: $teacher, time: $time, room: $room)';

  // เทียบค่า (เพื่อประโยชน์เวลาทดสอบ/เทียบรายการ)
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Subject &&
        other.title == title &&
        other.code == code &&
        other.credits == credits &&
        other.section == section &&
        other.year == year &&
        other.term == term &&
        other.teacher == teacher &&
        other.time == time &&
        other.room == room;
  }

  @override
  int get hashCode =>
      title.hashCode ^
      code.hashCode ^
      credits.hashCode ^
      section.hashCode ^
      year.hashCode ^
      term.hashCode ^
      teacher.hashCode ^
      time.hashCode ^
      room.hashCode;
}
