import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // ⬅️ เพิ่ม
import 'package:my_app/student/student_home_pages.dart';
import 'package:my_app/teacher/teacher_home_pages.dart';

import './pages/login_page.dart';
import './pages/signup.dart';
import './pages/splash_screen.dart';

// --- Student side ---
import 'student/student_scan_page.dart';
import 'student/leave_upload_page.dart';

// --- Teacher side ---
import 'teacher/courses_page.dart';
import 'teacher/teacher_qr_page.dart';
import 'teacher/teacher_attendancehistory_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Check',
      debugShowCheckedModeBanner: false,

      // เปิดหน้าเริ่มต้น
      // initialRoute: '/teacher_home',
      initialRoute: '/student_home',

      // ✅ รองรับภาษา/ข้อความของ Material (แก้ error DatePickerDialog)
      locale: const Locale('th'), // ถ้าต้องการตามระบบ ให้ลบบรรทัดนี้
      supportedLocales: const [
        Locale('th'), // ไทย
        Locale('en'), // อังกฤษ (สำรอง)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        '/': (context) => const LoginPage(),
        '/splash': (context) => const SplashScreenPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // --- Student side ---
        '/student_home': (context) => const StudentHomePage(),
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // --- Teacher side ---
        '/teacher_home': (context) => const TeacherHomePage(),
        '/courses': (context) => const CoursesPage(),
        '/teacher_attendancehistory': (context) => const AttendanceHistoryPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/teacher_qr') {
          final args = settings.arguments;
          if (args is Map) {
            final courseId = args['courseId'] as int?;
            final courseName = args['courseName'] as String?;
            if (courseId != null && courseName != null) {
              return MaterialPageRoute(
                builder: (_) => TeacherQRPage(courseId: courseId, courseName: courseName),
                settings: settings,
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const CoursesPage());
        }
        return null;
      },

      onUnknownRoute: (_) => MaterialPageRoute(builder: (_) => const LoginPage()),

      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
