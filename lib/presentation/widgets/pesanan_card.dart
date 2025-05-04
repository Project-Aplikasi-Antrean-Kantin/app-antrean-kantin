import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';

class PesananCard extends StatelessWidget {
  final Pesanan pesanan;
  final VoidCallback? terimaPesanan;
  final VoidCallback? tolakPesanan;
  final Widget? actionButton; // Bisa null jika tidak butuh button khusus

  const PesananCard({
    Key? key,
    required this.pesanan,
    this.terimaPesanan, // Opsional
    this.tolakPesanan, // Opsional
    this.actionButton, // Opsional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalItemMenu = pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Informasi Pesanan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informasi pesanan',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  pesanan.namaRuangan != null
                      ? 'Pesanan Berstatus DIANTAR'
                      : 'Pesanan Berstatus AMBIL SENDIRI',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          // Pembeli & Nomor Pesanan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pembeli',
                        style: GoogleFonts.poppins(
                            color: AppColors.textColorBlack, fontSize: 10)),
                    const SizedBox(height: 3),
                    Text(
                      '${pesanan.namaPembeli}',
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('No.',
                        style: GoogleFonts.poppins(
                            color: AppColors.textColorBlack, fontSize: 10)),
                    const SizedBox(height: 3),
                    Text(
                      "ORDER-0${pesanan.id}",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          // List Pesanan
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Text('List pesanan',
                style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack, fontSize: 10)),
          ),
          ...pesanan.listTransaksiDetail.map((item) {
            // int harga = item.harga;
            // int totalItems = item.jumlah;
            // subtotal += (harga * jumlah);
            return PesananItemWidget(
              pesanan: item,
              tolakPesanan: () {}, // Bisa dikosongkan jika tidak diperlukan
              terimaPesanan: () {}, // Bisa dikosongkan jika tidak diperlukan
            );
          }).toList(),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Divider(color: Colors.grey, height: 1),
          ),
          // Subtotal & Total
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Subtotal ($totalItemMenu menu)",
                      style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      FormatCurrency.intToStringCurrency(pesanan.subTotal),
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 12,
                        fontWeight: medium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorBlack,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      pesanan.isAntar == 0
                          ? FormatCurrency.intToStringCurrency(pesanan.total)
                          : FormatCurrency.intToStringCurrency(
                              pesanan.total - pesanan.ongkosKirim,
                            ),
                      style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Action Buttons
                if (terimaPesanan != null || tolakPesanan != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (tolakPesanan != null)
                        ElevatedButton(
                          onPressed: tolakPesanan,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.red,
                            minimumSize: Size(100, 40),
                          ),
                          child: Text(
                            'Tolak',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      if (terimaPesanan != null)
                        ElevatedButton(
                          onPressed: terimaPesanan,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            backgroundColor: Colors.green,
                            minimumSize: Size(100, 40),
                          ),
                          child: Text(
                            'Terima',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                if (actionButton != null) actionButton!,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
