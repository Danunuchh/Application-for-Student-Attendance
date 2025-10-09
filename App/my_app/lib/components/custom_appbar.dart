import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;          // ปุ่มฝั่งซ้าย เช่น Back
  final List<Widget>? actions;    // ปุ่มฝั่งขวา เช่น Search, Setting
  final Color backgroundColor;
  final Color textColor;
  final bool centerTitle;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.leading,
    this.actions,
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
    this.centerTitle = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Text(
        title,
        style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w500),
      ),
      centerTitle: centerTitle,
      elevation: 0,
      backgroundColor: backgroundColor,
      actions: actions,
      iconTheme: IconThemeData(color: textColor),
    );
  }
}
