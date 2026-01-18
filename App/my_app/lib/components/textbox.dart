import 'package:flutter/material.dart';
import 'package:my_app/models/subject.dart';

class TextBox extends StatelessWidget {
  // ใช้ได้ทั้ง subject และข้อความอิสระ
  final Subject? subject;
  final String? text;

  // ใช้กับหน้าอื่น ๆ (เช่น Pending Approvals)
  final String? title;        // หัวข้อหลัก (เช่น ชื่อวิชา)
  final String? subtitle;     // ข้อความรอง (เช่น วันที่)
  final String? code;         // รหัสวิชา (ถ้ามีให้แสดงแทน subject.code)
  final String? status;       // สถานะ (อนุมัติ / ไม่อนุมัติ / รออนุมัติ)
  final Color? statusColor;   // สีสถานะ

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
          color: Color(0x14000000),
          blurRadius: 6,
          spreadRadius: 2,
          offset: Offset(0, 3),
        ),
      ],
    );

    // ข้อความหลัก/รองที่เลือกแหล่งข้อมูลได้
    final displayMain = title ?? text ?? subject?.title ?? '-';
    final displaySub = subtitle ?? code ?? subject?.code;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20), // ให้โค้งเท่ากับกรอบ
          onTap: onTap,
          child: Container(
            padding: padding,
            decoration: box,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // เนื้อหาหลัก (ซ้าย)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // บรรทัดบน: ชื่อ/หัวข้อ (รองรับ 2 บรรทัด)
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
                      if (displaySub != null && displaySub.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        // บรรทัดล่าง: รอง (1 บรรทัด)
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

                // ส่วนขวา: สถานะ + ไอคอนท้าย (ถ้ามี)
                if (status != null) ...[
                  Text(
                    status!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: statusColor ?? const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                trailing ??
                    const Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: Color(0xFF9CA3AF),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
