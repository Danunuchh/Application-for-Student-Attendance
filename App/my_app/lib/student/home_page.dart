// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// // import '../widgets/menu_title.dart';
// import '../student/leave_upload_page.dart'; 

// class AppColors {
//   static const primary = Color(0xFF4A86E8);
//   static const ink = Color(0xFF1F2937);
//   static const sub = Color.fromARGB(255, 196, 199, 208);
//   static const card = Color.fromARGB(255, 148, 171, 208);
//   static const bar = Color(0xFFA6CAFA);
//   static const fabRing = Color(0xFFA6CAFA);
// }

// class MenuItemData {
//   final String title;
//   final String svgPath; // ใช้ไฟล์ SVG แทน IconData
//   MenuItemData(this.title, this.svgPath);
// }

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final items = <MenuItemData>[
//       MenuItemData("ปฏิทิน", "assets/calendar.svg"),
//       MenuItemData("ส่งใบลา/มาสาย", "assets/file.svg"),
//       MenuItemData("เอกสารที่รอ\nการอนุมัติ", "assets/data-processing.svg"),
//       MenuItemData("ประวัติ\nการเข้าเรียน", "assets/history.svg"),
//       MenuItemData("สรุป\nผลรายงาน", "assets/dashboard.svg"),
//     ];
//     final topRow = items.sublist(0, 2);
//     final bottomRow = items.sublist(2);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
//       floatingActionButton: Container(
//         padding: const EdgeInsets.all(6), //กรอบวงกลม qr code 
//         decoration: const BoxDecoration(
//           color: AppColors.fabRing,
//           shape: BoxShape.circle,
//         ),
//         child: FloatingActionButton.large(
//           elevation: 2,
//           backgroundColor: Colors.white,
//           foregroundColor: const Color(0xFF4A86E8),
//           shape: const CircleBorder(),
//           onPressed: () {},
//           child: SvgPicture.asset(
//             "assets/qr-code.svg",
//             width: 36,
//             height: 36,
//             color: AppColors.primary,
//           ),
//         ),
//       ),
//       bottomNavigationBar: SizedBox(
//         height: 60,
//         child: BottomAppBar(
//           color: const Color(0xFFA6CAFA),
//           shape: const CircularNotchedRectangle(),
//           notchMargin: 4,
//           padding: const EdgeInsets.symmetric(horizontal: 24),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _BarIcon(svgPath: "assets/home.svg"),
//               const SizedBox(width: 48),
//               _BarIcon(svgPath: "assets/logout.svg"),
//             ],
//           ),
//         ),
//       ),
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top icons
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   SvgPicture.asset(
//                     "assets/bell.svg",
//                     width: 28,
//                     height: 28,
//                   ),
//                   SvgPicture.asset(
//                     "assets/profiles.svg",
//                     width: 30,
//                     height: 30,
//                   ),
//                 ],
//               ),
//             ),
//             // unicheck
//             Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
//               child: Center(
//                 child: Image.asset(
//                   'assets/unicheck.png',
//                   height: 240,
//                   fit: BoxFit.contain,
//                   errorBuilder: (_, __, ___) =>
//                       const Icon(Icons.image, size: 80, color: AppColors.sub),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 10),

//             const Padding(
//               padding: EdgeInsets.symmetric(horizontal: 26),
//               child: Text(
//                 "Menu",
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF000000),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),

//             // เมนู: แถวบน 2, แถวล่าง 3
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.fromLTRB(24, 8, 24, 120), //ระยะห่างระหว่างเมนู
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         Expanded( //ปฏิทิน
//                           child: MenuTitle(
//                             title: topRow[0].title,
//                             svgPath: topRow[0].svgPath,
//                             iconBg: const Color(0xFFCDE0F9),
//                             iconColor: const Color(0xFF4A86E8),
//                             textColor: const Color.fromARGB(255, 0, 0, 0),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded( //ส่งใบลา
//                           child: MenuTitle(
//                             title: topRow[1].title,
//                             svgPath: topRow[1].svgPath,
//                             iconBg: const Color(0xFFCDE0F9),
//                             iconColor: const Color(0xFF4A86E8),
//                             textColor: const Color(0xFF000000),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         Expanded(  //เอกสารที่รออนุมัติ
//                           child: MenuTitle(
//                             title: bottomRow[0].title,
//                             svgPath: topRow[1].svgPath,
//                             iconBg: const Color(0xFFCDE0F9),
//                             iconColor: const Color(0xFF4A86E8),
//                             textColor: const Color(0xFF000000),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded( //ประวัติการเข้าเรียน
//                           child: MenuTitle(
//                             title: bottomRow[1].title,
//                             svgPath: topRow[1].svgPath,
//                             iconBg: const Color(0xFFCDE0F9),
//                             iconColor: const Color(0xFF4A86E8),
//                             textColor: const Color(0xFF000000),
//                           ),
//                         ),
//                         const SizedBox(width: 16),
//                         Expanded( //สรุปรายงาน
//                           child: MenuTitle(
//                             title: bottomRow[2].title,
//                             svgPath: topRow[1].svgPath,
//                             iconBg: const Color(0xFFCDE0F9),
//                             iconColor: const Color(0xFF4A86E8),
//                             textColor: const Color(0xFF000000),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Widget สำหรับ icon bar
// class _BarIcon extends StatelessWidget {
//   final String svgPath;
//   const _BarIcon({required this.svgPath});

//   @override
//   Widget build(BuildContext context) {
//     return IconButton(
//       onPressed: () {},
//       icon: SvgPicture.asset(
//         svgPath,
//         width: 28,
//         height: 28,
//         color: AppColors.ink,
//       ),
//       splashRadius: 24,
//     );
//   }
// }

// // Widget MenuTitle ปรับใหม่ให้รองรับ SVG
// class MenuTitle extends StatelessWidget {
//   final String title;
//   final String svgPath;
//   final Color iconBg;
//   final Color iconColor;
//   final Color textColor;

//   const MenuTitle({
//     super.key,
//     required this.title,
//     required this.svgPath,
//     required this.iconBg,
//     required this.iconColor,
//     required this.textColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: () {},
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Container(
//                 width: 72,
//                 height: 72,
//                 decoration: BoxDecoration(
//                   color: iconBg,
//                   borderRadius: BorderRadius.circular(18),
//                 ),
//                 alignment: Alignment.center,
//                 child: SvgPicture.asset(
//                   svgPath,
//                   width: 36,
//                   height: 36,
//                   color: iconColor,
//                 ),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 title,
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   color: textColor,
//                   fontSize: 14.5,
//                   height: 1.15,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

