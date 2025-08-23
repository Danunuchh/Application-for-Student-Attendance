import 'package:flutter/material.dart';
import '../widgets/logo_area.dart';
import '../widgets/menu_title.dart';

class AppColors {
  static const primary = Color(0xFF4A86E8); // น้ำเงินหลัก (ไอคอน)
  static const ink = Color(0xFF1F2937); // ตัวหนังสือเข้ม
  static const sub = Color(0xFF6B7280); // ตัวหนังสือรอง
  static const card = Color(0xFFE8F1FF); // พื้นหลังการ์ดไอคอน
  static const bar = Color(0xFFD9E7FF); // แถบล่างอ่อน (ตามภาพ)
  static const fabRing = Color(0xFFBFD6FF); // วงแหวนรอบปุ่มสแกน
}

class MenuItemData {
  final String title;
  final IconData icon;
  MenuItemData(this.title, this.icon);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <MenuItemData>[
      MenuItemData("ปฏิทิน", Icons.calendar_month_rounded),
      MenuItemData("สั่งลา/มาสาย", Icons.schedule_rounded),
      MenuItemData("เอกสารที่รอ\nการอนุมัติ", Icons.description_rounded),
      MenuItemData("ประวัติ\nการเข้าเรียน", Icons.manage_search_rounded),
      MenuItemData("สรุป\nผลรายงาน", Icons.stacked_bar_chart_rounded),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // FAB แบบวงแหวนตรงกลางล่าง
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
      // Bottom bar มีรอยบาก และพื้นหลังฟ้าอ่อน
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
              SizedBox(width: 48), // เว้นที่ให้ FAB
              _BarIcon(icon: Icons.campaign_rounded),
            ],
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar
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

            // โลโก้ตามภาพ
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Center(child: LogoArea()),
            ),

            const SizedBox(height: 12),

            // หัวข้อ "Menu"
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

            // กริดเมนู
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 100, top: 8),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, i) {
                    final d = items[i];
                    return MenuTitle(
                      title: d.title,
                      icon: d.icon,
                      // โทนสีให้ใกล้ภาพ
                      iconBg: AppColors.card,
                      iconColor: AppColors.primary,
                      textColor: AppColors.sub,
                    );
                  },
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
