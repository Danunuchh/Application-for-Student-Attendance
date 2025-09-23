import 'package:flutter/material.dart';
import 'package:my_app/student/student_home_pages.dart';
import 'package:my_app/teacher/teacher_home_pages.dart';

import './pages/login_page.dart';
import './pages/signup.dart';
import './pages/splash_screen.dart';

// --- Student side ---
import 'student/guestupload_page.dart';
import 'student/student_scan_page.dart';
import 'student/leave_upload_page.dart';

// --- Teacher side ---
import 'teacher/courses_page.dart';
import 'teacher/teacher_qr_page.dart';
import 'teacher/course_history_page.dart';

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

      // ตอนนี้เปิดเป็น Student Home
      // initialRoute: '/teacher_home', // 👉 ถ้าอยากไปหน้าอาจารย์ เอา // ออก
      initialRoute: '/student_home',

      routes: {
        '/': (context) => const LoginPage(),
        '/splash': (context) => const SplashScreenPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // --- Student side ---
        '/student_home': (context) => const StudentHomePage(),
        '/guestupload': (context) => const GuestUploadPage(),
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // --- Teacher side ---
        '/teacher_home': (context) => const TeacherHomePage(),
        '/courses': (context) => const CoursesPage(),
        '/course_history': (context) => const CourseHistoryPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/teacher_qr') {
          final args = settings.arguments;
          if (args is Map) {
            final courseId = args['courseId'] as int?;
            final courseName = args['courseName'] as String?;
            if (courseId != null && courseName != null) {
              return MaterialPageRoute(
                builder: (_) =>
                    TeacherQRPage(courseId: courseId, courseName: courseName),
                settings: settings,
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const CoursesPage());
        }
        return null;
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),

      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
