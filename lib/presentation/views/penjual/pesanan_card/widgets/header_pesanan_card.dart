import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';

class HeaderPesananCard extends StatelessWidget {
  final Pesanan pesanan;
  const HeaderPesananCard({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Text(
              '${pesanan.namaPembeli}',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'ORDER-${pesanan.id}',
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor100,
                  fontSize: 10,
                  fontWeight: bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
