import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:my_app/components/custom_bar.dart';
import 'package:my_app/pages/login_page.dart';
import 'package:my_app/components/menu_title.dart';
import 'package:my_app/teacher/teacher_attendancehistory_page.dart';
import 'package:my_app/teacher/calendar_page.dart';
import 'package:my_app/teacher/courses_page.dart';
import 'package:my_app/teacher/dashboard_page.dart';
import 'package:my_app/pages/edit_profile_page.dart';
import 'package:my_app/teacher/pending_approvals_page.dart';
import 'package:my_app/teacher/qr_code_page.dart';

import 'package:my_app/config.dart';

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

class TeacherHomePage extends StatelessWidget {
  final String userId; // ✅ รหัสอาจารย์ที่ล็อกอินอยู่
  const TeacherHomePage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final items = <MenuItemData>[
      MenuItemData("คลาสเรียน", "assets/bookplus.svg"),
      MenuItemData("ปฏิทิน", "assets/calendar.svg"),
      MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/document.svg"),
      MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
      MenuItemData("สรุป\nผลรายงาน", "assets/piechart.svg"),
    ];
    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2);

    return CustomBottomBarWithFab(
      role: 'teacher',
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
          MaterialPageRoute(builder: (_) => QrCodePage(userId: userId)),
        );
        if (result != null) {
          debugPrint('QR Result: $result');
        }
      },

      // ===== Body =====
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              EditProfilePage(userId: userId, role: 'teacher'),
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
                    'assets/logounimai.png',
                    height: 230,
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

            // 🔹 เมนูกริด
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  8,
                  24,
                  kBottomNavigationBarHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                                builder: (_) => CoursesPage(userId: userId),
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
                                builder: (_) => CalendarPage(userId: userId),
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
                        // ✅ เอกสารรออนุมัติ
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
                                  userId: userId,
                                  loadList: (uid) async {
                                    final res = await http.get(
                                      Uri.parse(
                                        '$baseUrl/get_pending.php?teacher_id=$uid',
                                      ),
                                    );
                                    final data =
                                        jsonDecode(res.body) as List<dynamic>;
                                    return data
                                        .map((e) => ApprovalItem.fromJson(e))
                                        .toList();
                                  },
                                  loadDetail: (reqId) async {
                                    final res = await http.get(
                                      Uri.parse(
                                        '${baseUrl}get_pending_detail.php?id=$reqId',
                                      ),
                                    );
                                    return jsonDecode(res.body);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ✅ ประวัติการเข้าเรียน
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[1].title,
                            svgPath: bottomRow[1].svgPath,
                            iconBg: const Color(0xFFCDE0F9),
                            iconColor: Colors.black,
                            textColor: Colors.black,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AttendanceHistoryPage(userId: userId),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // ✅ แดชบอร์ด — ดึงข้อมูลจริงจาก API
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
                                builder: (_) => DashboardPage(
                                  userId: userId,
                                  loadCourses: (id) async {
                                    final res = await http.get(
                                      Uri.parse(
                                        'https://192.168.0.111:8000/api/get_courses.php?teacher_id=$id',
                                      ),
                                    );
                                    final data =
                                        jsonDecode(res.body) as List<dynamic>;
                                    return data
                                        .map(
                                          (e) => CourseOption(
                                            id: e['course_id'].toString(),
                                            name: e['course_name'].toString(),
                                          ),
                                        )
                                        .toList();
                                  },
                                  loadDashboard:
                                      ({
                                        required userId,
                                        required courseId,
                                        required range,
                                      }) async {
                                        final res = await http.get(
                                          Uri.parse(
                                            'https://192.168.0.111:8000/api/get_dashboard.php?teacher_id=$userId&course_id=$courseId&range=$range',
                                          ),
                                        );
                                        final json =
                                            jsonDecode(res.body)
                                                as Map<String, dynamic>;
                                        return DashboardData.fromJson(json);
                                      },
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
