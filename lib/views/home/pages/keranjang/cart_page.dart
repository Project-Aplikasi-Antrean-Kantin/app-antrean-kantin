// import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:midtrans_sdk/midtrans_sdk.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/constants.dart';
// import 'package:testgetdata/http/fetch_data_ruangan.dart';
// import 'package:testgetdata/http/order_cancel.dart';
// import 'package:testgetdata/model/ruangan_model.dart';
// import 'package:testgetdata/model/user_model.dart';
// import 'package:testgetdata/provider/auth_provider.dart';
// import 'package:testgetdata/provider/cart_provider.dart';
// import 'package:testgetdata/model/cart_menu_modelllll.dart';
// import 'package:testgetdata/views/home/widgets/bottom_sheet_keranjang.dart';
// import 'package:testgetdata/views/home/widgets/list_cart.dart';
// import 'package:testgetdata/views/home/widgets/pilih_tipe_pembayaran.dart';
// import 'package:testgetdata/views/home/widgets/pilih_tipe_pemesanan.dart';
// import 'package:testgetdata/views/home/widgets/pilihan_lokasi_ruangan.dart';
// import 'package:testgetdata/views/home/widgets/ringkasan_pembayaran_cart.dart';
// import 'package:testgetdata/views/theme.dart';

// class Cart extends StatefulWidget {
//   const Cart({Key? key}) : super(key: key);

//   @override
//   State<Cart> createState() => _CartState();
// }

// class _CartState extends State<Cart> {
//   TextEditingController namaPembeli = TextEditingController();
//   TextEditingController ruanganPembeli = TextEditingController();
//   TextEditingController catatan = TextEditingController();
//   List<Ruangan> listRuangan = [];
//   late final MidtransSDK _midtrans;
//   bool isLoading = false;
//   bool transactionCompleted = false;

//   List<String> tipePemesanan = [
//     'Ambil Sendiri',
//     'Pesan Antar',
//   ];
//   List<String> tipePembayaran = [
//     'Ambil Sendiri',
//     'Pesan Antar',
//   ];

//   int? plihPengantaran;
//   int? pilihRuangan;
//   String? plihPembayaran;

//   void initSDK() async {
//     print("JALANIN SDK MIDTRANS");
//     _midtrans = await MidtransSDK.init(
//       config: MidtransConfig(
//         // untuk debug
//         clientKey: 'SB-Mid-client-T9zZrTGN1ARTH8rb',
//         merchantBaseUrl:
//             'https://app.sandbox.midtrans.com/snap/v4/redirection/',

//         // untuk prod
//         // clientKey: 'Mid-client-aQsYyyZzJScqCS1X',
//         // merchantBaseUrl: 'https://app.midtrans.com/snap/v1/redirection/',

//         colorTheme: ColorTheme(
//           colorPrimary: Theme.of(context).colorScheme.secondary,
//           colorPrimaryDark: Theme.of(context).colorScheme.secondary,
//           colorSecondary: Theme.of(context).colorScheme.secondary,
//         ),
//       ),
//     );
//     _midtrans?.setUIKitCustomSetting(
//       skipCustomerDetailsPages: true,
//     );
//     _midtrans.setTransactionFinishedCallback((result) {
//       print(result.toJson());
//       if (result.transactionStatus == TransactionResultStatus.settlement) {
//         print('Navigating to /sukses_order');
//         setState(() {
//           transactionCompleted = true;
//         });
//         Provider.of<CartProvider>(context, listen: false).clearCart();
//         Navigator.pushNamed(context, '/sukses_order');
//       }
//       // else if (result.transactionStatus == TransactionResultStatus.cancel) {
//       //   String transactionId = result.orderId ?? 'Unknown ID';
//       //   print('Transaction ID: $transactionId');
//       // }
//       else {
//         // Handle other transaction statuses if needed
//         print("Transaction failed or was canceled");
//       }
//     });
//   }

//   // void cancelOrder(int id) async {
//   //   await orderCanceled(id);
//   // }

//   @override
//   void initState() {
//     super.initState();

