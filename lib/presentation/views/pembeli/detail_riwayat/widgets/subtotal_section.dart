import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class SubtotalSection extends StatelessWidget {
  final int totalItem;
  final Pesanan pesanan;
  const SubtotalSection(
      {super.key, required this.totalItem, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 8,
      children: [
        DashedDivider(height: 2, color: AppColors.blackColor100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sub total : ${totalItem} Menu",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(
                pesanan.subTotal,
              ),
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
