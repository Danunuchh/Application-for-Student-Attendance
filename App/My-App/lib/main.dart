import 'package:flutter/material.dart';
import './pages/login_page.dart';
import './pages/signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Uni Check', // ชื่อแอป
      debugShowCheckedModeBanner: false, // ปิดแถบ Debug
      initialRoute: '/login', // กำหนดหน้าเริ่มต้น
      routes: {
        '/login': (context) => const LoginPage(), // กำหนดเส้นทางไปหน้า Login
        '/signup': (context) => const SignUpPage(), // กำหนดเส้นทางไปหน้า SignUp
        // กำหนดเส้นทางไปหน้า AttendancePage
      },
      theme: ThemeData(
        primarySwatch: Colors.blue, // กำหนดสีหลักให้กับแอป
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}
