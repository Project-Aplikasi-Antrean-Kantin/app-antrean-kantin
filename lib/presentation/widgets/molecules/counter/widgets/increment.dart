import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class Increment extends StatelessWidget {
  final VoidCallback onTap;
  final double width;
  final double height;
  const Increment(
      {super.key,
      required this.onTap,
      required this.width,
      required this.height});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      identifier: 'increment',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            width: width,
            height: height,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                '+',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
