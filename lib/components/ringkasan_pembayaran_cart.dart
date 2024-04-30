import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';

class RingkasanPembayaranCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    return Container(
      // decoration: BoxDecoration(
      //   borderRadius: BorderRadius.circular(10),
      //   border: Border.all(
      //     color: Colors.grey,
      //     width: 1,
      //   ),
      // ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(
          Radius.circular(10),
        ),
        border: Border(
          bottom: BorderSide(
            color: Colors.grey, // Warna border
            width: 1.0, // Lebar border
          ),
          top: BorderSide(
            color: Colors.grey, // Warna border
            width: 0.2, // Lebar border
          ),
          left: BorderSide(
            color: Colors.grey, // Warna border
            width: 0.2, // Lebar border
          ),
          right: BorderSide(
            color: Colors.grey, // Warna border
            width: 0.2, // Lebar border
          ),
        ),
        // borderRadius: BorderRadius.circular(10),
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
                      NumberFormat.currency(
                        symbol: 'Rp. ',
                        decimalDigits: 0,
                        locale: 'id-ID',
                      ).format(cartProvider.cost),
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
                  NumberFormat.currency(
                    symbol: 'Rp. ',
                    decimalDigits: 0,
                    locale: 'id-ID',
                  ).format(cartProvider.service),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 7,
            ),
            if (cartProvider.isAntar == 1)
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
                          text: "${cartProvider.jumlahMenu()}x ",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        TextSpan(
                          text: "Rp.1.000",
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
                  NumberFormat.currency(
                    symbol: 'Rp',
                    decimalDigits: 0,
                    locale: 'id-ID',
                  ).format(cartProvider.getTotal()),
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.redAccent,
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
