import 'package:flutter/material.dart';
import 'package:my_app/models/subject.dart';

class TextBox extends StatelessWidget {
  // ใช้ได้ทั้ง subject และข้อความอิสระ
  final Subject? subject;
  final String? text;

  // ใช้กับหน้าอื่น ๆ
  final String? title; // หัวข้อหลัก
  final String? subtitle; // subtitle แบบข้อความ (เดิม)
  final Widget? subtitleWidget; // ✅ subtitle แบบ Widget (ใหม่)
  final String? code;
  final String? status;
  final Color? statusColor;

  final VoidCallback? onTap;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final bool showBorder;

  const TextBox({
    super.key,
    this.subject,
    this.text,
    this.title,
    this.subtitle,
    this.subtitleWidget, // ✅ เพิ่ม
    this.code,
    this.status,
    this.statusColor,
    this.onTap,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final box = BoxDecoration(
      color: Colors.white,
      border: showBorder
          ? Border.all(color: const Color(0xFF84A9EA), width: 1.5)
          : null,
      borderRadius: BorderRadius.circular(20),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1F000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );

    // ---------- แหล่งข้อมูลข้อความ ----------
    final displayMain = title ?? text ?? subject?.title ?? '-';
    final displaySub = subtitle ?? code ?? subject?.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: box,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ---------- ฝั่งซ้าย ----------
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ชื่อ / หัวข้อ
                      Text(
                        displayMain,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                          height: 1.25,
                        ),
                      ),

                      // ---------- subtitle ----------
                      if (subtitleWidget != null) ...[
                        const SizedBox(height: 6),
                        subtitleWidget!,
                      ] else if (displaySub != null &&
                          displaySub.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          displaySub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ---------- ฝั่งขวา ----------
                if (status != null) ...[
                  Text(
                    status!,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor ?? const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                Center(
                  child:
                      trailing ??
                      const Icon(
                        Icons.chevron_right,
                        size: 22,
                        color: Color(0xFF9CA3AF),
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
