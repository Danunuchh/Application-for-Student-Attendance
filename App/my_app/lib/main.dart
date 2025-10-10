import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Admin side ---
import 'package:my_app/admin/admin_home_page.dart';
import 'package:my_app/admin/admin_student_page.dart'; //  หน้า "จัดการนักศึกษา"
import 'package:my_app/admin/admin_add_student_page.dart'; // หน้าเพิ่มนักศึกษา
import 'package:my_app/admin/admin_class_page.dart'; // หน้าคลาสเรียน
import 'package:my_app/admin/admin_history_page.dart';

// --- Student side ---
import 'package:my_app/student/student_home_pages.dart';
import 'package:my_app/student/student_scan_page.dart';
import 'package:my_app/student/leave_upload_page.dart';

// --- Teacher side ---
import 'package:my_app/teacher/teacher_home_pages.dart';
import 'package:my_app/teacher/courses_page.dart';
import 'package:my_app/teacher/teacher_qr_page.dart';
import 'package:my_app/teacher/teacher_attendancehistory_page.dart';

// --- Auth / Misc ---
import './pages/login_page.dart';
import './pages/signup.dart';
import './pages/splash_screen.dart';

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

      // ===== หน้าเริ่มต้น =====
      initialRoute: '/admin_home', // student_home, teacher_home
      // ===== Localization (ไทย/อังกฤษ) =====
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ===== เส้นทางหลักทั้งหมด =====
      routes: {
        // Public/Auth
        '/': (context) => const LoginPage(), // เผื่อสลับกลับมาใช้หน้า Login
        '/splash': (context) => const SplashScreenPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // Student
        '/student_home': (context) => const StudentHomePage(),
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // Teacher
        '/teacher_home': (context) => const TeacherHomePage(),
        '/courses': (context) => const CoursesPage(),
        '/teacher_attendancehistory': (context) =>
            const AttendanceHistoryPage(),

        // Admin
        '/admin_home': (context) => const AdminHomePage(), // หน้าแอดมินหลัก
        '/admin_student': (context) =>
            const AdminStudentPage(), //  หน้าจัดการนักศึกษา
        '/add_student': (context) =>
            const AddStudentPage(), // หน้าเพิ่มนักศึกษา
        '/admin_history': (context) => const AdminHistoryPage(),
      },

      // ===== เส้นทางที่ต้องใช้ arguments =====
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
          // ถ้า args ไม่ครบ กลับไปหน้า Courses
          return MaterialPageRoute(builder: (_) => const CoursesPage());
        }
        return null;
      },

      // ===== กันหลงทาง =====
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),

      // ===== ธีม =====
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
