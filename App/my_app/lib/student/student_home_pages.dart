import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:my_app/teacher/attendancehistory_page.dart';
import 'package:my_app/student/leave_upload_page.dart';
import 'package:my_app/student/student_calendar_page.dart';
import 'package:my_app/student/pending_approvals_page.dart';
import 'package:my_app/student/student_courses_page.dart';
import 'package:my_app/student/qr_scan_page.dart';
import 'package:my_app/pages/edit_profile_page.dart';

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
  const StudentHomePage({super.key});

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

    return Scaffold(
      backgroundColor: Colors.white,

      // ===== FAB =====
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(5),
        decoration: const BoxDecoration(
          color: AppColors.fabRing,
          shape: BoxShape.circle,
        ),
        child: SizedBox(
          width: 84,
          height: 84,
          child: FloatingActionButton(
            elevation: 2,
            backgroundColor: Colors.white,
            foregroundColor: AppColors.ink,
            shape: const CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QRScanPage()),
              );
            },
            child: SvgPicture.asset(
              'assets/scan.svg',
              width: 40,
              height: 40,
            ),
          ),
        ),
      ),

      // ===== Bottom Bar =====
      bottomNavigationBar: Container(
        height: 50,
        color: AppColors.fabRing,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () {},
              icon: SvgPicture.asset(
                "assets/home.svg",
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              splashRadius: 24,
            ),
            IconButton(
              onPressed: () {
                // TODO: logout
              },
              icon: SvgPicture.asset(
                "assets/logout.svg",
                width: 26,
                height: 26,
                colorFilter:
                    const ColorFilter.mode(Colors.black, BlendMode.srcIn),
              ),
              splashRadius: 24,
            ),
          ],
        ),
      ),

      // ===== Body =====
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset("assets/bell.svg", width: 22, height: 22),
                  InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const EditProfilePage()),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height * 0.28, // สูงสุด 28%
                    minHeight: 120,
                  ),
                  child: Image.asset(
                    'assets/unicheck.png',
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
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 80),
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
                                  builder: (_) => const StudentCalendarPage()),
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
                                  builder: (_) => const LeaveUploadPage()),
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
                                  builder: (_) => const PendingApprovalsPage()),
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
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const AttendanceHistoryPage()),
                            ),
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
                                  builder: (_) => const StudentCoursesPage()),
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

// ===== Component: เมนูแต่ละช่อง =====
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
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
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


// // ===== Component: เมนูแต่ละช่อง =====
// class MenuTitle extends StatelessWidget {
//   final String title;
//   final String svgPath;
//   final Color iconBg;
//   final Color iconColor;
//   final Color textColor;
//   final VoidCallback? onTap;

//   const MenuTitle({
//     super.key,
//     required this.title,
//     required this.svgPath,
//     required this.iconBg,
//     required this.iconColor,
//     required this.textColor,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 56,
//                 height: 56,
//                 decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(18),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.10),
//                       blurRadius: 6,
//                       spreadRadius: 0,
//                       offset: const Offset(0, 4),
//                     ),
//                   ],
//                 ),
//                 alignment: Alignment.center,
//                 child: SvgPicture.asset(
//                   svgPath,
//                   width: 28,
//                   height: 28,
//                   colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 11,
//                   height: 1.15,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
