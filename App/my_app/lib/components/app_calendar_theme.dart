import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class AppCalendarTheme {
  // ===== Colors =====
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF9CA3AF);
  static const border = Color(0xFFCFE0FF);
  static const todayBg = Color.fromARGB(255, 221, 232, 248);

  // ===== Header =====
  static const HeaderStyle headerStyle = HeaderStyle(
    titleCentered: true,
    formatButtonVisible: false,
  );

  // ===== Weekdays =====
  static const DaysOfWeekStyle daysOfWeekStyle = DaysOfWeekStyle(
    weekdayStyle: TextStyle(fontSize: 12, color: sub),
    weekendStyle: TextStyle(fontSize: 12, color: sub),
  );

  // ===== Calendar =====
  static CalendarStyle calendarStyle = CalendarStyle(
    defaultTextStyle: const TextStyle(
      color: ink,
      fontSize: 12,
    ),
    weekendTextStyle: const TextStyle(
      color: ink,
      fontSize: 12,
    ),
    outsideDaysVisible: true,

    todayDecoration: BoxDecoration(
      color: todayBg,
      shape: BoxShape.circle,
      border: Border.all(color: const Color(0xFF4A86E8), width: 1.5),
    ),
    todayTextStyle: const TextStyle(
      color: primary,
      fontWeight: FontWeight.w700,
    ),

    selectedDecoration: const BoxDecoration(
      color: primary,
      shape: BoxShape.circle,
    ),

    markersAlignment: Alignment.bottomCenter,
    markersMaxCount: 3,
    markerDecoration: const BoxDecoration(
      color: primary,
      shape: BoxShape.circle,
    ),
    markerSizeScale: 0.12,
  );
}
