import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/common/format_currency.dart';
import 'package:testgetdata/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';

class HomeDiproses extends StatefulWidget {
  // final Map<String, List<Map<String, dynamic>>> pesananDiproses;
  final List<Pesanan> pesananDiproses;
  final Function(Pesanan, String) removePesanan;

  const HomeDiproses({
    Key? key,
    required this.pesananDiproses,
    required this.removePesanan,
  }) : super(key: key);

  @override
  _HomeDiprosesState createState() => _HomeDiprosesState();
}

class _HomeDiprosesState extends State<HomeDiproses> {
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
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
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
                      bottom: 10,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 20,
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
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                          ),
                          child: Container(
                            padding: const EdgeInsets.only(
                              bottom: 5,
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
                              'Pesanan No-$idPesanan',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
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
                                          FormatCurrency.intToStringCurrency(
                                            subtotal,
                                          ),
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                          ),
                                        ),
                                      ])
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
                                        FormatCurrency.intToStringCurrency(
                                          subtotal,
                                        ),
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      widget.removePesanan(pesanan, user.token);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        side: const BorderSide(
                                          color: Colors.redAccent,
                                        ),
                                        backgroundColor: Colors.redAccent,
                                        minimumSize: const Size(20, 30),
                                        fixedSize: Size(180, 30)),
                                    child: Text(
                                      'Pesanan Siap',
                                      style: GoogleFonts.poppins(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
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
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
    // Add refresh logic here if needed
  }
}
