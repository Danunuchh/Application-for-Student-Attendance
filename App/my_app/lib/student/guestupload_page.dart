// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import 'package:http/http.dart' as http;
// // ถ้าอยากระบุ contentType ตามนามสกุลไฟล์ ค่อยเพิ่ม http_parser ทีหลังได้

// class GuestUploadPage extends StatefulWidget {
//   const GuestUploadPage({super.key});

//   @override
//   State<GuestUploadPage> createState() => _GuestUploadPageState();
// }

// class _GuestUploadPageState extends State<GuestUploadPage> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameCtrl = TextEditingController();
//   final _noteCtrl = TextEditingController();

//   String? _leaveType;
//   PlatformFile? _picked;
//   bool _submitting = false;

//   final _leaveTypes = const ['ลาป่วย', 'ลากิจ'];

//   // เปลี่ยนเป็น API ของคุณภายหลังได้
//   static const _testEndpoint = 'https://httpbin.org/post';

//   @override
//   void dispose() {
//     _nameCtrl.dispose();
//     _noteCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _pickLeaveType() async {
//     final picked = await showModalBottomSheet<String>(
//       context: context,
//       showDragHandle: true,
//       builder: (ctx) => SafeArea(
//         child: ListView.separated(
//           shrinkWrap: true,
//           itemCount: _leaveTypes.length,
//           separatorBuilder: (_, __) => const Divider(height: 1),
//           itemBuilder: (ctx, i) => ListTile(
//             title: Text(_leaveTypes[i]),
//             onTap: () => Navigator.pop(ctx, _leaveTypes[i]),
//           ),
//         ),
//       ),
//     );
//     if (picked != null) setState(() => _leaveType = picked);
//   }

//   Future<void> _pickFile() async {
//     final res = await FilePicker.platform.pickFiles(
//       allowMultiple: false,
//       withReadStream: true,
//       type: FileType.custom,
//       allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
//     );
//     if (res != null && res.files.isNotEmpty) {
//       final f = res.files.first;

//       // จำกัดขนาดไฟล์ 20MB
//       const maxBytes = 20 * 1024 * 1024;
//       if (f.size > maxBytes) {
//         if (!mounted) return;
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('ไฟล์ใหญ่เกินไป (จำกัด 20MB)')),
//         );
//         return;
//       }

//       setState(() => _picked = f);
//     }
//   }

//   Future<void> _submit() async {
//     if (_leaveType == null) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('กรุณาเลือกประเภทการลา')));
//       return;
//     }
//     if (_picked == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('กรุณาแนบไฟล์อย่างน้อย 1 ไฟล์')),
//       );
//       return;
//     }
//     if (!(_formKey.currentState?.validate() ?? false)) return;

//     setState(() => _submitting = true);
//     try {
//       final uri = Uri.parse(_testEndpoint); // เปลี่ยนเป็นของคุณภายหลัง

//       final req = http.MultipartRequest('POST', uri)
//         ..fields['name'] = _nameCtrl.text.trim()
//         ..fields['leaveType'] = _leaveType!
//         ..fields['note'] = _noteCtrl.text.trim();

//       req.files.add(
//         http.MultipartFile(
//           'file',
//           _picked!.readStream!,
//           _picked!.size,
//           filename: _picked!.name,
//         ),
//       );

//       final resp = await req.send();
//       final body = await resp.stream.bytesToString();

//       if (!mounted) return;

//       if (resp.statusCode >= 200 && resp.statusCode < 300) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('ส่งคำขอสำเร็จ')));
//         setState(() {
//           _picked = null;
//           _leaveType = null;
//           _noteCtrl.clear();
//           _nameCtrl.clear();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('อัปโหลดไม่สำเร็จ: ${resp.statusCode} • $body'),
//           ),
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
//     } finally {
//       if (mounted) setState(() => _submitting = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: const Text('แบบฟอร์มลา (ผู้เยี่ยมชม)'),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Form(
//           key: _formKey,
//           child: ListView(
//             padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
//             children: [
//               // ชื่อผู้ส่ง
//               Text(
//                 'ชื่อ-สกุล',
//                 style: TextStyle(
//                   fontSize: 16,
//                   color: cs.onSurface,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _nameCtrl,
//                 decoration: InputDecoration(
//                   hintText: 'เช่น สมชาย ใจดี',
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 14,
//                   ),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                   ),
//                 ),
//                 validator: (v) =>
//                     (v ?? '').trim().isEmpty ? 'โปรดกรอกชื่อ-สกุล' : null,
//               ),

//               const SizedBox(height: 18),

