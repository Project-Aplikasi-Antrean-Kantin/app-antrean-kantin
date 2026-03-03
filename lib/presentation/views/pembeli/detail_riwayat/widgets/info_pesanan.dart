import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';

class InfoPesanan extends StatelessWidget {
  final Pesanan pesanan;
  const InfoPesanan({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 4,
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                'Kode Pemesanan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: semibold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${pesanan.kodePemesanan}',
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: semibold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${pesanan.namaPembeli}',
                softWrap: true,
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
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
