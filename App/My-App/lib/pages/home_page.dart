import 'package:flutter/material.dart';
import '../widgets/logo_area.dart';
import '../widgets/menu_tile.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {},
        child: const Icon(Icons.qr_code_2, size: 36),
      ),
      bottomNavigationBar: BottomAppBar(
        height: 64,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.home_rounded)),
            const SizedBox(width: 48),
            IconButton(onPressed: () {}, icon: const Icon(Icons.campaign_rounded)),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.notifications_none_rounded, color: Colors.amber, size: 28),
                  Icon(Icons.account_circle_rounded, color: Colors.black87, size: 30),
                ],
              ),
            ),
            // Logo
            const LogoArea(),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.only(left: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Menu", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
            // Menu Grid
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 100),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, i) => MenuTile(data: items[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
