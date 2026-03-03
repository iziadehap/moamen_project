// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:icons_plus/icons_plus.dart';
// import 'package:moamen_project/core/theme/app_colors.dart';

// class MapHeader extends StatelessWidget {
//   const MapHeader({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//           decoration: BoxDecoration(
//             color: AppColors.darkCard,
//             borderRadius: BorderRadius.circular(14),
//             border: Border.all(color: Colors.white.withOpacity(0.1)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.2),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             children: [
//               const Icon(HeroIcons.map, color: AppColors.primaryBlue, size: 18),
//               const SizedBox(width: 10),
//               Text(
//                 'خريطة التوصيل',
//                 style: GoogleFonts.cairo(
//                   color: Colors.white,
//                   fontSize: 16,
//                   fontWeight: FontWeight.w800,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
