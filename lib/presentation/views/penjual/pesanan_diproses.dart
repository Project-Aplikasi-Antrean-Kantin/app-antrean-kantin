import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/theme.dart';

class PesananDiproses extends StatefulWidget {
  final List<Pesanan> pesananDiproses;
  final Function(Pesanan, String) removePesanan;

  const PesananDiproses({
    Key? key,
    required this.pesananDiproses,
    required this.removePesanan,
  }) : super(key: key);

  @override
  _PesananDiprosesState createState() => _PesananDiprosesState();
}

class _PesananDiprosesState extends State<PesananDiproses> {
  List<Pesanan> _pesananDiproses = [];

  @override
  void initState() {
    super.initState();
    _pesananDiproses = widget.pesananDiproses;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
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
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _pesananDiproses.length,
                  itemBuilder: (BuildContext context, int index) {
                    final pesanan = _pesananDiproses[index];
                    final int idPesanan = _pesananDiproses[index].id;
                    final List<ListTransaksiDetail> pesananPembeli =
                        _pesananDiproses[index].listTransaksiDetail;
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
                                  _pesananDiproses[index].namaRuangan != null
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
                                      capitalizeFirstLetter(
                                          "${_pesananDiproses[index].namaPembeli}"),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Subtotal (${_pesananDiproses[index].listTransaksiDetail.length} menu)",
                                      style: GoogleFonts.poppins(
                                        color: primaryTextColor,
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
                                          color: primaryTextColor,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                const SizedBox(
                                  height: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        widget.removePesanan(
                                            pesanan, user.token);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side: BorderSide(
                                          color: primaryColor,
                                        ),
                                        backgroundColor: primaryColor,
                                        minimumSize: Size(20, 30),
                                        fixedSize: Size(180, 30),
                                      ),
                                      child: Text(
                                        'Pesanan Siap',
                                        style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: medium,
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
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Add refresh logic here if needed
  }
}
