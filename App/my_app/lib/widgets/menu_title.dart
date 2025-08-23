import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuTitle extends StatelessWidget {
  final String title;
  final String svgPath;
  final Color iconBg;
  final Color iconColor;
  final Color textColor;

  const MenuTitle({
    super.key,
    required this.title,
    required this.svgPath,
    required this.iconBg,
    required this.iconColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14.5,
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
