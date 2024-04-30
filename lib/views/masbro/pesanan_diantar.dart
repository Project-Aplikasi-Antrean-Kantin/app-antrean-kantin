import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/pesanan_pembeli_tile.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/transaksi_detail_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/masbro/pesanan_diantar.dart';

class PesananDiantar extends StatefulWidget {
  final List<Pesanan> pesananDiantar;
  final Function(int, String) pesananSelesai;

  const PesananDiantar({
    Key? key,
    required this.pesananDiantar,
    required this.pesananSelesai,
  }) : super(key: key);

  @override
  State<PesananDiantar> createState() => PesananDiantarState();
}

class PesananDiantarState extends State<PesananDiantar> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: widget.pesananDiantar.map((entry) {
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
                            '${entry.namaRuangan}',
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
                        tolakPesanan: () {
                          // ntar Tambahkan logika untuk menolak pesanan di sini
                        },
                        terimaPesanan: () {
                          // ntar Tambahkan logika untuk menerima pesanan di sini
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              const SizedBox(
                                height: 13,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                        symbol: 'Rp. ',
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Biaya layanan",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    NumberFormat.currency(
                                      symbol: 'Rp. ',
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                          text: " Rp. 1.000",
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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      symbol: 'Rp. ',
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
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Center(
                                child: Text(
                                  '#$idPesanan',
                                  style: TextStyle(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  widget.pesananSelesai(idPesanan, user.token);
                                },
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  side: const BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                  backgroundColor: Colors.redAccent,
                                  minimumSize: const Size(20, 30),
                                ),
                                child: const Text(
                                  'Diterima',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
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
