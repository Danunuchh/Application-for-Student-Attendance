import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;                 // ถ้าไม่ส่ง จะเช็ค canPop() แล้วใส่ Back ให้อัตโนมัติ
  final VoidCallback? onBack;            // ถ้าต้องการ override พฤติกรรมปุ่ม Back
  final List<Widget>? actions;           // ปุ่มฝั่งขวา
  final Color backgroundColor;
  final Color textColor;
  final bool centerTitle;
  final double elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.leading,
    this.onBack,
    this.actions,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.centerTitle = true,
    this.elevation = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      // ถ้าไม่ได้ส่ง leading มา และหน้านี้ย้อนกลับได้ → ใส่ปุ่ม Back ให้อัตโนมัติ
      leading: leading ?? (canPop
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : null),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: centerTitle,
      elevation: elevation,
      backgroundColor: backgroundColor,
      surfaceTintColor: Colors.transparent, // ✅ ปิดเงาสีม่วงอ่อนของ Material 3
      scrolledUnderElevation: 0, 
      actions: actions,
      iconTheme: IconThemeData(color: textColor),
      // ปรับสีไอคอน Status Bar ให้เข้ากับพื้นหลัง
      systemOverlayStyle: backgroundColor.computeLuminance() > 0.5
          ? SystemUiOverlayStyle.dark   // พื้นหลังสว่าง → ไอคอนดำ
          : SystemUiOverlayStyle.light, // พื้นหลังเข้ม → ไอคอนขาว
    );
  }
}
