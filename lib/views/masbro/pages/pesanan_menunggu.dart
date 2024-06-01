import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/views/theme.dart';

class PesananMenunggu extends StatefulWidget {
  final List<Pesanan> pesananSiapDiantar;
  final Function(int, Pesanan, String) pesananDiantar;

  const PesananMenunggu({
    Key? key,
    required this.pesananSiapDiantar,
    required this.pesananDiantar,
  }) : super(key: key);

  @override
  State<PesananMenunggu> createState() => PesananMenungguState();
}

class PesananMenungguState extends State<PesananMenunggu> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Column(
            children: widget.pesananSiapDiantar.map((entry) {
              int totalItem = 0;
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
                            'Alamat pengantaran',
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
                            "${entry.namaRuangan}",
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
                                'Penerima',
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tenant',
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
                                '${entry.listTransaksiDetail[0].menus?.tenants?.namaTenant}'),
                            style: GoogleFonts.poppins(
                              color: secondaryTextColor,
                              fontSize: 14,
                              fontWeight: semibold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...pesananPembeli.map((item) {
                      int harga = item.harga;
                      int jumlah = item.jumlah;
                      subtotal += (harga * jumlah);
                      totalItem += jumlah;
                      return PesananItemWidget(
                        pesanan: item,
                        tolakPesanan: () {
                          // ntar Tambahkan logika untuk menolak pesanan di sini
                        },
                        terimaPesanan: () {
                          // ntar Tambahkan logika untuk menerima pesanan di sini
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
                            children: [
                              Text(
                                "Biaya layanan",
                                style: GoogleFonts.poppins(
                                  color: primaryextColor,
                                  fontSize: 12,
                                  fontWeight: medium,
                                ),
                              ),
                              Column(children: [
                                Text(
                                  FormatCurrency.intToStringCurrency(
                                    entry.biayaLayanan,
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
                            children: [
                              Text(
                                "Ongkir",
                                style: GoogleFonts.poppins(
                                  color: primaryextColor,
                                  fontSize: 12,
                                ),
                              ),
                              // Menampilkan jumlah menu dikalikan dengan 10000
                              Row(
                                children: [
                                  Text(
                                    "$totalItem x",
                                    style: GoogleFonts.poppins(
                                      color: primaryextColor,
                                      fontSize: 12,
                                      fontWeight: semibold,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    FormatCurrency.intToStringCurrency(
                                      1000,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: primaryextColor,
                                      fontWeight: medium,
                                    ),
                                  ),
                                ],
                              ),
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
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  widget.pesananDiantar(
                                      idPesanan, entry, user.token);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: BorderSide(
                                    color: primaryColor,
                                  ),
                                  backgroundColor: primaryColor,
                                  minimumSize: const Size(20, 30),
                                  fixedSize: Size(180, 35),
                                ),
                                child: Text(
                                  'Antar Pesanan',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: medium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
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
    );
  }
}
