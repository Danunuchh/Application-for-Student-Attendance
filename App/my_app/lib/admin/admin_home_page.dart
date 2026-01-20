import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_dashboard_page.dart';
import 'package:my_app/pages/login_page.dart'; // ✅ import LoginPage
import 'package:my_app/components/button.dart'; // ✅ import CustomButton

class AppColors {
  static const Color sub = Color(0xFFC4C7D0);
  static const Color kPrimary = Color(0xFF3B82F6);
  static const Color kBottom = Color(0xFFF3F4F6);
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final String userId = (args is Map && args['userId'] != null)
        ? args['userId'].toString()
        : '';
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // โลโก้
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.28,
                          minHeight: 120,
                        ),
                        child: Image.asset(
                          'assets/logounimai.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.image,
                            size: 80,
                            color: AppColors.sub,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  _buildRoleButton(
                    text: 'นักศึกษา',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/admin_student',
                        arguments: {'userId': userId},
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildRoleButton(
                    text: 'อาจารย์',
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/admin_teacher',
                        arguments: {'userId': userId},
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildRoleButton(
                    text: 'Dashboard',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AdminDashboardPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 120), // เว้นพื้นที่ให้ปุ่ม bottom
                ],
              ),
            ),
          ),

          // ปุ่มเข้าสู่ระบบด้านล่าง
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: const BoxDecoration(
                color: Color(0xFFA6CAFA),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(22),
                  topRight: Radius.circular(22),
                ),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      text: 'ออกจากระบบ',
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      backgroundColor: const Color(0xFF84A9EA),
                      textColor: Colors.white,
                      fontSize: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: 250,
      height: 55,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(color: Color(0xFF84A9EA), width: 1.5),
          ),
          shadowColor: Colors.grey.shade400,
          elevation: 3,
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
