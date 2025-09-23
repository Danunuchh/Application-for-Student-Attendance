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
      const MenuItemData("คลาสเรียน", "assets/bell.svg"),
      const MenuItemData("ปฏิทิน", "assets/calendar.svg"),
      const MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/document.svg"),
      const MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
      const MenuItemData("สรุป\nผลรายงาน", "assets/piechart.svg"),
    ];
    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2);

    return Scaffold(
      backgroundColor: Colors.white,

      // >>> ปุ่มบวก: เชื่อมไป CoursesPage แบบ push (เหมือนสไตล์ไฟล์เดิม) <<<
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: AppColors.fabRing,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton.large(
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: const CircleBorder(),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CoursesPage()),
            );
          },
          child: SvgPicture.asset(
            'assets/plus.svg',
            width: 36,
            height: 36,
            fit: BoxFit.contain,
          ),
        ),
      ),

      bottomNavigationBar: SizedBox(
        height: 60,
        child: BottomAppBar(
          color: const Color(0xFFA6CAFA),
          shape: const CircularNotchedRectangle(),
          notchMargin: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BarIcon(svgPath: "assets/home.svg"),
              SizedBox(width: 50),
              _BarIcon(svgPath: "assets/logout.svg"),
            ],
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
                      width: 28,
                      height: 28,
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
                      "assets/num_student.svg",
                      width: 30,
                      height: 30,
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
                  height: 240,
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
                  fontSize: 18,
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

class _BarIcon extends StatelessWidget {
  final String svgPath;
  const _BarIcon({required this.svgPath});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        onPressed: () {},
        icon: SvgPicture.asset(
          svgPath,
          width: 32,
          height: 32,
          colorFilter: const ColorFilter.mode(AppColors.ink, BlendMode.srcIn),
        ),
        splashRadius: 28,
      ),
    );
  }
}
