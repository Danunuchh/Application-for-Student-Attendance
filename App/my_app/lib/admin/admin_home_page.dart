import 'package:flutter/material.dart';
import 'package:my_app/admin/admin_dashboard_page.dart';

class AppColors {
  static const Color sub = Color(0xFFC4C7D0);
}

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ ดึง arguments ที่ส่งมาจาก Navigator.pushReplacementNamed(..., arguments: {...})
    final args = ModalRoute.of(context)?.settings.arguments;
    final String userId = (args is Map && args['userId'] != null)
        ? args['userId'].toString()
        : ''; // fallback เป็นว่าง ถ้าไม่ได้ส่งมา

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // โลโก้
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.28,
                        minHeight: 120,
                      ),
                      child: Image.asset(
                        'assets/unicheck1.png',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.image, size: 80, color: AppColors.sub),
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
                      '/admin_history',
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
                      '/admin_student',
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
                    // ถ้า Dashboard ก็ต้องใช้ userId เช่นกัน:
                    // Navigator.push(context, MaterialPageRoute(
                    //   builder: (_) => AdminDashboardPage(userId: userId),
                    // ));
                  },
                ),
              ],
            ),
          ),
        ),
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
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFB0C4DE)),
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
