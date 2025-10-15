import 'package:flutter/material.dart';
import 'package:my_app/components/custom_appbar.dart';

/// ถ้าคุณมี enum/สีจากหน้าอื่นอยู่แล้ว ให้ลบบรรทัดนี้ทิ้งและ import ต้นฉบับแทนได้
enum ApprovalStatus { pending, approved, rejected }

class ApprovalDetail {
  final String id;            // ไอดีเอกสาร (ใช้เรียก API)
  final DateTime date;
  final String subject;       // ชื่อวิชา
  final String students;      // ข้อความรวม เช่น "65200128 ณนุช & 65200020 กวิสรา"
  final String leaveType;     // ประเภทการลา
  final String reason;        // หมายเหตุ
  final ApprovalStatus status;

  const ApprovalDetail({
    required this.id,
    required this.date,
    required this.subject,
    required this.students,
    required this.leaveType,
    required this.reason,
    this.status = ApprovalStatus.pending,
  });
}

/// หน้าแสดงรายละเอียด: ไม่ใช้ดัมมี่ แต่ "รอข้อมูล" จากฟังก์ชันโหลดที่ส่งมา
class ApprovalDetailPage extends StatefulWidget {
  /// ไอดีเอกสารที่ต้องการดูรายละเอียด
  final String approvalId;

  /// ฟังก์ชันโหลดรายละเอียดจาก backend (ต้องคืน ApprovalDetail)
  final Future<ApprovalDetail> Function(String id) loadDetail;

  /// ฟังก์ชันกดอนุมัติ/ไม่อนุมัติ (เลือกใส่)
  final Future<bool> Function(String id)? onApprove;
  final Future<bool> Function(String id)? onReject;

  const ApprovalDetailPage({
    super.key,
    required this.approvalId,
    required this.loadDetail,
    this.onApprove,
    this.onReject,
  });

  @override
  State<ApprovalDetailPage> createState() => _ApprovalDetailPageState();
}

class _ApprovalDetailPageState extends State<ApprovalDetailPage> {
  static const _ink = Color(0xFF1F2937);
  static const _sub = Color(0xFF9CA3AF);
  static const _green = Color(0xFF20A445);
  static const _red = Color(0xFFE53935);
  static const _border = Color(0xFF9DBAF6);

  late Future<ApprovalDetail> _future;
  bool _busyAction = false;

  @override
  void initState() {
    super.initState();
    _future = widget.loadDetail(widget.approvalId);
  }

  static String thShortDate(DateTime d) {
    final buddhistYear = d.year + 543;
    final yy = buddhistYear % 100;
    return 'วันที่ ${d.day}/${d.month}/$yy';
  }

  Future<void> _handleApprove(ApprovalDetail d) async {
    if (widget.onApprove == null) return;
    setState(() => _busyAction = true);
    try {
      final ok = await widget.onApprove!(d.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'อนุมัติสำเร็จ' : 'อนุมัติไม่สำเร็จ')),
      );
      if (ok) Navigator.pop(context, {'approved': true, 'id': d.id});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการอนุมัติ')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  Future<void> _handleReject(ApprovalDetail d) async {
    if (widget.onReject == null) return;
    setState(() => _busyAction = true);
    try {
      final ok = await widget.onReject!(d.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ok ? 'ไม่อนุมัติสำเร็จ' : 'ไม่อนุมัติไม่สำเร็จ')),
      );
      if (ok) Navigator.pop(context, {'rejected': true, 'id': d.id});
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('เกิดข้อผิดพลาดในการไม่อนุมัติ')),
      );
    } finally {
      if (mounted) setState(() => _busyAction = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'เอกสารที่รออนุมัติ'),
      backgroundColor: Colors.white,
      body: FutureBuilder<ApprovalDetail>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return _errorState(
              'โหลดข้อมูลไม่สำเร็จ',
              onRetry: () {
                setState(() {
                  _future = widget.loadDetail(widget.approvalId);
                });
              },
            );
          }
          final detail = snap.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            children: [
              Text(thShortDate(detail.date),
                  style: const TextStyle(fontSize: 16, color: _ink)),
              const SizedBox(height: 16),
              Text('วิชา : ${detail.subject}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: _ink,
                    fontWeight: FontWeight.w600,
                  )),
              const SizedBox(height: 28),

              // กล่องไอคอน PDF (คุณจะเปลี่ยนให้กดเปิดไฟล์จริงก็ได้)
              Center(
                child: Container(
                  width: 140,
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: _ink.withOpacity(.2)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.insert_drive_file_outlined,
                          size: 56, color: _ink),
                      SizedBox(height: 12),
                      Text(
                        'PDF',
                        style:
                            TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ปุ่ม อนุมัติ / ไม่อนุมัติ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pillButton(
                    text: 'อนุมัติ',
                    color: const Color.fromARGB(255, 104, 48, 146),
                    enabled: !_busyAction && widget.onApprove != null,
                    onTap: () => _handleApprove(detail),
                  ),
                  const SizedBox(width: 16),
                  _pillButton(
                    text: 'ไม่อนุมัติ',
                    color: _red,
                    enabled: !_busyAction && widget.onReject != null,
                    onTap: () => _handleReject(detail),
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Text(detail.students,
                  style: const TextStyle(fontSize: 16, color: _ink)),
              const SizedBox(height: 16),
              _kv('ประเภทการลา', detail.leaveType),
              const SizedBox(height: 10),
              _kv('หมายเหตุการลา', detail.reason),
            ],
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
          Text(msg, style: const TextStyle(color: _sub)),
          const SizedBox(height: 8),
          if (onRetry != null)
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('ลองใหม่'),
            ),
        ],
      ),
    );
  }

  static Widget _pillButton({
    required String text,
    required Color color,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black12.withOpacity(.04),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _kv(String k, String v) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$k :',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontSize: 15, color: _ink)),
        ],
      );
}
