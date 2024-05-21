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
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

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
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
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
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border(
                                              bottom: BorderSide(
                                                color: secondaryTextColor,
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          child: Text(
                                            '${entry.listTransaksiDetail[0].menus?.tenants?.namaTenant}',
                                            style: GoogleFonts.poppins(
                                              color: secondaryTextColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        //
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.only(
                                      top: 10,
                                    ),
                                    child: Text(
                                      textAlign: TextAlign.right,
                                      '${entry.namaRuangan ?? 'Ambil Sendiri'}',
                                      style: GoogleFonts.poppins(
                                        color: secondaryTextColor,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
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
                              tolakPesanan: () {},
                              terimaPesanan: () {},
                            );
                          }).toList(),
                          const SizedBox(height: 10),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const SizedBox(
                                      height: 13,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Subtotal",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Column(children: [
                                          Text(
                                            FormatCurrency.intToStringCurrency(
                                              subtotal,
                                            ),
                                            style: GoogleFonts.poppins(
                                              color: primaryextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ])
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Biaya layanan",
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                            entry.biayaLayanan,
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: primaryextColor,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 7,
                                    ),
                                    if (entry.isAntar == 1)
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Ongkir",
                                            style: GoogleFonts.poppins(
                                              color: primaryextColor,
                                              fontSize: 14,
                                            ),
                                          ),
                                          // Menampilkan jumlah menu dikalikan dengan 10000
                                          Text.rich(
                                            TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${totalItem}x ",
                                                  style: GoogleFonts.poppins(
                                                    color: secondaryTextColor,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: FormatCurrency
                                                      .intToStringCurrency(
                                                    1000,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    color: primaryextColor,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total",
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                            entry.total,
                                          ),
                                          style: GoogleFonts.poppins(
                                            color: secondaryTextColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 10,
                                  right: 10,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      child: Text(
                                        entry.status
                                            .replaceAll('_', ' ')
                                            .toUpperCase(),
                                        style: GoogleFonts.poppins(
                                          color: getStatusColor(entry.status),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      // ),
                                    ),
                                  ],
                                ),
                              ),
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
