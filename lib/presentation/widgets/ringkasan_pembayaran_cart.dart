import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class RingkasanPembayaranCart extends StatelessWidget {
  final bool isKasir;

  const RingkasanPembayaranCart({
    super.key,
    required this.isKasir,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final kasirProvider = Provider.of<KasirProvider>(context);
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(
      //     color: Colors.grey,
      //     width: 1,
      //   ),
      // ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border.all(
          width: 0.2,
          color: Colors.grey,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Ringkasan pembayaran",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(
              height: 13,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Harga",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
                Column(
                  children: [
                    Text(
                      FormatCurrency.intToStringCurrency(
                        isKasir
                            ? kasirProvider.cost
                            : cartProvider.deliveryCost,
                      ),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Biaya layanan",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
                Text(
                  FormatCurrency.intToStringCurrency(
                    cartProvider.serviceFee,
                  ),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            if (!isKasir)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Ongkir",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  // Menampilkan jumlah menu dikalikan dengan 10000
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: "${cartProvider.getTotalItemCount()}x ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: FormatCurrency.intToStringCurrency(
                            1000,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(
              height: 7,
            ),
            const Divider(
              color: Colors.grey,
              thickness: 1,
              indent: 0,
              endIndent: 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  FormatCurrency.intToStringCurrency(
                    isKasir
                        ? kasirProvider.getTotal()
                        : cartProvider.getTotal(),
                  ),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
