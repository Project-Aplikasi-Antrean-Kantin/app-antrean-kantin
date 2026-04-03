import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class CostSectionDelivery extends StatelessWidget {
  final Pesanan pesanan;
  final int lengthListPesanan;
  final int ongkir;
  const CostSectionDelivery(
      {super.key,
      required this.pesanan,
      required this.lengthListPesanan,
      required this.ongkir});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lengthListPesanan == 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Biaya Pengantaran',
                  style: GoogleFonts.poppins(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: bold,
                  ),
                ),
                Text(
                  FormatCurrency.intToStringCurrency(ongkir),
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 16,
                    fontWeight: bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
