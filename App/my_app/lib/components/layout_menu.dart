import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TwoRowMenuItem {
  final String title;
  final String svgPath;
  final VoidCallback onTap;

  TwoRowMenuItem({
    required this.title,
    required this.svgPath,
    required this.onTap,
  });
}

/// เมนู 2 แถว “ไม่เลื่อน” ย่อขนาดอัตโนมัติให้พอดีจอ
class TwoRowMenu extends StatelessWidget {
  /// รายการทั้งหมด (อย่างน้อย 3 ชิ้นขึ้นไปจะสวยสุดในเลย์เอาต์นี้)
  final List<TwoRowMenuItem> items;

  /// แบ่งคั่นรายการไปแถวบนกี่ชิ้น (เช่น 2 ชิ้นบน / ที่เหลือล่าง)
  final int splitAt;

  /// สีพื้นหลังกรอบไอคอน
  final Color iconBg;

  /// สีไอคอนและตัวอักษร
  final Color iconColor;
  final Color textColor;

  /// ระยะขอบนอกของคอมโพเนนต์
  final EdgeInsets outerPadding;

  /// กันชนด้านล่าง (กันไม่ให้ชน BottomBar/FAB)
  final double bottomGap;

  const TwoRowMenu({
    super.key,
    required this.items,
    this.splitAt = 2,
    this.iconBg = const Color(0xFFCDE0F9),
    this.iconColor = Colors.black,
    this.textColor = Colors.black,
    this.outerPadding = const EdgeInsets.fromLTRB(24, 8, 24, 60),
    this.bottomGap = 60,
  });

  @override
  Widget build(BuildContext context) {
    final top = items.take(splitAt).toList();
    final bottom = items.skip(splitAt).toList();

    return LayoutBuilder(
      builder: (context, c) {
        final h = c.maxHeight;         // พื้นที่ที่ได้รับจาก parent
        final isSmall = h < 700;       // เกณฑ์ย่อสำหรับจอเตี้ย

        // สเกลต่าง ๆ ให้พอดีทุกจอ (ไม่เลื่อน)
        final tilePadV = isSmall ? 10.0 : 14.0;
        final iconBox  = isSmall ? 52.0 : 56.0;
        final iconSize = isSmall ? 24.0 : 28.0;
        final textSize = isSmall ? 10.5 : 11.0;
        final vGapRows = isSmall ? 12.0 : 16.0;

        return Padding(
          padding: outerPadding.copyWith(
            bottom: bottomGap, // กันชนล่าง
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MenuRow(
                items: top,
                iconBg: iconBg,
                iconColor: iconColor,
                textColor: textColor,
                tilePadV: tilePadV,
                iconBox: iconBox,
                iconSize: iconSize,
                textSize: textSize,
              ),
              SizedBox(height: vGapRows),
              _MenuRow(
                items: bottom,
                iconBg: iconBg,
                iconColor: iconColor,
                textColor: textColor,
                tilePadV: tilePadV,
                iconBox: iconBox,
                iconSize: iconSize,
                textSize: textSize,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MenuRow extends StatelessWidget {
  final List<TwoRowMenuItem> items;
  final Color iconBg, iconColor, textColor;
  final double tilePadV, iconBox, iconSize, textSize;

  const _MenuRow({
    required this.items,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
    required this.tilePadV,
    required this.iconBox,
    required this.iconSize,
    required this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: _MenuTile(
              title: items[i].title,
              svgPath: items[i].svgPath,
              iconBg: iconBg,
              iconColor: iconColor,
              textColor: textColor,
              padV: tilePadV,
              box: iconBox,
              icon: iconSize,
              textSize: textSize,
              onTap: items[i].onTap,
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 16),
        ],
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final String title, svgPath;
  final Color iconBg, iconColor, textColor;
  final double padV, box, icon, textSize;
  final VoidCallback? onTap;

  const _MenuTile({
    required this.title,
    required this.svgPath,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
    required this.padV,
    required this.box,
    required this.icon,
    required this.textSize,
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
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: padV),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: box,
                height: box,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 6,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: SvgPicture.asset(
                  svgPath,
                  width: icon,
                  height: icon,
                  colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: textSize,
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
