import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/ruangan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/views/home/widgets/custom_alert.dart';
import 'package:testgetdata/views/home/widgets/list_cart.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pemesanan.dart';
import 'package:testgetdata/views/home/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/views/home/widgets/ringkasan_pembayaran_cart.dart';
import 'package:testgetdata/views/home/widgets/sukses_order.dart';
import 'package:testgetdata/views/tenant/widgets/ringkasan_pembayaran_kasir.dart';
import 'package:testgetdata/views/theme.dart';

class Cart extends StatefulWidget {
  const Cart({Key? key}) : super(key: key);

  State<Cart> createState() => _CartState();
}

class _CartState extends State<Cart> {
  TextEditingController namaPembeli = TextEditingController();
  TextEditingController ruanganPembeli = TextEditingController();
  TextEditingController catatan = TextEditingController();

  List<Ruangan> listRuangan = [];
  late final MidtransSDK _midtrans;
  bool isLoading = false;
  bool transactionCompleted = false;
  int? plihPengantaran;
  int? pilihRuangan;

  List<String> tipePemesanan = [
    'Ambil Sendiri',
    'Pesan Antar',
  ];

  _dialogDataTidakLengkap() {
    /// kode alert sebelum saya jadikan reusable component
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //       shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.circular(10),
    //       ),
    //       child: Container(
    //         padding: const EdgeInsets.all(25),
    //         child: Column(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             const Text(
    //               "Lengkapi informasi pesanan!",
    //               style: TextStyle(
    //                 fontSize: 16,
    //                 fontWeight: FontWeight.bold,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //             const SizedBox(height: 15),
    //             const Text(
    //               "Informasi pesanan anda belum lengkap, harap lengkapi terlebih dahulu",
    //               style: TextStyle(
    //                 fontSize: 14,
    //               ),
    //               textAlign: TextAlign.center,
    //             ),
    //             const SizedBox(height: 20),
    //             Row(
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               children: [
    //                 TextButton(
    //                   onPressed: () {
    //                     Navigator.of(context).pop();
    //                   },
    //                   style: ButtonStyle(
    //                     shape:
    //                         MaterialStateProperty.all<RoundedRectangleBorder>(
    //                       RoundedRectangleBorder(
    //                         borderRadius: BorderRadius.circular(5.0),
    //                         side: const BorderSide(color: Colors.grey),
    //                       ),
    //                     ),
    //                     minimumSize: MaterialStateProperty.all(Size(100, 30)),
    //                   ),
    //                   child: const Text(
    //                     "OK",
    //                     style:
    //                         TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
    //                   ),
    //                 ),
    //               ],
    //             ),
    //           ],
    //         ),
    //       ),
    //     );
    //   },
    // );

    /// kode alert setelah saya jadikan reusable component
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Data Tidak Lengkap!",
          message:
              "Harap isi data pemesanan terlebih dahulu sebelum melanjutkan.",
          onConfirmCancle: () {
            Navigator.of(context).pop(); // Menutup dialog
          },
          textButtonCancel: "OK",
          textButtonCancelColor: primaryColor,
          cancelBorderColor: primaryColor,
        );
      },
    );
  }

  /// Fungsi Init Midtrans
  // void initSDK() async {
  //   print("JALANIN SDK MIDTRANS");
  //   _midtrans = await MidtransSDK.init(
  //     config: MidtransConfig(
  //       clientKey: 'SB-Mid-client-T9zZrTGN1ARTH8rb',
  //       merchantBaseUrl:
  //           'https://app.sandbox.midtrans.com/snap/v4/redirection/',
  //       colorTheme: ColorTheme(
  //         colorPrimary: Theme.of(context).colorScheme.secondary,
  //         colorPrimaryDark: Theme.of(context).colorScheme.secondary,
  //         colorSecondary: Theme.of(context).colorScheme.secondary,
  //       ),
  //     ),
  //   );
  //   _midtrans?.setUIKitCustomSetting(
  //     skipCustomerDetailsPages: true,
  //   );
  //   _midtrans.setTransactionFinishedCallback((result) {
  //     print(result.toJson());
  //     if (result.transactionStatus == TransactionResultStatus.settlement) {
  //       setState(() {
  //         transactionCompleted = true;
  //       });
  //       Provider.of<CartProvider>(context, listen: false).clearCart();
  //       Provider.of<KasirProvider>(context, listen: false).clearCart();
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //           builder: (context) => const SuksesOrder(),
  //         ),
  //         (route) => false,
  //       );
  //     } else {
  //       print("Transaction failed or was canceled");
  //     }
  //   });
  // }

  void initState() {
    super.initState();

    /// Inisialisasi Provider
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    CartProvider cartProvider =
        Provider.of<CartProvider>(context, listen: false);
    KasirProvider kasirProvider =
        Provider.of<KasirProvider>(context, listen: false);

    UserModel user = authProvider.user;

    /// Inisialisasi Nilai awal
    plihPengantaran = null;
    pilihRuangan = null;
    // pilihPembayaran = null;

    fetchDataRuangan(user.token).then((value) {
      setState(() {
        listRuangan = value;
      });
    });

    /// auto set metodePembayaran ke cod/bayar tunai, ganti ke cashless apabila sudah ready
    cartProvider.setMetodePembayaran("cod");
    kasirProvider.setMetodePembayaran("cod");

    /// Init Midtrans
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   initSDK();
    // });
  }

  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
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
              Consumer2<CartProvider, KasirProvider>(
                builder: (context, cartData, kasirData, _) {
                  /// Menentukan keranjang yang aktif (KasirProvider atau CartProvider)
                  List<CartMenuModel> activeCart = kasirData.cart.isNotEmpty
                      ? kasirData.cart
                      : cartData.cart;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: activeCart.length,
                    itemBuilder: (context, i) {
                      /// perubahan dengan menggunakan 1 file cart saja
                      return ListCart(
                        cart: activeCart[i],
                        isKasir: kasirData.cart.isNotEmpty,
                      );

                      /// sebelum terjadi perubahan dari 2 file cart
                      // if (kasirData.cart.isNotEmpty) {
                      //   // Jika sedang aktif di kasir, tampilkan dari ListCartKasir
                      //   return ListCart(cart: activeCart[i]);
                      // } else {
                      //   // Jika tidak aktif di kasir, tampilkan dari ListCart
                      //   return ListCart(cart: activeCart[i]);
                      // }
                    },
                  );
                },
              ),
              const SizedBox(height: 15),
              Consumer2<CartProvider, KasirProvider>(
                builder: (context, cartData, kasirData, _) {
                  bool isKasirProviderActive = kasirData.cart.isNotEmpty;
                  return Column(
                    children: [
                      /// Jika KasirProvider tidak aktif tampilkan 3 pilihan ini
                      if (!isKasirProviderActive) ...[
                        /// Fitur Pilih Tipe Pemesanan
                        PilihTipePemesanan(
                          tipePemesanan: tipePemesanan,
                          plihPengantaran: plihPengantaran,
                          onPemesananSelected: (option) {
                            setState(() {
                              plihPengantaran = option;
                              cartData.setIsAntar(option!);
                            });
                          },
                        ),
                        const SizedBox(height: 8),

                        /// Fitur Pilih Lokasi Pengantaran
                        if (plihPengantaran == 1)
                          PilihLokasiRuangan(
                            listRuangan: listRuangan,
                            token: user.token,
                            selectedLocation: pilihRuangan,
                            onLocationSelected: (option) {
                              setState(() {
                                pilihRuangan = option;
                                cartData.setRuanganId(option!);
                              });
                            },
                          ),
                        const SizedBox(height: 8),

                        /// Fitur Pilih Pembayaran
                        // PilihTipePembayaran(
                        //   tipePembayaran: tipePembayaran,
                        //   pilihTipePembayaran: plihPembayaran,
                        //   selectedPembayaran: (option2) {
                        //     setState(() {
                        //       plihPembayaran = option2;
                        //       cartData.setMetodePembayaran(option2!);
                        //       kasirData.setMetodePembayaran(option2);
                        //     });
                        //   },
                        // ),
                      ],

                      /// Jika KasirProvider tidak aktif maka tampilkan ringkasana pembayaran kasir
                      if (!isKasirProviderActive) ...[
                        const SizedBox(height: 20),
                        RingkasanPembayaranCart(),
                        const SizedBox(height: 5),
                      ] else ...[
                        const SizedBox(height: 20),
                        RingkasanPembayaranKasir(),
                        const SizedBox(height: 5),
                      ]
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: context.watch<CartProvider>().isCartShow ||
              context.watch<KasirProvider>().isCartShow
          ? Consumer2<CartProvider, KasirProvider>(
              builder: (context, cartData, kasirData, _) {
                return Container(
                  margin: const EdgeInsets.all(15),
                  height: 63,
                  decoration: BoxDecoration(
                    color: isLoading ? Colors.grey : primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    enableFeedback: !isLoading,
                    onTap: isLoading
                        ? () {}
                        : () {
                            /// Optimalkan validasi di provider agar file ini hanya fokus pada ui
                            if (!kasirData.cart.isNotEmpty &&
                                !cartData.isCartValid(
                                    plihPengantaran, pilihRuangan)) {
                              _dialogDataTidakLengkap();
                            }

                            /// Logika validasi awal
                            // if (!kasirData.cart.isNotEmpty &&
                            //     (plihPengantaran == null ||
                            //         (plihPengantaran == 1 &&
                            //             pilihRuangan == null))) {
                            //   _dialogDataTidakLengkap();
                            // }

                            else {
                              setState(() {
                                isLoading = true;
                                transactionCompleted = true;
                              });
                              if (kasirData.cart.isNotEmpty) {
                                kasirData
                                    .buatTransaksi(context, user.token)
                                    .then((value) {
                                  /// Menghapus item pada keranjang kasir
                                  kasirData.clearCart();

                                  /// Mengarahkan ke halaman sukses
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SuksesOrder(),
                                    ),
                                    (route) => false,
                                  );

                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                cartData
                                    .buatTransaksi(context, user.token)
                                    .then((value) {
                                  if (value.status == 'success') {
                                    if (value.snap != null) {
                                      _midtrans.startPaymentUiFlow(
                                        token: value.snap!.token,
                                      );
                                    } else {
                                      cartData.clearCart();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              const SuksesOrder(),
                                        ),
                                        (route) => false,
                                      );
                                    }
                                  } else {
                                    print('gagal brooo');
                                  }
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              }
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
                );
              },
            )
          : null,
    );
  }
}
