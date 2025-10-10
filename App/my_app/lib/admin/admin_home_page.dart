import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_dashboard_page.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ===== โลโก้ UniCheck =====
              Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Image.asset('assets/unicheck.png', width: 180),
              ),

              // ===== ปุ่มนักศึกษา =====
              _buildRoleButton(
                text: 'นักศึกษา',
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_history');
                },
              ),

              const SizedBox(height: 20),

              // ===== ปุ่มอาจารย์ =====
              _buildRoleButton(
                text: 'อาจารย์',
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_student');
                },
              ),

              const SizedBox(height: 20),

              // ===== ปุ่ม Dashboard (สไตล์เดียวกัน) =====
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
            ],
          ),
        ),
      ),
    );
  }

  // ===== ปุ่มสไตล์เดียวกัน =====
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
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFB0C4DE)), // ขอบฟ้าอ่อน
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
