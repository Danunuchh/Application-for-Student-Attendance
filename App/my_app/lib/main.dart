import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Admin side ---
import 'package:my_app/admin/admin_home_page.dart';
import 'package:my_app/admin/admin_student_page.dart';
import 'package:my_app/admin/admin_teacher_page.dart';
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

      // ✅ แก้ตรงนี้
      initialRoute: '/splash',

      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: {
        // 🔹 Auth
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/splash': (context) => const SplashScreenPage(),

        // 🔹 Student
        '/student_home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage();
          }
          return StudentHomePage(userId: userId);
        },
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // 🔹 Teacher
        '/teacher_home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage();
          }
          return TeacherHomePage(userId: userId);
        },
        '/courses': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage();
          }
          return CoursesPage(userId: userId);
        },
        '/teacher_attendancehistory': (context) {
          final args = ModalRoute.of(context)?.settings.arguments
              as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          if (userId == null || userId.isEmpty) {
            return const LoginPage();
          }
          return AttendanceHistoryPage(userId: userId);
        },

        // 🔹 Admin
        '/admin_home': (context) => const AdminHomePage(),
<<<<<<< HEAD
        '/admin_student': (context) => AdminStudentPage(),
        '/admin_teacher': (context) => AdminTeacherPage(),
=======
        '/admin_student': (context) => const AdminStudentPage(),
        '/add_student': (context) => const AddStudentPage(),
        '/admin_teacher': (context) => const AdminTeacherPage(),
        '/add_teacher': (context) => const AddTeacherPage(),
>>>>>>> 8a7bfc79f22c6e3b7c0b669b2d40c9edf92d6f90
        '/admin_history': (context) => const AdminHistoryPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/teacher_qr') {
          final args = settings.arguments;
          if (args is Map<String, dynamic>) {
            final courseId = args['courseId'] as int?;
            final courseName = args['courseName'] as String?;
            if (courseId != null && courseName != null) {
              return MaterialPageRoute(
                builder: (_) => TeacherQRPage(
                  courseId: courseId,
                  courseName: courseName,
                ),
              );
            }
          }
          return MaterialPageRoute(builder: (_) => const LoginPage());
        }
        return null;
      },

      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4A86E8),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Prompt',
      ),
    );
  }
}
