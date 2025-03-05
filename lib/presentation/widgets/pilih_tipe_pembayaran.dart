import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_keranjang.dart';

class PilihTipePembayaran extends StatelessWidget {
  // final List<String> tipePembayaran;
  final String? pilihTipePembayaran;
  final Function(String?) selectedPembayaran;
  final bool isKasirActive;
  final bool isCartActive;

  const PilihTipePembayaran({
    // required this.tipePembayaran,
    required this.pilihTipePembayaran,
    required this.selectedPembayaran,
    required this.isKasirActive,
    required this.isCartActive,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    log("pembayaran: " + pilihTipePembayaran.toString());
    return GestureDetector(
      onTap: () {
        bottomSheetTipePembayaran(context, (option2) {
          if (option2 == 'Bayar Tunai') {
            selectedPembayaran('cod');
          } else if (option2 == 'Transfer') {
            selectedPembayaran('Transfer');
          } else {
            selectedPembayaran('Coin');
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundColor,
        ),
        child: Row(
          children: [
            if (pilihTipePembayaran != null)
              pilihTipePembayaran == 'cod'
                  ? Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.payments_outlined,
                      ),
                    )
                  : Image.asset(
                      "assets/images/mandiri_logo.png",
                      height: 30,
                      width: 30,
                    ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(
                    horizontal: pilihTipePembayaran != null ? 10 : 0),
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      pilihTipePembayaran == null
                          ? 'Pilih Tipe Pembayaran'
                          : (pilihTipePembayaran == 'cod'
                              ? 'Bayar Tunai'
                              : pilihTipePembayaran!),
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textColorBlack,
                        height: 1.5,
                      ),
                    ),
                    if (pilihTipePembayaran != null)
                      Text(
                        FormatCurrency.intToStringCurrency(
                          isKasirActive
                              ? kasirProvider.getTotal()
                              : cartProvider.getTotal(),
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: semibold,
                          fontSize: 12,
                          color: AppColors.textColorBlack,
                          height: 1.5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color.fromARGB(255, 62, 62, 62),
              ),
              child: const Icon(
                Icons.more_horiz,
                size: 20,
                color: AppColors.backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
