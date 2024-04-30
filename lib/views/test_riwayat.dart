import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/http/fetch_riwayat_transaksi.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/theme/colors.dart';
import 'package:testgetdata/views/home/navbar_home.dart';

class TestRiwayat extends StatefulWidget {
  // static const int RiwayatIndex = 1;
  final String role;

  const TestRiwayat({super.key, required this.role});

  @override
  State<TestRiwayat> createState() => _TestRiwayatState();
}

class _TestRiwayatState extends State<TestRiwayat> {
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
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.white,
      //   toolbarHeight: 50,
      //   scrolledUnderElevation: 0,
      //   title: Text(
      //     'Riwayat',
      //     style: GoogleFonts.poppins(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //       color: Colors.black,
      //     ),
      //   ),
      //   centerTitle: true,
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(4.0),
      //     child: Container(
      //       color: Colors.grey,
      //       height: 0.5,
      //     ),
      //   ),
      // ),
      body: isLoading
          ? Center(
              child:
                  CircularProgressIndicator()) // Show CircularProgressIndicator while loading
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                        border: Border.all(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                  left: 5,
                                  right: 5,
                                ),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: Color.fromARGB(255, 31, 31, 31),
                                      width: 1,
                                    ),
                                  ),
                                ),
                                child: Text(
                                  '${entry.listTransaksiDetail[0].menusKelola.tenants.namaTenant}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(
                                flex: 1,
                              ),
                              Container(
                                padding: const EdgeInsets.only(
                                  top: 10,
                                ),
                                child: Text(
                                  '${entry.namaRuangan ?? 'Ambil Sendiri'}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        Column(children: [
                                          Text(
                                            NumberFormat.currency(
                                              symbol: 'Rp ',
                                              decimalDigits: 0,
                                              locale: 'id-ID',
                                            ).format(subtotal),
                                            style: GoogleFonts.poppins(
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
                                            fontSize: 14,
                                          ),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            symbol: 'Rp ',
                                            decimalDigits: 0,
                                            locale: 'id-ID',
                                          ).format(entry.biayaLayanan),
                                          style: GoogleFonts.poppins(
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
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " Rp 1.000",
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
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          NumberFormat.currency(
                                            symbol: 'Rp ',
                                            decimalDigits: 0,
                                            locale: 'id-ID',
                                          ).format(entry.total),
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black,
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
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Center(
                                        child: Text(
                                          'Pesanan',
                                          style: GoogleFonts.poppins(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      // child: Container(
                                      // decoration: BoxDecoration(
                                      //   borderRadius: BorderRadius.circular(8),
                                      // border: Border.all(
                                      //   color: getStatusColor(entry
                                      //       .status), // Fungsi untuk mendapatkan warna border sesuai status
                                      // ),
                                      // color: Colors.transparent,
                                      // ),
                                      // constraints: const BoxConstraints(
                                      //   minWidth: 20,
                                      //   minHeight: 30,
                                      // ),
                                      child: Center(
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
      // bottomNavigationBar: NavbarHome(
      //   pageIndex: user.menu.indexWhere((element) => element.url == '/riwayat'),
      // ),
    );
  }
}
