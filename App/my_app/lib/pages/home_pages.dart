import 'package:flutter/material.dart';
import '../widgets/logo_area.dart';
import '../widgets/menu_title.dart';
import '../student/leave_upload_page.dart'; // 👈 import หน้าลา

class AppColors {
  static const primary = Color(0xFF4A86E8);
  static const ink = Color(0xFF1F2937);
  static const sub = Color(0xFF6B7280);
  static const card = Color(0xFFE8F1FF);
  static const bar = Color(0xFFD9E7FF);
  static const fabRing = Color(0xFFBFD6FF);
}

class MenuItemData {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  MenuItemData(this.title, this.icon, {this.onTap});
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <MenuItemData>[
      MenuItemData("ปฏิทิน", Icons.calendar_month_rounded),
      MenuItemData(
        "สั่งลา/มาสาย",
        Icons.schedule_rounded,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LeaveUploadPage()),
          );
        },
      ),
      MenuItemData("เอกสารที่รอ\nการอนุมัติ", Icons.description_rounded),
      MenuItemData("ประวัติ\nการเข้าเรียน", Icons.manage_search_rounded),
      MenuItemData("สรุป\nผลรายงาน", Icons.stacked_bar_chart_rounded),
    ];
    final topRow = items.sublist(0, 2);
    final bottomRow = items.sublist(2); // 3 รายการ

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.fabRing,
          shape: BoxShape.circle,
        ),
        child: FloatingActionButton.large(
          elevation: 2,
          backgroundColor: Colors.white,
          foregroundColor: AppColors.primary,
          shape: const CircleBorder(),
          onPressed: () {},
          child: const Icon(Icons.qr_code_2, size: 36),
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: 64,
        child: BottomAppBar(
          color: AppColors.bar,
          shape: const CircularNotchedRectangle(),
          notchMargin: 8,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _BarIcon(icon: Icons.home_rounded),
              SizedBox(width: 48),
              _BarIcon(icon: Icons.campaign_rounded),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // top icons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.amber,
                    size: 28,
                  ),
                  Icon(
                    Icons.account_circle_rounded,
                    color: Colors.black87,
                    size: 30,
                  ),
                ],
              ),
            ),

            // โลโก้เป็น "รูปภาพ"
            const Center(child: LogoArea()),

            const SizedBox(height: 16),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Menu",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // เมนู: แถวบน 2, แถวล่าง 3
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
                child: Column(
                  children: [
                    // แถวบน (2)
                    Row(
                      children: [
                        Expanded(
                          child: MenuTitle(
                            title: topRow[0].title,
                            icon: topRow[0].icon,
                            iconBg: AppColors.card,
                            iconColor: AppColors.primary,
                            textColor: AppColors.sub,
                            onTap: topRow[0].onTap, // 👈 เพิ่ม onTap
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: topRow[1].title,
                            icon: topRow[1].icon,
                            iconBg: AppColors.card,
                            iconColor: AppColors.primary,
                            textColor: AppColors.sub,
                            onTap:
                                topRow[1].onTap, // 👈 กดแล้วไป LeaveUploadPage
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // แถวล่าง (3)
                    Row(
                      children: [
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[0].title,
                            icon: bottomRow[0].icon,
                            iconBg: AppColors.card,
                            iconColor: AppColors.primary,
                            textColor: AppColors.sub,
                            onTap: bottomRow[0].onTap,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[1].title,
                            icon: bottomRow[1].icon,
                            iconBg: AppColors.card,
                            iconColor: AppColors.primary,
                            textColor: AppColors.sub,
                            onTap: bottomRow[1].onTap,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: MenuTitle(
                            title: bottomRow[2].title,
                            icon: bottomRow[2].icon,
                            iconBg: AppColors.card,
                            iconColor: AppColors.primary,
                            textColor: AppColors.sub,
                            onTap: bottomRow[2].onTap,
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
  final IconData icon;
  const _BarIcon({required this.icon});
  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {},
      icon: Icon(icon, size: 28, color: AppColors.ink),
      splashRadius: 24,
    );
  }
}
