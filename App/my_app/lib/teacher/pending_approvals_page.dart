import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/teacher/teacher_approval_detail_page.dart';

enum ApprovalStatus { approved, rejected, pending }

class ApprovalItem {
  final DateTime date;
  final String title;
  final ApprovalStatus status;

  const ApprovalItem({
    required this.date,
    required this.title,
    required this.status,
  });
}

class PendingApprovalsPage extends StatelessWidget {
  const PendingApprovalsPage({super.key});

  // โทนสีให้เหมือนภาพ
  static const _ink = Color(0xFF1F2937);
  static const _sub = Color(0xFF9CA3AF);
  static const _border = Color(0xFF9DBAF6); // ฟ้าอ่อนขอบการ์ด
  static const _green = Color(0xFF20A445);
  static const _red = Color(0xFFE53935);

  // --------- ดัมมี่ดาต้า ----------
  List<ApprovalItem> _items() => [
    ApprovalItem(
      date: DateTime(2025, 8, 1),
      title: 'DATA WAREHOUSE',
      status: ApprovalStatus.approved,
    ),
    ApprovalItem(
      date: DateTime(2025, 8, 1),
      title: 'DATA WAREHOUSE',
      status: ApprovalStatus.approved,
    ),
    ApprovalItem(
      date: DateTime(2025, 8, 1),
      title: 'DATA WAREHOUSE',
      status: ApprovalStatus.approved,
    ),
    ApprovalItem(
      date: DateTime(2025, 8, 1),
      title: 'DATA WAREHOUSE',
      status: ApprovalStatus.rejected,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return Scaffold(
      appBar: const CustomAppBar(title: 'เอกสารที่รออนุมัติ'),
      backgroundColor: Colors.white,
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemBuilder: (_, i) => _ApprovalCard(
          item: items[i],
          onTap: () {
            final details = <ApprovalDetail>[
              ApprovalDetail(
                date: items[i].date,
                subject: items[i].title,
                students: '65200128 ณนุช & 65200020 กวิสรา',
                leaveType: 'ลาหยุด',
                reason: 'อยากพักผ่อน',
                status: items[i].status,
              ),
              ApprovalDetail(
                date: items[i].date,
                subject: items[i].title,
                students: '65123456 ธนกร & 65112233 ณัฐวุฒิ',
                leaveType: 'ลากิจ',
                reason: 'ไปทำธุระครอบครัว',
                status: items[i].status,
              ),
              ApprovalDetail(
                date: items[i].date,
                subject: items[i].title,
                students: '65200999 ภูริ & 65200888 วัชระ',
                leaveType: 'ลาป่วย',
                reason: 'มีไข้',
                status: items[i].status,
              ),
              ApprovalDetail(
                date: items[i].date,
                subject: items[i].title,
                students: '65200001 ศุภชัย',
                leaveType: 'ลาหยุด',
                reason: 'ธุระส่วนตัว',
                status: items[i].status,
              ),
            ];
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    ApprovalDetailPage(detail: details[i % details.length]),
              ),
            );
          },
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 16),
        itemCount: items.length,
      ),
    );
  }

  // แปลงวันที่เป็นรูปแบบ `วันที่ 1/8/68` (พ.ศ. 2568 → 68)
  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ ${d.day}/${d.month}/$yy';
  }

  // แปลงสถานะ → ข้อความ+สี
  static (String, Color) statusLabel(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.approved:
        return ('อนุมัติ', _green);
      case ApprovalStatus.rejected:
        return ('ไม่อนุมัติ', _red);
      case ApprovalStatus.pending:
        return ('รอดำเนินการ', _sub);
    }
  }
}

class _ApprovalCard extends StatelessWidget {
  final ApprovalItem item;
  final VoidCallback? onTap;

  const _ApprovalCard({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final (label, color) = PendingApprovalsPage.statusLabel(item.status);

    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: PendingApprovalsPage._border, width: 1),
          ),
          child: Row(
            children: [
              // ซ้าย: วันที่ + ชื่อรายวิชา
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      PendingApprovalsPage.thShortDate(item.date),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: PendingApprovalsPage._ink,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PendingApprovalsPage._ink,
                      ),
                    ),
                  ],
                ),
              ),
              // ขวา: สถานะ + ลูกศร
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFFBDBDBD),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
