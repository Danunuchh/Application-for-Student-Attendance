import 'package:flutter/material.dart';
import 'package:my_app/components/custom_bar.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/components/menu_title.dart';

import 'package:my_app/student/student_attendancehistory_page.dart';
import 'package:my_app/student/leave_upload_page.dart';
import 'package:my_app/student/course_approval_page.dart';
import 'package:my_app/student/student_courses_page.dart';
import 'package:my_app/student/qr_scan_page.dart';
import 'package:my_app/student/student_calendar_loader.dart';

import 'package:my_app/pages/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppColors {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color.fromARGB(255, 196, 199, 208);
  static const fabRing = Color(0xFFA6CAFA);
}

class MenuItemData {
  final String title;
  final String svgPath;
  MenuItemData(this.title, this.svgPath);
}

class StudentHomePage extends StatelessWidget {
  final String userId;
  const StudentHomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final items = <MenuItemData>[
      MenuItemData("ปฏิทิน", "assets/calendar.svg"),
      MenuItemData("ส่งใบลา", "assets/file.svg"),
      MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/document.svg"),
      MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
      MenuItemData("สรุป\nผลรายงาน", "assets/piechart.svg"),
    ];

    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2);

    return CustomBottomBarWithFab(
      role: 'student',

      // ===== PROFILE (แทน Home เดิม) =====
      onProfile: () async {
        final prefs = await SharedPreferences.getInstance();
        final savedId = prefs.getString('userId');
        final uid = (savedId != null && savedId.isNotEmpty) ? savedId : userId;

        if (uid.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่'),
            ),
          );
          return;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(userId: uid, role: 'student'),
          ),
        );
      },

      // ===== LOGOUT =====
      onLogout: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },

      // ===== FAB (สแกน QR) =====
      onFabTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScanPage()),
        );
        if (result != null) {
          debugPrint('QR Result: $result');
        }
      },

      // ===== BODY =====
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;

            final double logoHeight = (screenHeight * 0.28)
                .clamp(120.0, 220.0)
                .toDouble();

            final double horizontalPadding = screenWidth > 900
                ? 120
                : screenWidth > 600
                ? 60
                : 24;

            return Column(
              children: [
                const SizedBox(height: 20),

                /// ===== LOGO =====
                Image.asset(
                  'assets/mainlogo.png',
                  height: logoHeight,
                  fit: BoxFit.contain,
                ),

                /// ===== MENU อยู่กลางจอจริง ๆ =====
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ---- แถวบน ----
                          Row(
                            children: [
                              Expanded(
                                child: MenuTitle(
                                  title: topRow[0].title,
                                  svgPath: topRow[0].svgPath,
                                  iconBg: const Color(0xFFCDE0F9),
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const StudentCalendarLoader(),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MenuTitle(
                                  title: topRow[1].title,
                                  svgPath: topRow[1].svgPath,
                                  iconBg: const Color(0xFFCDE0F9),
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LeaveUploadPage(),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // ---- แถวล่าง ----
                          Row(
                            children: [
                              Expanded(
                                child: MenuTitle(
                                  title: bottomRow[0].title,
                                  svgPath: bottomRow[0].svgPath,
                                  iconBg: const Color(0xFFCDE0F9),
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentApprovalCoursePage(
                                            studentId: userId,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: MenuTitle(
                                  title: bottomRow[1].title,
                                  svgPath: bottomRow[1].svgPath,
                                  iconBg: const Color(0xFFCDE0F9),
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final currentUserId =
                                        prefs.getString('userId') ?? userId;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AttendanceHistoryPage(
                                          userId: currentUserId,
                                        ),
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
                                  iconColor: Colors.black,
                                  textColor: Colors.black,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          StudentCoursesPage(userId: userId),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
