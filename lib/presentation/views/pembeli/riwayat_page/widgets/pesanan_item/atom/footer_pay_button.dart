import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class FooterPayButton extends StatelessWidget {
  final Pesanan pesanan;

  const FooterPayButton({
    super.key,
    required this.pesanan,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: Key('bayar${pesanan.id}'),
      onTap: () {
        Navigator.push(
          context,
          CustomPageBuilder(
            page: CheckoutQris(
              pesanan: pesanan,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryColor,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          'Bayar',
          style: GoogleFonts.poppins(
            color: AppColors.primaryColor,
            fontSize: 14,
            fontWeight: semibold,
          ),
        ),
      ),
    );
  }
}
