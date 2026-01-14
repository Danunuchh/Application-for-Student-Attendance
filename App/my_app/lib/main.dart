import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// --- Admin side ---
import 'package:my_app/admin/admin_home_page.dart';
import 'package:my_app/admin/admin_student_page.dart';
import 'package:my_app/admin/admin_teacher_page.dart';
import 'package:my_app/admin/admin_history_page.dart';
// import 'package:my_app/admin/add_student_page.dart';
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

      // หน้าแรก:
      initialRoute: '/login',

      //student_home ,//teacher_home
      // ภาษาที่รองรับ
      locale: const Locale('th'),
      supportedLocales: const [Locale('th'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routes: <String, WidgetBuilder>{
        // 🔹 Auth
        '/': (context) => const LoginPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),

        // 🔹 Student
        '/student_home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          return (userId == null || userId.isEmpty)
              ? const LoginPage()
              : StudentHomePage(userId: userId);
        },
        '/scan': (context) => const StudentScanPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // 🔹 Teacher
        '/teacher_home': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          return (userId == null || userId.isEmpty)
              ? const LoginPage()
              : TeacherHomePage(userId: userId);
        },
        '/courses': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          return (userId == null || userId.isEmpty)
              ? const LoginPage()
              : CoursesPage(userId: userId);
        },
        '/teacher_attendancehistory': (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments
                  as Map<String, dynamic>?;
          final userId = args?['userId'] as String?;
          return (userId == null || userId.isEmpty)
              ? const LoginPage()
              : AttendanceHistoryPage(userId: userId);
        },

        // 🔹 Admin (ไม่ซ้ำ!)
        '/admin_home': (context) => const AdminHomePage(),
        '/admin_student': (context) => const AdminStudentPage(),
        '/admin_teacher': (context) => const AdminTeacherPage(),
        // '/add_student': (context) => const AddStudentPage(),
        // '/add_teacher': (context) => const AddTeacherPage(),
        '/admin_history': (context) => const AdminHistoryPage(),
      },

      onGenerateRoute: (settings) {
        if (settings.name == '/teacher_qr') {
          final args = settings.arguments as Map<String, dynamic>?;
          final courseId = args?['courseId'] as int?;
          final courseName = args?['courseName'] as String?;
          if (courseId != null && courseName != null) {
            return MaterialPageRoute(
              builder: (_) =>
                  TeacherQRPage(courseId: courseId, courseName: courseName),
            );
          }
        }
        return MaterialPageRoute(builder: (_) => const LoginPage());
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
