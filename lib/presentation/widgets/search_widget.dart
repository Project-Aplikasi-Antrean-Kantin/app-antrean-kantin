// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';

// class SearchWidget extends StatelessWidget {
//   final ValueChanged<String> onChanged;
//   final String tittle;
//   final double paddingHorizontal;
//   TextEditingController? controller; // Tambahkan TextEditingController
//   FocusNode? focusNode; // Tambahkan FocusNode

//   SearchWidget({
//     Key? key,
//     required this.onChanged,
//     required this.tittle,
//     required this.paddingHorizontal,
//     this.controller, // Tambahkan TextEditingController
//     this.focusNode, // Tambahkan FocusNode
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
//         focusNode: focusNode, // Gunakan FocusNode
//         controller: controller, // Gunakan TextEditingController
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
//               color: Color.fromARGB(255, 75, 75, 75),
//               width: 1.5,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: Colors.grey,
//               width: 1,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:testgetdata/views/theme.dart';

// class SearchWidget extends StatefulWidget {
//   final ValueChanged<String> onChanged;
//   final String tittle;
//   final double paddingHorizontal;
//   final double paddingVertical;
//   TextEditingController? controller;
//   FocusNode? focusNode;

//   SearchWidget({
//     Key? key,
//     required this.onChanged,
//     required this.tittle,
//     required this.paddingHorizontal,
//     required this.paddingVertical,
//     this.controller,
//     this.focusNode,
//   }) : super(key: key);

//   @override
//   _SearchWidgetState createState() => _SearchWidgetState();
// }

// class _SearchWidgetState extends State<SearchWidget> {
//   late FocusNode _focusNode;
//   late ValueNotifier<Color> _iconColorNotifier;

//   @override
//   void initState() {
//     super.initState();
//     _focusNode = widget.focusNode ?? FocusNode();
//     _iconColorNotifier = ValueNotifier<Color>(Colors.grey);

//     _focusNode.addListener(() {
//       if (_focusNode.hasFocus) {
//         _iconColorNotifier.value = primaryColor;
//       } else {
//         _iconColorNotifier.value = Colors.grey;
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _focusNode.dispose();
//     _iconColorNotifier.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.symmetric(
//         horizontal: widget.paddingHorizontal,
//         vertical: widget.paddingVertical,
//       ),
//       child: TextFormField(
//         style: GoogleFonts.poppins(
//           color: secondaryTextColor,
//           fontSize: 15,
//         ),
//         cursorColor: Colors.grey,
//         textAlign: TextAlign.start,
//         textAlignVertical: TextAlignVertical.center,
//         onChanged: widget.onChanged,
//         focusNode: _focusNode,
//         controller: widget.controller,
//         decoration: InputDecoration(
//           contentPadding: const EdgeInsets.symmetric(vertical: 10),
//           prefixIcon: ValueListenableBuilder<Color>(
//             valueListenable: _iconColorNotifier,
//             builder: (context, color, child) {
//               return Icon(
//                 Icons.search,
//                 color: color,
//               );
//             },
//           ),
//           hintText: widget.tittle,
//           hintStyle: GoogleFonts.poppins(
//             color: Colors.grey,
//             fontSize: 14,
//           ),
//           filled: true,
//           fillColor: Colors.white,
//           focusedBorder: OutlineInputBorder(
//             borderSide: const BorderSide(
//               color: Colors.grey,
//               width: 0.2,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           enabledBorder: OutlineInputBorder(
//             // borderSide: BorderSide.none,
//             borderSide: const BorderSide(
//               color: Colors.grey,
//               width: 0.2,
//             ),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           border: OutlineInputBorder(
//             borderSide: BorderSide.none,
//             borderRadius: BorderRadius.circular(20),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class SearchWidget extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String tittle;
  final double paddingHorizontal;
  final double paddingVertical;
  TextEditingController? controller;
  FocusNode? focusNode;

  SearchWidget({
    Key? key,
    required this.onChanged,
    required this.tittle,
    required this.paddingHorizontal,
    required this.paddingVertical,
    this.controller,
    this.focusNode,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  late FocusNode _focusNode;
  late ValueNotifier<Color> _iconColorNotifier;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _iconColorNotifier = ValueNotifier<Color>(Colors.grey);

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _iconColorNotifier.value = AppColors.primaryColor;
      } else {
        _iconColorNotifier.value = Colors.grey;
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _iconColorNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widget.paddingHorizontal,
        vertical: widget.paddingVertical,
      ),
      child: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
          borderRadius: BorderRadius.circular(20),
        ),
        child: TextFormField(
          style: GoogleFonts.poppins(
            color: AppColors.secondaryTextColor,
            fontSize: 15,
          ),
          cursorColor: Colors.grey,
          textAlign: TextAlign.start,
          textAlignVertical: TextAlignVertical.center,
          onChanged: widget.onChanged,
          focusNode: _focusNode,
          controller: widget.controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 10),
            prefixIcon: ValueListenableBuilder<Color>(
              valueListenable: _iconColorNotifier,
              builder: (context, color, child) {
                return Icon(
                  Icons.search,
                  color: color,
                );
              },
            ),
            hintText: widget.tittle,
            hintStyle: GoogleFonts.poppins(
              color: Colors.grey,
              fontSize: 14,
            ),
            filled: true,
            fillColor: Colors.white,
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ),
    );
  }
}
