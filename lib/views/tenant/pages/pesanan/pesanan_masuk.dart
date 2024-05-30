import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/components/custom_snackbar.dart';
import 'package:testgetdata/views/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/views/theme.dart';

class PesananMasuk extends StatelessWidget {
  final List<Pesanan> pesananMasuk;
  final Function(int, Pesanan, String) terimaPesanan;
  final Function(int, Pesanan, String) tolakPesanan;

  const PesananMasuk({
    Key? key,
    required this.pesananMasuk,
    required this.terimaPesanan,
    required this.tolakPesanan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
            ),
            child: Column(
              children: pesananMasuk.map((entry) {
                final int idPesanan = entry.id;
                final List<ListTransaksiDetail> pesananPembeli =
                    entry.listTransaksiDetail;
                int subtotal = 0;
                return Container(
                  margin: const EdgeInsets.only(
                    bottom: 5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 0.2,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi pesanan',
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 10,
                                fontWeight: regular,
                              ),
                            ),
                            const SizedBox(
                              height: 3,
                            ),
                            Text(
                              textAlign: TextAlign.left,
                              entry.namaRuangan != null
                                  ? 'Pesanan Berstatus DIANTAR'
                                  : 'Pesanan Berstatus AMBIL SENDIRI',
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pembeli',
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 10,
                                    fontWeight: regular,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  capitalizeFirstLetter("${entry.namaPembeli}"),
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'No.',
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 10,
                                    fontWeight: regular,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  "0000$idPesanan",
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'List pesanan',
                          style: GoogleFonts.poppins(
                            color: secondaryTextColor,
                            fontSize: 10,
                            fontWeight: regular,
                          ),
                        ),
                      ),
                      ...pesananPembeli.map((item) {
                        int harga = item.harga;
                        int jumlah = item.jumlah;
                        subtotal += (harga * jumlah);
                        return PesananItemWidget(
                          pesanan: item,
                          tolakPesanan: () {
                            // Tambahkan logika untuk menolak pesanan di sini
                          },
                          terimaPesanan: () {
                            // Tambahkan logika untuk menerima pesanan di sini
                          },
                        );
                      }).toList(),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Divider(
                          color: Colors.grey,
                          height: 1,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal (${entry.listTransaksiDetail.length} menu)",
                                  style: GoogleFonts.poppins(
                                    color: primaryextColor,
                                    fontSize: 12,
                                    fontWeight: medium,
                                  ),
                                ),
                                Column(children: [
                                  Text(
                                    FormatCurrency.intToStringCurrency(
                                      subtotal,
                                    ),
                                    style: GoogleFonts.poppins(
                                      color: primaryextColor,
                                      fontSize: 12,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ])
                              ],
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Total",
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: bold,
                                  ),
                                ),
                                Text(
                                  FormatCurrency.intToStringCurrency(
                                    subtotal,
                                  ),
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      // Tambahkan logika untuk menolak pesanan di sini
                                      try {
                                        tolakPesanan(
                                            idPesanan, entry, user.token);
                                      } catch (e) {
                                        // PERHATIKAN
                                        if (e is ApiException) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            CustomSnackBar(
                                              status: e.status,
                                              message: e.message,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            CustomSnackBar(
                                              status: 'failed',
                                              message: e.toString(),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: const BorderSide(
                                        color: Colors.grey,
                                      ),
                                      backgroundColor: Colors.white,
                                      minimumSize: const Size(20, 30),
                                    ),
                                    child: Text(
                                      'Tolak',
                                      style: GoogleFonts.poppins(
                                          color: secondaryTextColor,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      try {
                                        terimaPesanan(
                                            idPesanan, entry, user.token);
                                      } catch (e) {
                                        // PERHATIKAN
                                        if (e is ApiException) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            CustomSnackBar(
                                              status: e.status,
                                              message: e.message,
                                            ),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            CustomSnackBar(
                                              status: 'failed',
                                              message: e.toString(),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      side: BorderSide(
                                        color: primaryColor,
                                      ),
                                      backgroundColor: primaryColor,
                                      minimumSize: Size(20, 30),
                                    ),
                                    child: Text(
                                      'Terima',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: medium,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
