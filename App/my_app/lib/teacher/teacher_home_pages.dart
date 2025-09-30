import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/teacher/attendancehistory_page.dart';
import 'package:my_app/teacher/calender_page.dart';
import 'package:my_app/teacher/courses_page.dart';
import 'package:my_app/teacher/dashboard_page.dart';
import 'package:my_app/teacher/edit_profile_page.dart';
import 'package:my_app/teacher/pending_approvals_page.dart';

import '../components/menu_title.dart';

class AppColors {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color.fromARGB(255, 196, 199, 208);
  static const fabRing = Color(0xFFA6CAFA);
}

class MenuItemData {
  final String title;
  final String svgPath;
  const MenuItemData(this.title, this.svgPath);
}

class TeacherHomePage extends StatelessWidget {
  const TeacherHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <MenuItemData>[
      const MenuItemData("คลาสเรียน", "assets/bookplus.svg"),
      const MenuItemData("ปฏิทิน", "assets/calendar.svg"),
      const MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/document.svg"),
      const MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
      const MenuItemData("สรุป\nผลรายงาน", "assets/piechart.svg"),
    ];
    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2);

    return Scaffold(
      backgroundColor: Colors.white,

      // ===== FAB วงกลมกลาง + วงแหวนฟ้า =====
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(5), // ความหนาของวงแหวนฟ้า
        decoration: const BoxDecoration(
          color: AppColors.fabRing,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 84,   // ปรับขนาดเองของวงกลมสีขาว
          height: 84,
          child: FloatingActionButton(
            elevation: 2,
            backgroundColor: Colors.white, // วงกลมสีขาว
            foregroundColor: AppColors.ink,
            shape: const CircleBorder(),
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoursesPage()),
            );
          },
            child: SvgPicture.asset(
              'assets/qr_code.svg',
              width: 40, // ปรับไอคอนให้สมดุล
              height: 40,
            ),
          ),
        ),
      ),

       // ===== Bottom bar แท่งฟ้าอ่อน (ไม่มี notch) =====
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          height: 50,
          decoration: const BoxDecoration(
            color: AppColors.fabRing, // ฟ้าอ่อน
            borderRadius: BorderRadius.zero, // เหลี่ยม/โค้งนิดหน่อยตามต้องการ
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ไอคอนซ้าย (Home)
                IconButton(
                  onPressed: () {},
                  icon: SvgPicture.asset(
                    "assets/home.svg",
                    width: 26,
                    height: 26,
                    colorFilter: const ColorFilter.mode(
                      Colors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                  splashRadius: 24,
                ),
                // ไอคอนขวา (Logout)
                IconButton(
                  onPressed: () {
                    // TODO: logout
                  },
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
      ),


      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ไอคอนด้านบน
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: SvgPicture.asset(
                      "assets/bell.svg",
                      width: 22,
                      height: 22,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfilePage(),
                        ),
                      );
                    },
                    icon: SvgPicture.asset(
                      "assets/profile.svg",
                      width: 34,
                      height: 34,
                    ),
                  ),
                ],
              ),
            ),

            // โลโก้
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
              child: Center(
                child: Image.asset(
                  'assets/unicheck.png',
                  height: 210,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image, size: 80, color: AppColors.sub),
                ),
              ),
            ),
            const SizedBox(height: 10),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // เมนู
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MenuTitle(
                            title: topRow[0].title,
                            svgPath: topRow[0].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: const Color(0xFF000000),
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CoursesPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: topRow[1].title,
                            svgPath: topRow[1].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: const Color(0xFF000000),
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CalendarPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[0].title,
                            svgPath: bottomRow[0].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: const Color(0xFF000000),
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const PendingApprovalsPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[1].title,
                            svgPath: bottomRow[1].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: const Color(0xFF000000),
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AttendanceHistoryPage(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[2].title,
                            svgPath: bottomRow[2].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: const Color(0xFF000000),
                            textColor: Colors.black,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const DashboardPage(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MenuTitle extends StatelessWidget {
  final String title;
  final String svgPath;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;
  final VoidCallback? onTap;

  const MenuTitle({
    super.key,
    required this.title,
    required this.svgPath,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(  //เมนูกรอบสีฟ้า 5 เมนู
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(  //ขนาดของไอคอนตรงเมนู
                  svgPath,
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 11,
                  height: 1.15,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

