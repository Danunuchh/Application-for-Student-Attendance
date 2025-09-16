import 'package:flutter/material.dart';
import './pages/login_page.dart';
import './pages/signup.dart'; // ต้องมีคลาส SignUpPage อยู่ในไฟล์นี้
import './pages/splash_screen.dart'; // ต้องมีคลาส SplashScreenPage
import 'student/guestupload_page.dart'; // ต้องมีคลาส GuestUploadPage
import 'teacher/courses_page.dart';
import 'teacher/teacher_qr_page.dart'; // มีคลาส TeacherQRPage(courseId, courseName)
import 'student/student_scan_page.dart';
import './teacher/teacher_qr_page.dart'; // มีคลาส TeacherQRPage(courseId, courseName)
import './student/student_scan_page.dart';
import 'teacher/course_history_page.dart';
import './student/leave_upload_page.dart'; 

void main() {
  // WidgetsFlutterBinding.ensureInitialized(); // (ไม่บังคับตอนนี้)
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Check',
      debugShowCheckedModeBanner: false,

      // หน้าแรก
      initialRoute: '/splash',

      // ลงทะเบียนเส้นทางที่มีจริงทั้งหมด (เหมือนเดิม)
      routes: {
        '/': (context) => const LoginPage(), // สำรองไว้ถ้าหลงมา root
        '/splash': (context) => const SplashScreenPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/guestupload': (context) => const GuestUploadPage(),
        '/courses': (context) => const CoursesPage(),
        '/scan': (context) => const StudentScanPage(),
        '/course_history': (context) => const CourseHistoryPage(),
        '/leave_upload': (context) => const LeaveUploadPage(),

        // ✳️ อย่าลงทะเบียน '/teacher_qr' ที่นี่แบบเปล่า ๆ
        // เพราะเราต้องส่ง arguments (courseId, courseName)
      },

      // NEW: รองรับหน้า /teacher_qr ที่ต้อง "รับ arguments"
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
          // arguments ไม่ครบ → กลับหน้า courses
          return MaterialPageRoute(builder: (_) => const CoursesPage());
        }
        return null; // ให้ไปต่อ onUnknownRoute ถ้าไม่แมตช์
      },

      // NEW: กันกรณี route ไม่รู้จัก
      onUnknownRoute: (_) =>
          MaterialPageRoute(builder: (_) => const LoginPage()),

      theme: ThemeData(
        useMaterial3: true, // ดูทันสมัยขึ้นนิดหน่อย (จะเอาออกก็ได้)
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
