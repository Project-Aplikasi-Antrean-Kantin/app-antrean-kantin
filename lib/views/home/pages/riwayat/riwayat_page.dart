import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_riwayat_transaksi.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/theme/colors.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/views/home/pages/riwayat/backup_detail_riwayat.dart';
import 'package:testgetdata/views/theme.dart';

class RiwayatPage extends StatefulWidget {
  // static const int RiwayatIndex = 1;
  final String role;

  const RiwayatPage({super.key, required this.role});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  List<Pesanan> orderedFood = [];
  bool isLoading = false;

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    fetchRiwayat(user.token, widget.role).then(
      (value) => setState(() {
        isLoading = false;
        orderedFood = value;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Container(
              color: backgroundColor,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    primaryColor,
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: backgroundColor,
                ),
                child: Column(
                  children: orderedFood.map((entry) {
                    int totalItem = 0;
                    final int idPesanan = entry.id;
                    final List<ListTransaksiDetail> pesananPembeli =
                        entry.listTransaksiDetail;
                    int subtotal = 0;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 254, 254),
                        border: Border.all(
                          color: Colors.grey,
                          width: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const DetialRwiayatCoba(),
                                ),
                              );
                            },
                            child: Center(
                              child: Text(
                                "Rincian Pesananmu",
                                style: GoogleFonts.poppins(
                                  color: secondaryTextColor,
                                  fontSize: 16,
                                  fontWeight: bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(
                              entry.status.replaceAll('_', ' ').toUpperCase(),
                              style: GoogleFonts.poppins(
                                color: getStatusColor(entry.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
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
                                  "Alamat Pengantaran",
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 14,
                                    fontWeight: semibold,
                                  ),
                                ),
                                const SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  textAlign: TextAlign.left,
                                  entry.namaRuangan ??
                                      capitalizeFirstLetter(
                                          'Tidak Diantar, Ambil Pesanan ke ${entry.listTransaksiDetail[0].menus?.tenants?.namaTenant}'),
                                  style: GoogleFonts.poppins(
                                    color: secondaryTextColor,
                                    fontSize: 12,
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
                            child: Text(
                              '${entry.listTransaksiDetail[0].menus?.tenants?.namaTenant}',
                              style: GoogleFonts.poppins(
                                color: secondaryTextColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                          ),
                          ...pesananPembeli.map((item) {
                            int harga = item.harga;
                            int jumlah = item.jumlah;
                            subtotal += (harga * jumlah);
                            totalItem += jumlah;
                            return PesananItemWidget(
                              pesanan: item,
                              tolakPesanan: () {},
                              terimaPesanan: () {},
                            );
                          }).toList(),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Subtotal pesanan ($totalItem menu)",
                                  style: GoogleFonts.poppins(
                                    color: primaryextColor,
                                    fontSize: 12,
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
                                    ),
                                  ),
                                ])
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Biaya layanan",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                            entry.biayaLayanan,
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    if (entry.isAntar == 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                                  fontWeight: semibold,
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                FormatCurrency
                                                    .intToStringCurrency(
                                                  1000,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  color: primaryextColor,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "Total",
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                            entry.total,
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Rincinan Pesanan",
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontSize: 14,
                                        fontWeight: semibold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "No Pesanan:",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                            fontWeight: regular,
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                        Text(
                                          "0000$idPesanan",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                            fontWeight: regular,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          "Pembayaran:",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                            fontWeight: regular,
                                          ),
                                        ),
                                        const Spacer(
                                          flex: 1,
                                        ),
                                        Text(
                                          entry.metodePembayaran
                                                      .toLowerCase() ==
                                                  'cod'
                                              ? 'Bayar di Tempat'
                                              : capitalizeFirstLetter(
                                                  entry.metodePembayaran),
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 12,
                                            fontWeight: regular,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              )
                            ],
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