//     AuthProvider authProvider =
//         Provider.of<AuthProvider>(context, listen: false);
//     UserModel user = authProvider.user;
//     plihPengantaran = null;
//     pilihRuangan = null;
//     pilihPembayaran = null;

//     fetchDataRuangan(user.token).then((value) {
//       setState(() {
//         listRuangan = value;
//       });
//     });

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       initSDK();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     AuthProvider authProvider = Provider.of<AuthProvider>(context);
//     UserModel user = authProvider.user;

//     final List<CartMenuModel> cart = Provider.of<CartProvider>(context).cart;

//     // if (cart.isEmpty && transactionCompleted == false) {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     Navigator.pop(context);
//     //   });
//     // }

//     return Scaffold(
//       backgroundColor: Color.fromARGB(255, 248, 248, 248),
//       appBar: AppBar(
//         scrolledUnderElevation: 0,
//         toolbarHeight: 50,
//         title: Text(
//           'Keranjang',
//           style: GoogleFonts.poppins(
//             fontWeight: FontWeight.bold,
//             fontSize: 20,
//             color: Colors.black,
//           ),
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.keyboard_backspace,
//             color: Colors.black,
//             size: 24,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           margin: const EdgeInsets.all(15),
//           child: Column(
//             children: [
//               Consumer<CartProvider>(
//                 builder: (context, data, _) {
//                   return ListView.builder(
//                     shrinkWrap: true,
//                     physics: const ScrollPhysics(),
//                     itemCount: data.cart.length,
//                     itemBuilder: (context, i) {
//                       // List item pembeli
//                       return ListCart(
//                         cart: data.cart[i],
//                       );
//                     },
//                   );
//                 },
//               ),
//               const SizedBox(
//                 height: 15,
//               ),
//               Consumer<CartProvider>(builder: (context, data, _) {
//                 return Column(
//                   children: [
//                     // Tipe Pemesanan
//                     PilihTipePemesanan(
//                       tipePemesanan: tipePemesanan,
//                       plihPengantaran: plihPengantaran,
//                       onPemesananSelected: (option) {
//                         setState(() {
//                           plihPengantaran = option;
//                           data.setIsAntar(option!);
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 8),

//                     // Lokasi Pengantaran
//                     if (plihPengantaran == 1)
//                       PilihLokasiRuangan(
//                         listRuangan: listRuangan,
//                         token: user.token,
//                         selectedLocation: pilihRuangan,
//                         onLocationSelected: (option) {
//                           setState(() {
//                             pilihRuangan = option;
//                             data.setRuanganId(option!);
//                           });
//                         },
//                       ),
//                     const SizedBox(height: 8),

//                     // Tipe pembayaran
//                     PilihTipePembayaran(
//                       tipePembayaran: tipePembayaran,
//                       pilihTipePembayaran: pilihPembayaran,
//                       selectedPembayaran: (option2) {
//                         setState(() {
//                           plihPembayaran = option2;
//                           data.setMetodePembayaran(option2!);
//                         });
//                       },
//                     ),
//                   ],
//                 );
//               }),
//               const SizedBox(
//                 height: 20,
//               ),

