import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class FooterPriceInfo extends StatelessWidget {
  final Pesanan pesanan;

  const FooterPriceInfo({
    super.key,
    required this.pesanan,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          FormatCurrency.intToStringCurrency(pesanan.total),
          style: GoogleFonts.poppins(
            color: AppColors.primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          '${pesanan.listTransaksiDetail.length} Menu',
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
