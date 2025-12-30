import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Admin side ---
import 'package:my_app/admin/admin_home_page.dart';
import 'package:my_app/admin/admin_student_page.dart';
import 'package:my_app/admin/admin_add_student_page.dart';
import 'package:my_app/admin/admin_history_page.dart';
import 'package:my_app/admin/admin_teacher_page.dart';
import 'package:my_app/admin/admin_add_teacher_page.dart';

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
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/pages/signup.dart';
import 'package:my_app/pages/splash_screen.dart';

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

      // หน้าแรก: Splash เพื่อตรวจ token/role
      initialRoute: '/teacher_home',
      //student_home
      // ภาษาที่รองรับ
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ======= Static Routes =======
      routes: {
        // 🔹 Auth Pages
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/splash': (context) => const SplashScreenPage(),

        // 🔹 Student Pages (ไม่ใช้ const เพราะต้องอ่าน arguments)
        '/student_home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            // ถ้าไม่มี userId ให้ย้อนกลับไปหน้า login (หรือ splash ตามที่ต้องการ)
            return const LoginPage();
          }
          return StudentHomePage(userId: userId);
        },
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // 🔹 Teacher Pages (ไม่ใช้ const เพราะต้องอ่าน arguments)
        '/teacher_home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage();
          }
          return TeacherHomePage(userId: userId);
        },
        '/courses': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage(); // หรือย้อนกลับหน้า teacher_home ก็ได้
          }
          return CoursesPage(userId: userId);
        },
        '/teacher_attendancehistory': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) return const LoginPage();
          return AttendanceHistoryPage(userId: userId);
        },

        // 🔹 Admin Pages
        '/admin_home': (context) => const AdminHomePage(),
        '/admin_student': (context) => const AdminStudentPage(),
        '/add_student': (context) => const AddStudentPage(),
        '/admin_teacher': (context) => const AdminTeacherPage(),
        '/add_teacher': (context) => const AddTeacherPage(),
        '/admin_history': (context) => const AdminHistoryPage(),
      },

      // ======= Dynamic Routes =======
      onGenerateRoute: (settings) {
        if (settings.name == '/teacher_qr') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
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
          // ❌ อย่ากลับไป CoursesPage แบบไม่ส่ง userId อีกแล้ว
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return null;
      },

      // กันหลงทาง
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),

      // ธีมหลัก
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4A86E8),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Prompt',
      ),
    );
  }
}