//               // Ringkasan Pembayaran
//               RingkasanPembayaranCart(),
//               const SizedBox(height: 5),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: context.watch<CartProvider>().isCartShow
//           ? Consumer<CartProvider>(
//               builder: (context, data, _) {
//                 return Container(
//                   margin: const EdgeInsets.all(15),
//                   height: 63,
//                   decoration: BoxDecoration(
//                     color: isLoading ? Colors.grey : primaryColor,
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   // child: InkWell(
//                   //   onTap: () {
//                   //     setState(() {
//                   //       isLoading = true;
//                   //     });
//                   //     Navigator.push(context, MaterialPageRoute(
//                   //       builder: (context) {
//                   //         return const Cart();
//                   //       },
//                   //     ));
//                   //   },
//                   child: InkWell(
//                     enableFeedback: !isLoading,
//                     onTap: isLoading
//                         ? () {}
//                         : () {
//                             if (plihPengantaran == null ||
//                                 (plihPengantaran == 1 &&
//                                     pilihRuangan == null) ||
//                                 plihPembayaran == null) {
//                               showDialog(
//                                 context: context,
//                                 builder: (BuildContext context) {
//                                   return Dialog(
//                                     shape: RoundedRectangleBorder(
//                                       borderRadius: BorderRadius.circular(10),
//                                     ),
//                                     child: Container(
//                                       padding: const EdgeInsets.all(25),
//                                       child: Column(
//                                         mainAxisSize: MainAxisSize.min,
//                                         // crossAxisAlignment:
//                                         //     CrossAxisAlignment.center,
//                                         children: [
//                                           const Text(
//                                             "Lengkapi informasi pesanan!",
//                                             style: TextStyle(
//                                               fontSize: 16,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           const SizedBox(height: 15),
//                                           const Text(
//                                             "Informasi pesanan anda belum lengkap, harap lengkapi terlebih dahulu",
//                                             style: TextStyle(
//                                               fontSize: 14,
//                                             ),
//                                             textAlign: TextAlign.center,
//                                           ),
//                                           const SizedBox(height: 20),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.center,
//                                             children: [
//                                               TextButton(
//                                                 onPressed: () {
//                                                   Navigator.of(context).pop();
//                                                 },
//                                                 style: ButtonStyle(
//                                                   shape:
//                                                       MaterialStateProperty.all<
//                                                           RoundedRectangleBorder>(
//                                                     RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               5.0),
//                                                       side: const BorderSide(
//                                                         color: Colors.grey,
//                                                       ),
//                                                     ),
//                                                   ),
//                                                   minimumSize:
//                                                       MaterialStateProperty.all(
//                                                           Size(100, 30)),
//                                                 ),
//                                                 child: const Text(
//                                                   "OK",
//                                                   style: TextStyle(
//                                                     color: Color.fromARGB(
//                                                         255, 99, 99, 99),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             } else {
//                               setState(() {
//                                 isLoading = true;
//                                 transactionCompleted == true;
//                               });
//                               Provider.of<CartProvider>(context, listen: false)
//                                   .buatTransaksi(context, user.token)
//                                   .then(
//                                 (value) {
//                                   print(value.status.toString());
//                                   print(value.messages.toString());
//                                   if (value.status == 'success') {
//                                     if (value.snap != null) {
//                                       print(value.snap!.token.toString());
//                                       _midtrans?.startPaymentUiFlow(
//                                         token: value.snap!.token,
//                                       );
//                                     } else {
//                                       print('berhasil');
//                                       Provider.of<CartProvider>(context,
//                                               listen: false)
//                                           .clearCart();
//                                       Navigator.pushNamed(
//                                           context, '/sukses_order');
//                                     }
//                                   } else {
//                                     print('gagal brooo');
//                                     // print($message);
//                                   }
//                                   setState(() {
//                                     isLoading = false;
//                                   });
//                                 },
//                               );
//                             }
//                           },
//                     child: Align(
//                       alignment: Alignment.center,
//                       child: isLoading
//                           ? Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Container(
//                                   width: 20,
//                                   height: 20,
//                                   child: const CircularProgressIndicator(
//                                     strokeWidth: 4,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   "Tunggu sebentar",
//                                   style: GoogleFonts.poppins(
//                                     color: Colors.white,
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w700,
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : Text(
//                               "Pesan sekarang",
//                               style: GoogleFonts.poppins(
//                                 color: Colors.white,
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),
//                   // ),
//                 );
//               },
//             )
//           : null,
//     );
//   }
// }

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
import 'package:testgetdata/views/home/widgets/bottom_sheet_keranjang.dart';
import 'package:testgetdata/views/home/widgets/list_cart.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/views/home/widgets/pilih_tipe_pemesanan.dart';
import 'package:testgetdata/views/home/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/views/home/widgets/ringkasan_pembayaran_cart.dart';
import 'package:testgetdata/views/home/widgets/sukses_order.dart';
import 'package:testgetdata/views/tenant/widgets/list_cart_kasir.dart';
import 'package:testgetdata/views/tenant/widgets/ringkasan_pembayaran_kasir.dart';
import 'package:testgetdata/views/theme.dart';

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
  late final MidtransSDK _midtrans;
  bool isLoading = false;
  bool transactionCompleted = false;

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

  void initSDK() async {
    print("JALANIN SDK MIDTRANS");
    _midtrans = await MidtransSDK.init(
      config: MidtransConfig(
        clientKey: 'SB-Mid-client-T9zZrTGN1ARTH8rb',
        merchantBaseUrl:
            'https://app.sandbox.midtrans.com/snap/v4/redirection/',
        colorTheme: ColorTheme(
          colorPrimary: Theme.of(context).colorScheme.secondary,
          colorPrimaryDark: Theme.of(context).colorScheme.secondary,
          colorSecondary: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
    _midtrans?.setUIKitCustomSetting(
      skipCustomerDetailsPages: true,
    );
    _midtrans.setTransactionFinishedCallback((result) {
      print(result.toJson());
      if (result.transactionStatus == TransactionResultStatus.settlement) {
        setState(() {
          transactionCompleted = true;
        });
        Provider.of<CartProvider>(context, listen: false).clearCart();
        Provider.of<KasirProvider>(context, listen: false).clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const SuksesOrder(),
          ),
          (route) => false,
        );
      } else {
        print("Transaction failed or was canceled");
      }
    });
  }

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initSDK();
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    final List<CartMenuModel> cart = Provider.of<CartProvider>(context).cart;
    final List<CartMenuModel> kasirCart =
        Provider.of<KasirProvider>(context).cart;

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
              // Consumer2<CartProvider, KasirProvider>(
              //   builder: (context, cartData, kasirData, _) {
              //     // Tentukan cart yang aktif
              //     List<CartMenuModel> activeCart = kasirData.cart.isNotEmpty
              //         ? kasirData.cart
              //         : cartData.cart;
              //     return ListView.builder(
              //       shrinkWrap: true,
              //       physics: const ScrollPhysics(),
              //       itemCount: activeCart.length,
              //       itemBuilder: (context, i) {
              //         // Gunakan item dari cart yang aktif
              //         return ListCart(cart: activeCart[i]);
              //       },
              //     );
              //   },
              // ),
              Consumer2<CartProvider, KasirProvider>(
                builder: (context, cartData, kasirData, _) {
                  // Tentukan cart yang aktif
                  List<CartMenuModel> activeCart = kasirData.cart.isNotEmpty
                      ? kasirData.cart
                      : cartData.cart;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: activeCart.length,
                    itemBuilder: (context, i) {
                      // Gunakan item dari cart yang aktif
                      if (kasirData.cart.isNotEmpty) {
                        // Jika sedang aktif di kasir, tampilkan dari ListCartKasir
                        return ListCartKasir(cart: activeCart[i]);
                      } else {
                        // Jika tidak aktif di kasir, tampilkan dari ListCart
                        return ListCart(cart: activeCart[i]);
                      }
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
                      if (!isKasirProviderActive) ...[
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
                        PilihTipePembayaran(
                          tipePembayaran: tipePembayaran,
                          pilihTipePembayaran: plihPembayaran,
                          selectedPembayaran: (option2) {
                            setState(() {
                              plihPembayaran = option2;
                              cartData.setMetodePembayaran(option2!);
                              kasirData.setMetodePembayaran(option2!);
                            });
                          },
                        ),
                      ],
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
              // const SizedBox(height: 20),
              // RingkasanPembayaranCart(),
              // const SizedBox(height: 5),
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
                            if (!kasirData.cart.isNotEmpty &&
                                (plihPengantaran == null ||
                                    (plihPengantaran == 1 &&
                                        pilihRuangan == null) ||
                                    plihPembayaran == null)) {
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
                                                          color: Colors.grey),
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
                                                          255, 99, 99, 99)),
                                                ),
                                              ),
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
                                transactionCompleted = true;
                              });

                              if (kasirData.cart.isNotEmpty) {
                                kasirData
                                    .buatTransaksi(context, user.token)
                                    .then((value) {
                                  kasirData.clearCart();
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
                                      _midtrans?.startPaymentUiFlow(
                                          token: value.snap!.token);
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
