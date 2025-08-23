import 'package:flutter/material.dart';

class MenuTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;

  const MenuTitle({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ไอคอนในกล่องโค้งมนสีฟ้าอ่อน
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 36, color: iconColor),
              ),
              const SizedBox(height: 10),
              // ชื่อเมนู 1-2 บรรทัด ตรงกลาง
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
                  height: 1.2,
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
