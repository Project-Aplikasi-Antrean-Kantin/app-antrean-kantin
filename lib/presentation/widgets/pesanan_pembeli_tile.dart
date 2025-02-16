import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/core/theme/theme.dart';

class PesananItemWidget extends StatelessWidget {
  final ListTransaksiDetail pesanan;
  //  Map<String, dynamic> pesanan = value.first;
  final Function() tolakPesanan;
  final Function() terimaPesanan;

  PesananItemWidget({
    Key? key,
    required this.pesanan,
    required this.tolakPesanan,
    required this.terimaPesanan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // final String food =
    //     pesanan.menusKelola?.nama ?? pesanan.menusKelola?.menus.nama;
    final String food = pesanan.namaMenu ??
        pesanan.menus?.nama ??
        'iki jeneng e kosong ketok e';

    final int harga = pesanan.harga;
    final int jumlah = pesanan.jumlah;
    final String catatan = pesanan.catatan ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 15,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$jumlah x',
                style: GoogleFonts.poppins(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                food,
                style: GoogleFonts.poppins(
                  color: secondaryTextColor,
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Text(
                FormatCurrency.intToStringCurrency(
                  harga,
                ),
                style: GoogleFonts.poppins(
                  color: primaryTextColor,
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ],
          ),
          if (catatan.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 36,
                vertical: 5,
              ),
              child: Text(
                'Note: $catatan',
                style: GoogleFonts.poppins(
                  color: primaryTextColor,
                  fontSize: 14,
                  fontWeight: medium,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
