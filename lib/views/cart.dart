import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/bottom_sheet_keranjang.dart';
import 'package:testgetdata/components/list_cart.dart';
import 'package:testgetdata/components/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/components/pilih_tipe_pemesanan.dart';
import 'package:testgetdata/components/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/components/ringkasan_pembayaran_cart.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  @override
  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController namaPembeli = TextEditingController();
  TextEditingController ruanganPembeli = TextEditingController();
  TextEditingController catatan = TextEditingController();
  List<Ruangan> listRuangan = [];
  bool isLoading = false;

  List<String> tipePemesanan = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];
  List<String> tipePembayaran = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  int? plihPengantaran;
  int? pilihRuangan;
  String? plihPembayaran;

  @override
  void initState() {
    super.initState();

    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    plihPengantaran = null;
    pilihRuangan = null;
    pilihPembayaran = null;

    fetchDataRuangan(user.token).then((value) {
      setState(() {
        listRuangan = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    final List<CartMenuModel> cart = Provider.of<CartProvider>(context).cart;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 248, 248, 248),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        title: Text(
          'Keranjang',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            color: Colors.black,
            size: 24,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(15),
          child: Column(
            children: [
              Consumer<CartProvider>(
                builder: (context, data, _) {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: data.cart.length,
                    itemBuilder: (context, i) {
                      // List item pembeli
                      return ListCart(
                        cart: data.cart[i],
                      );
                    },
                  );
                },
              ),
              const SizedBox(
                height: 15,
              ),
              Consumer<CartProvider>(builder: (context, data, _) {
                return Column(
                  children: [
                    // Tipe Pemesanan
                    PilihTipePemesanan(
                      tipePemesanan: tipePemesanan,
                      plihPengantaran: plihPengantaran,
                      onPemesananSelected: (option) {
                        setState(() {
                          plihPengantaran = option;
                          data.setIsAntar(option!);
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Lokasi Pengantaran
                    if (plihPengantaran == 1)
                      PilihLokasiRuangan(
                        listRuangan: listRuangan,
                        token: user.token,
                        selectedLocation: pilihRuangan,
                        onLocationSelected: (option) {
                          setState(() {
                            pilihRuangan = option;
                            data.setRuanganId(option!);
                          });
                        },
                      ),
                    const SizedBox(height: 8),

                    // Tipe pembayaran
                    PilihTipePembayaran(
                      tipePembayaran: tipePembayaran,
                      pilihTipePembayaran: pilihPembayaran,
                      selectedPembayaran: (option2) {
                        setState(() {
                          plihPembayaran = option2;
                          data.setMetodePembayaran(option2!);
                        });
                      },
                    ),
                  ],
                );
              }),
              const SizedBox(
                height: 20,
              ),

              // Ringkasan Pembayaran
              RingkasanPembayaranCart(),
              const SizedBox(height: 5),
            ],
          ),
        ),
      ),
      bottomNavigationBar: context.watch<CartProvider>().isCartShow
          ? Consumer<CartProvider>(
              builder: (context, data, _) {
                return Container(
                  margin: const EdgeInsets.all(15),
                  height: 63,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  // child: InkWell(
                  //   onTap: () {
                  //     setState(() {
                  //       isLoading = true;
                  //     });
                  //     Navigator.push(context, MaterialPageRoute(
                  //       builder: (context) {
                  //         return const Cart();
                  //       },
                  //     ));
                  //   },
                  child: InkWell(
                    enableFeedback: !isLoading,
                    onTap: isLoading
                        ? () {}
                        : () {
                            if (plihPengantaran == null ||
                                (plihPengantaran == 1 &&
                                    pilihRuangan == null) ||
                                plihPembayaran == null) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.all(25),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        // crossAxisAlignment:
                                        //     CrossAxisAlignment.center,
                                        children: [
                                          const Text(
                                            "Lengkapi informasi pesanan!",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 15),
                                          const Text(
                                            "Informasi pesanan anda belum lengkap, harap lengkapi terlebih dahulu",
                                            style: TextStyle(
                                              fontSize: 14,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                          const SizedBox(height: 20),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                style: ButtonStyle(
                                                  shape:
                                                      MaterialStateProperty.all<
                                                          RoundedRectangleBorder>(
                                                    RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5.0),
                                                      side: const BorderSide(
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ),
                                                  minimumSize:
                                                      MaterialStateProperty.all(
                                                          Size(100, 30)),
                                                ),
                                                child: const Text(
                                                  "OK",
                                                  style: TextStyle(
                                                    color: Color.fromARGB(
                                                        255, 99, 99, 99),
                                                  ),
                                                ),
                                              ),
                                              // const SizedBox(width: 16),
                                              // TextButton(
                                              //   onPressed: () {
                                              //     Provider.of<CartProvider>(
                                              //             context,
                                              //             listen: false)
                                              //         .clearCart();
                                              //     Navigator.of(context).pop();
                                              //     Navigator.pop(
                                              //         context); // Kembali ke halaman sebelumnya
                                              //   },
                                              //   style: ButtonStyle(
                                              //     shape:
                                              //         MaterialStateProperty.all<
                                              //             RoundedRectangleBorder>(
                                              //       RoundedRectangleBorder(
                                              //         borderRadius:
                                              //             BorderRadius.circular(
                                              //                 5.0),
                                              //       ),
                                              //     ),
                                              //     backgroundColor:
                                              //         MaterialStateProperty.all<
                                              //             Color>(
                                              //       Color.fromARGB(
                                              //           227, 244, 67, 54),
                                              //     ),
                                              //     minimumSize:
                                              //         MaterialStateProperty.all(
                                              //             Size(100, 30)),
                                              //   ),
                                              //   child: const Text(
                                              //     "Keluar",
                                              //     style: TextStyle(
                                              //       color: Colors.white,
                                              //     ),
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              setState(() {
                                isLoading = true;
                              });
                              Provider.of<CartProvider>(context, listen: false)
                                  .buatTransaksi(context, user.token)
                                  .then(
                                (value) {
                                  if (value) {
                                    print(value);
                                    print('berhasil');
                                    Provider.of<CartProvider>(context,
                                            listen: false)
                                        .clearCart();
                                    Navigator.pushNamed(
                                        context, '/sukses_order');
                                  } else {
                                    print('gagal brooo');
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                },
                              );
                            }
                          },
                    child: Align(
                      alignment: Alignment.center,
                      child: isLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 20,
                                  height: 20,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 4,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  "Tunggu sebentar",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            )
                          : Text(
                              "Pesan sekarang",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  // ),
                );
              },
            )
          : null,
    );
  }
}
