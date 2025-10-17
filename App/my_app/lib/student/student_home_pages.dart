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

// ✅ ใช้หน้าแก้ไขโปรไฟล์เวอร์ชันนักศึกษา (ตามไฟล์/คลาสที่คุณมี)
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
  // 🔧 non-nullable และ required
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

    // ===== ใช้ CustomBottomBarWithFab ครอบ body ทั้งหมด =====
    return CustomBottomBarWithFab(
      role: 'student',
      onHome: () {
        // หน้า Home อยู่แล้ว — ไม่ต้องทำอะไร
      },
      onLogout: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginPage(),
          ), // หรือ SplashScreen()
          (route) => false, // 🔹 ปิดทุกหน้าเก่า ไม่ให้ย้อนกลับได้
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

      // ===== Body ด้านล่างคือเนื้อหาหน้าเดิมของคุณ =====
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top icons (โปรไฟล์)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () async {
                      // ดึงจาก SharedPreferences ถ้าไม่มีจะ fallback เป็น userId ที่ได้จาก constructor
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

            // 🔹 โลโก้
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
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.image, size: 80, color: AppColors.sub),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // 🔹 หัวข้อเมนู
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

            // 🔹 กล่องเมนู
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  kBottomNavigationBarHeight /*≈56*/ + 0, // รวมเผื่อ FAB
                ),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceEvenly, // ✅ กระจายพื้นที่เท่ากัน
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
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const StudentCalendarLoader(), // โหลดปฏิทินจาก API
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
                                builder: (_) => PendingApprovalsPage(
                                  approvals:
                                      const [], // ใส่รายการจริงได้ภายหลัง
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
                            onTap: () {
                              final List<Map<String, String>> myCourses =
                                  []; // โหลดจาก backend ได้
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      AttendanceHistoryPage(courses: myCourses),
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
                                builder: (_) => const StudentCoursesPage(),
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
