import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:testgetdata/common/format_currency.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';

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
    final String food =
        pesanan.menusKelola.nama ?? pesanan.menusKelola.menus.nama;
    final int harga = pesanan.harga;
    final int jumlah = pesanan.jumlah;
    final String catatan = pesanan.catatan ?? '-';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 18,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color.fromARGB(98, 31, 31, 31),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '$jumlah x',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                food,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(
                flex: 1,
              ),
              Text(
                FormatCurrency.intToStringCurrency(harga),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 5,
                ),
                Text(
                  'Catatan : $catatan',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
