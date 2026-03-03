import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class SummaryPrice extends StatelessWidget {
  final int totalPrice;
  const SummaryPrice({super.key, required this.totalPrice});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Total Harga",
          style: GoogleFonts.poppins(
            fontSize: 14,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(totalPrice),
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primaryColor,
          ),
        ),
      ],
    );
  }
}
