import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/components/custom_bar.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/components/menu_title.dart';

import 'package:my_app/student/student_attendancehistory_page.dart';
import 'package:my_app/student/leave_upload_page.dart';
import 'package:my_app/student/pending_approvals_page.dart';
import 'package:my_app/student/student_courses_page.dart';
import 'package:my_app/student/qr_scan_page.dart';
import 'package:my_app/student/student_calendar_loader.dart';

// ใช้หน้าแก้ไขโปรไฟล์เวอร์ชันนักศึกษา
import 'package:my_app/pages/edit_profile_page.dart'
    show EditProfileStudentPage, EditProfilePage;
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
      MenuItemData("ส่งใบลา/มาสาย", "assets/file.svg"),
      MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/document.svg"),
      MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
      MenuItemData("สรุป\nผลรายงาน", "assets/piechart.svg"),
    ];
    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2);

    return CustomBottomBarWithFab(
      role: 'student',
      onHome: () {},
      onLogout: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      },
      onFabTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const QRScanPage()),
        );
        if (result != null) {
          debugPrint('QR Result: $result');
        }
      },
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top icons (โปรไฟล์)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      final savedId = prefs.getString('userId');
                      final uid = (savedId != null && savedId.isNotEmpty)
                          ? savedId
                          : userId;

                      if (uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'ไม่พบข้อมูลผู้ใช้ กรุณาเข้าสู่ระบบใหม่',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfilePage(userId: uid, role: 'student'),
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      "assets/profile.svg",
                      width: 34,
                      height: 34,
                    ),
                  ),
                ],
              ),
            ),

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
                    'assets/logounimai.png',
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 80, color: AppColors.sub),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // หัวข้อเมนู
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
            const SizedBox(height: 12),

            // กล่องเมนู
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  kBottomNavigationBarHeight,
                ),
                child: Column(
                  children: [
                    // แถวบน
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
                                builder: (_) => const StudentCalendarLoader(),
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
                    const SizedBox(height: 16),

                    // แถวล่าง
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
                                    PendingApprovalsPage(approvals: const []),
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
                                builder: (_) => StudentCoursesPage(
                                  userId: userId, // ✅ ส่ง userId
                                ),
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
          ],
        ),
      ),
    );
  }
}
