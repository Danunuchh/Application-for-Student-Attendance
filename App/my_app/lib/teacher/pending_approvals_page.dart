import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';
import 'package:my_app/components/textbox.dart';
import 'package:my_app/teacher/teacher_approval_detail_page.dart';

enum ApprovalStatus { approved, rejected, pending }

/// ไอเท็มในลิสต์หน้า Pending (ต้องมี id เพื่อเปิดรายละเอียด)
class ApprovalItem {
  final String id;           // ไอดีเอกสาร
  final DateTime date;
  final String title;        // ชื่อวิชา/หัวข้อ
  final ApprovalStatus status;

  const ApprovalItem({
    required this.id,
    required this.date,
    required this.title,
    required this.status,
  });

  // ✅ แปลง JSON → ApprovalItem (รองรับหลายฟอร์แมต)
  factory ApprovalItem.fromJson(Map<String, dynamic> json) {
    // แปลง status string → enum
    ApprovalStatus parseStatus(dynamic raw) {
      final s = (raw ?? '').toString().toLowerCase().trim();
      switch (s) {
        case 'approved':
        case 'อนุมัติ':
          return ApprovalStatus.approved;
        case 'rejected':
        case 'ไม่อนุมัติ':
          return ApprovalStatus.rejected;
        default:
          return ApprovalStatus.pending;
      }
    }

    // แปลง date (รองรับ ISO string หรือ milliseconds)
    DateTime parseDate(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is int) {
        // สมมติเป็น millisecondsSinceEpoch
        return DateTime.fromMillisecondsSinceEpoch(raw);
      }
      final s = raw.toString();
      return DateTime.tryParse(s) ?? DateTime.now();
    }

    return ApprovalItem(
      id: json['id']?.toString() ?? '',
      date: parseDate(json['date']),
      title: json['title']?.toString() ?? '-',
      status: parseStatus(json['status']),
    );
  }

  // (เผื่อส่งกลับไป server)
  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'title': title,
        'status': status.name, // 'approved' | 'rejected' | 'pending'
      };
}

class PendingApprovalsPage extends StatefulWidget {
  const PendingApprovalsPage({
    super.key,
    required this.userId,
    required this.loadList,     // โหลดลิสต์จาก backend
    required this.loadDetail,   // โหลดรายละเอียดจาก backend
    this.onApprove,             // อนุมัติ
    this.onReject,              // ไม่อนุมัติ
  });

  final String userId;

  /// คืนรายการที่ต้องแสดงบนลิสต์
  final Future<List<ApprovalItem>> Function(String userId) loadList;

  /// คืนรายละเอียดสำหรับหน้า Detail
  final Future<ApprovalDetail> Function(String approvalId) loadDetail;

  final Future<bool> Function(String approvalId)? onApprove;
  final Future<bool> Function(String approvalId)? onReject;

  @override
  State<PendingApprovalsPage> createState() => _PendingApprovalsPageState();

  // โทนสี
  static const _ink = Color(0xFF1F2937);
  static const _sub = Color(0xFF9CA3AF);

  // วันที่ไทยสั้น
  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ ${d.day}/${d.month}/$yy';
  }

  // label + สีของสถานะ (ใช้กับ TextBox.status)
  static (String, Color) statusLabel(ApprovalStatus s) {
    switch (s) {
      case ApprovalStatus.approved:
        return ('อนุมัติ', const Color(0xFF20A445));
      case ApprovalStatus.rejected:
        return ('ไม่อนุมัติ', const Color(0xFFE53935));
      case ApprovalStatus.pending:
        return ('รอดำเนินการ', _sub);
    }
  }
}

class _PendingApprovalsPageState extends State<PendingApprovalsPage> {
  late Future<List<ApprovalItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadList(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = widget.loadList(widget.userId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'เอกสารที่รออนุมัติ'),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<ApprovalItem>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _errorState('โหลดข้อมูลไม่สำเร็จ', onRetry: _refresh);
          }

          final items = snap.data ?? const <ApprovalItem>[];
          if (items.isEmpty) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Center(
                    child: Text(
                      'ยังไม่มีเอกสาร',
                      style: TextStyle(color: PendingApprovalsPage._sub),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final it = items[i];
                final (label, color) =
                    PendingApprovalsPage.statusLabel(it.status);

                return TextBox(
                  title: it.title,                                      // ชื่อวิชา/หัวข้อ
                  subtitle: PendingApprovalsPage.thShortDate(it.date),  // วันที่ไทยสั้น
                  status: label,                                        // สถานะ
                  statusColor: color,
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 22,
                    color: Color(0xFF9CA3AF),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ApprovalDetailPage(
                          approvalId: it.id,
                          loadDetail: widget.loadDetail,
                          onApprove: widget.onApprove,
                          onReject: widget.onReject,
                        ),
                      ),
                    ).then((res) {
                      // อัปเดตรายการเมื่อกลับจากหน้ารายละเอียด (ถ้ามีการเปลี่ยนสถานะ)
                      if (res is Map &&
                          (res['approved'] == true || res['rejected'] == true)) {
                        _refresh();
                      }
                    });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(String msg, {VoidCallback? onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(msg, style: const TextStyle(color: PendingApprovalsPage._sub)),
          const SizedBox(height: 8),
          if (onRetry != null)
            OutlinedButton(onPressed: onRetry, child: const Text('ลองใหม่')),
        ],
      ),
    );
  }
}
