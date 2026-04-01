import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomBottomBarWithFab extends StatelessWidget {
  final String role; // 'student' | 'teacher' | 'admin'
  final VoidCallback onProfile;
  final VoidCallback onLogout;
  final VoidCallback onFabTap;
  final Widget body; 

  const CustomBottomBarWithFab({
    super.key,
    required this.role,
    required this.onProfile,
    required this.onLogout,
    required this.onFabTap,
    required this.body,
  });

  // เลือกไอคอน FAB ตามบทบาท
  String _getFabIcon() {
    switch (role) {
      case 'teacher':
        return 'assets/qr_code.svg'; // สร้าง QR (อาจารย์)
      // case 'admin':
      //   return 'assets/dashboard.svg';
      default:
        return 'assets/scan.svg'; // สแกน QR (นักศึกษา)
    }
  }

  Color _getFabColor() {
    switch (role) {
      case 'teacher':
        return const Color(0xFFFFFFFF);
      case 'admin':
        return const Color(0xFFFFFFFF);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    // โทนสีพื้นฐาน (ฮาร์ดโค้ดเพื่อไม่ต้องไปแก้อะไรที่หน้าอื่น)
    const fabRing = Color(0xFFA6CAFA);
    const ink = Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: Colors.white,

      // ===== FAB (มีวงแหวน) =====
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: fabRing, // วงแหวนรอบวงกลม
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 80,
          height: 80,
          child: FloatingActionButton(
            elevation: 2,
            backgroundColor: _getFabColor(),
            foregroundColor: ink,
            shape: const CircleBorder(),
            onPressed: onFabTap,
            child: SvgPicture.asset(
              _getFabIcon(),
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),

      bottomNavigationBar: BottomAppBar(
  color: fabRing,
  shape: const CircularNotchedRectangle(),
  notchMargin: 4,
  height: 52,
  padding: const EdgeInsets.symmetric(horizontal: 50),
  child: Transform.translate(
    offset: const Offset(0, 2),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ===== PROFILE (แทน HOME) =====
        IconButton(
          onPressed: onProfile,
          icon: SvgPicture.asset(
            "assets/profile.svg",
            width: 30,
            height: 30,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          splashRadius: 24,
        ),

        // ===== LOGOUT =====
        IconButton(
          onPressed: onLogout,
          icon: SvgPicture.asset(
            "assets/logout.svg",
            width: 26,
            height: 26,
            colorFilter: const ColorFilter.mode(
              Colors.black,
              BlendMode.srcIn,
            ),
          ),
          splashRadius: 24,
        ),
      ],
    ),
  ),
),


      // ===== Body ที่ส่งมาจากหน้าเรียกใช้ =====
      body: body,
    );
  }
}
