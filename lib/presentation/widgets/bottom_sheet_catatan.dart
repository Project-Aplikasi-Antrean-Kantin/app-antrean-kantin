// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:testgetdata/core/theme/colors_theme.dart';
// import 'package:testgetdata/core/theme/text_theme.dart';

// Future bottomSheetCatatan(BuildContext context, String catatan, String title) {
//   TextEditingController _textEditingController =
//       TextEditingController(text: catatan);

//   return showModalBottomSheet(
//     backgroundColor: AppColors.backgroundColor,
//     context: context,
//     isScrollControlled: true,
//     shape: const RoundedRectangleBorder(
//       borderRadius: BorderRadius.vertical(
//         top: Radius.circular(15),
//       ),
//     ),
//     builder: (BuildContext context) {
//       return SafeArea(
//         child: Padding(
//           padding: EdgeInsets.only(
//             bottom: MediaQuery.of(context).viewInsets.bottom,
//           ),
//           child: Container(
//             // padding: const EdgeInsets.all(20),
//             padding: const EdgeInsets.only(
//               top: 8,
//               bottom: 18,
//               left: 18,
//               right: 18,
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: <Widget>[
//                 Container(
//                   height: 5,
//                   margin: const EdgeInsets.only(
//                     bottom: 20,
//                     left: 150,
//                     right: 150,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.grey[400],
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//                 Text(
//                   title,
//                   style: GoogleFonts.poppins(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   decoration: const BoxDecoration(
//                     border: Border(
//                       top: BorderSide(
//                         color: Color.fromARGB(133, 158, 158, 158),
//                         width: 1,
//                       ),
//                     ),
//                   ),
//                   height: 200,
//                   child: TextField(
//                     controller: _textEditingController,
//                     decoration: const InputDecoration(
//                       hintText: 'Masukkan catatan...',
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 3,
//                         vertical: 8,
//                       ),
//                       border: InputBorder.none,
//                     ),
//                     maxLines: 3,
//                     maxLength: 200,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 GestureDetector(
//                   onTap: () {
//                     String catatan = _textEditingController.text;
//                     // Tutup BottomSheet
//                     Navigator.pop(context, catatan);
//                   },
//                   child: Container(
//                     decoration: BoxDecoration(
//                       color: AppColors.primaryColor,
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 12.0,
//                         horizontal: 16.0,
//                       ),
//                       child: Center(
//                         child: Text(
//                           "Konfirmasi",
//                           style: GoogleFonts.poppins(
//                             color: AppColors.textColorwhite,
//                             fontSize: 14,
//                             fontWeight: medium,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
