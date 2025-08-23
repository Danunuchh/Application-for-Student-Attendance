import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
      ), // ✅ รองรับ ripple ตามมุม
      clipBehavior: Clip.antiAlias, // ✅ ตัด ripple ตามรัศมี
      elevation: 0,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap, // ✅ ใช้ callback ที่ส่งเข้ามา
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ไอคอนในกล่องโค้งมนสีฟ้าอ่อน
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  svgPath, 
                  height: 20,
                  color: iconColor,
                ),
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