//               // โซนแนบไฟล์
//               GestureDetector(
//                 onTap: _pickFile,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(vertical: 28),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(18),
//                     border: Border.all(color: cs.outlineVariant),
//                   ),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Icon(
//                             Icons.insert_drive_file_outlined,
//                             size: 64,
//                             color: cs.onSurfaceVariant,
//                           ),
//                           Positioned(
//                             bottom: 2,
//                             right: 120,
//                             child: Icon(
//                               Icons.download_rounded,
//                               size: 28,
//                               color: cs.onSurfaceVariant,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 10),
//                       Text(
//                         _picked == null ? 'แนบไฟล์ที่นี่' : 'เลือกแล้ว:',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       if (_picked != null) ...[
//                         const SizedBox(height: 8),
//                         Text(
//                           _picked!.name,
//                           style: TextStyle(color: cs.primary),
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 22),

//               // ประเภทการลา
//               InkWell(
//                 onTap: _pickLeaveType,
//                 borderRadius: BorderRadius.circular(14),
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 16,
//                     vertical: 18,
//                   ),
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(14),
//                     border: Border.all(
//                       color: cs.primary.withOpacity(0.35),
//                       width: 1,
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           _leaveType ?? 'ประเภทการลา',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: _leaveType == null
//                                 ? cs.onSurfaceVariant
//                                 : cs.onSurface,
//                           ),
//                         ),
//                       ),
//                       Icon(
//                         Icons.chevron_right_rounded,
//                         color: cs.onSurfaceVariant,
//                       ),
//                     ],
//                   ),
//                 ),
//               ),

//               const SizedBox(height: 28),

//               // หมายเหตุ
//               Text(
//                 'หมายเหตุ',
//                 style: TextStyle(
//                   fontSize: 18,
//                   color: cs.onSurface,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               const SizedBox(height: 8),
//               TextFormField(
//                 controller: _noteCtrl,
//                 minLines: 4,
//                 maxLines: 6,
//                 decoration: InputDecoration(
//                   hintText: 'ระบุรายละเอียดเพิ่มเติม...',
//                   contentPadding: const EdgeInsets.symmetric(
//                     horizontal: 14,
//                     vertical: 14,
//                   ),
//                   enabledBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide(color: cs.primary.withOpacity(0.35)),
//                   ),
//                   focusedBorder: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(14),
//                     borderSide: BorderSide(color: cs.primary, width: 1.2),
//                   ),
//                 ),
//                 validator: (v) =>
//                     (v ?? '').trim().isEmpty ? 'โปรดกรอกหมายเหตุ' : null,
//               ),

//               const SizedBox(height: 28),

//               Align(
//                 alignment: Alignment.centerRight,
//                 child: FilledButton(
//                   style: FilledButton.styleFrom(
//                     backgroundColor: Colors.green.shade600,
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 24,
//                       vertical: 14,
//                     ),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   onPressed: _submitting ? null : _submit,
//                   child: _submitting
//                       ? const SizedBox(
//                           width: 18,
//                           height: 18,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Text('ยืนยัน', style: TextStyle(fontSize: 16)),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),

//       bottomNavigationBar: _BottomNavBar(
//         onHome: () {},
//         onScan: () {},
//         onLogout: () {},
//       ),
//     );
//   }
// }

// class _BottomNavBar extends StatelessWidget {
//   const _BottomNavBar({
//     required this.onHome,
//     required this.onScan,
//     required this.onLogout,
//   });

//   final VoidCallback onHome;
//   final VoidCallback onScan;
//   final VoidCallback onLogout;

//   @override
//   Widget build(BuildContext context) {
//     final cs = Theme.of(context).colorScheme;

//     return Container(
//       padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
//       decoration: BoxDecoration(
//         color: cs.primary.withOpacity(0.12),
//         border: Border(top: BorderSide(color: cs.outlineVariant)),
//       ),
//       child: Row(
//         children: [
//           _NavIconButton(icon: Icons.home_outlined, onTap: onHome),
//           Expanded(
//             child: Center(
//               child: GestureDetector(
//                 onTap: onScan,
//                 child: Container(
//                   width: 92,
//                   height: 92,
//                   decoration: BoxDecoration(
//                     color: cs.surface,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.08),
//                         blurRadius: 12,
//                         offset: const Offset(0, 6),
//                       ),
//                     ],
//                     border: Border.all(color: cs.outlineVariant),
//                   ),
//                   child: const Center(
//                     child: Icon(Icons.qr_code_rounded, size: 40),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           _NavIconButton(icon: Icons.logout_rounded, onTap: onLogout),
//         ],
//       ),
//     );
//   }
// }

// class _NavIconButton extends StatelessWidget {
//   const _NavIconButton({required this.icon, required this.onTap});

//   final IconData icon;
//   final VoidCallback onTap;

//   @override
//   Widget build(BuildContext context) {
//     return InkResponse(
//       onTap: onTap,
//       radius: 28,
//       child: SizedBox(
//         width: 56,
//         height: 44,
//         child: Icon(icon, size: 28), // ใช้ icon ที่ส่งเข้ามาจริง
//       ),
//     );
//   }
// }
