import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class DateHeader extends StatelessWidget {
  final String tanggal;

  const DateHeader({super.key, required this.tanggal});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        tanggal,
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: semibold,
          color: AppColors.blackColor300,
        ),
      ),
    );
  }
}
