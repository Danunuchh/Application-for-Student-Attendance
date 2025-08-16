import 'package:flutter/material.dart';
import './pages/login_page.dart';
import './pages/signup.dart';
import './pages/splash_screen.dart'; // แก้ไข: เพิ่ม ;

import './pages/guestupload_page.dart';

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
      initialRoute: '/splash', // แก้ไข: ตั้งหน้า Splash เป็นหน้าแรก
      routes: {
        '/login': (context) => const LoginPage(), // กำหนดเส้นทางไปหน้า Login
        '/signup': (context) => const SignUpPage(), // กำหนดเส้นทางไปหน้า SignUp
        // กำหนดเส้นทางไปหน้า AttendancePage
      },
      theme: ThemeData(
        // primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
