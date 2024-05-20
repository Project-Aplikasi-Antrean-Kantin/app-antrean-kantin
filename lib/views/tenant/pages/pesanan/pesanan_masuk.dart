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

    bool _isLoading = false;

    return RefreshIndicator(
      onRefresh: _refresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: pesananMasuk.map((entry) {
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
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Row(
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
                                      color: Color.fromARGB(130, 0, 0, 0),
                                    ),
                                    backgroundColor: Colors.white,
                                    minimumSize: const Size(20, 30),
                                  ),
                                  child: Text(
                                    'Tolak',
                                    style: GoogleFonts.poppins(
                                        color: Colors.black,
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
                                    side: const BorderSide(
                                      color: Colors.redAccent,
                                    ),
                                    backgroundColor: Colors.redAccent,
                                    minimumSize: const Size(20, 30),
                                  ),
                                  child: Text(
                                    'Terima',
                                    style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500),
                                  ),
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
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    await Future.delayed(const Duration(seconds: 1));
  }
}
