import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class RingkasanPembayaran extends StatelessWidget {
  final Pesanan pesanan;
  const RingkasanPembayaran({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 10,
      children: [
        _buildRowText("Biaya layanan", pesanan.biayaLayanan),
        if (pesanan.isAntar == 1)
          _buildRowText("Biaya Pengantaran", pesanan.ongkosKirim),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(pesanan.total),
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRowText(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(value),
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
