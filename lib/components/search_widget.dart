import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// class SearchWidget extends StatelessWidget {
//   final ValueChanged<String> onChanged;
//   final String tittle;
//   double paddingHorizontal;

//   SearchWidget({
//     Key? key,
//     required this.onChanged,
//     required this.tittle,
//     required this.paddingHorizontal,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
//       child: TextFormField(
//         cursorColor: Colors.grey,
//         textAlign: TextAlign.start,
//         textAlignVertical: TextAlignVertical.center,
//         onChanged: onChanged,
//         decoration: InputDecoration(
//           contentPadding: const EdgeInsets.symmetric(
//             vertical: 10,
//           ),
//           prefixIcon: const Icon(
//             Icons.search,
//             color: Colors.grey,
//           ),
//           hintText: tittle,
//           hintStyle: GoogleFonts.poppins(
//             color: Colors.grey,
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//                 color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.grey, width: 1),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String tittle;
  final double paddingHorizontal;
  TextEditingController? controller; // Tambahkan TextEditingController
  FocusNode? focusNode; // Tambahkan FocusNode

  SearchWidget({
    Key? key,
    required this.onChanged,
    required this.tittle,
    required this.paddingHorizontal,
    this.controller, // Tambahkan TextEditingController
    this.focusNode, // Tambahkan FocusNode
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: paddingHorizontal),
      child: TextFormField(
        cursorColor: Colors.grey,
        textAlign: TextAlign.start,
        textAlignVertical: TextAlignVertical.center,
        onChanged: onChanged,
        focusNode: focusNode, // Gunakan FocusNode
        controller: controller, // Gunakan TextEditingController
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
          ),
          hintText: tittle,
          hintStyle: GoogleFonts.poppins(
            color: Colors.grey,
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
            borderRadius: BorderRadius.circular(20),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
