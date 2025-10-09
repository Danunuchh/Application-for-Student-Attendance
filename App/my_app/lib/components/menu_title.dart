// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';

// class MenuTitle extends StatelessWidget {
//   final String title;
//   final String svgPath;
//   final Color iconBg;
//   final Color iconColor;
//   final Color textColor;
//   final VoidCallback? onTap;

//   const MenuTitle({
//     super.key,
//     required this.title,
//     required this.svgPath,
//     required this.iconBg,
//     required this.iconColor,
//     required this.textColor,
//     this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(16),
//         onTap: onTap,
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
//                   colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
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
