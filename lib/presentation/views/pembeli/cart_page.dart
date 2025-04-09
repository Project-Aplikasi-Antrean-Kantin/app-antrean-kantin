import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:midtrans_sdk/midtrans_sdk.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/data/remote/fetch_data_ruangan.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/list_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/presentation/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/presentation/widgets/bottom_navigation_button.dart';
import 'package:testgetdata/presentation/widgets/ringkasan_pembayaran_cart.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Ruangan-related
  List<Ruangan> _roomList = [];

  // Midtrans SDK
  late final MidtransSDK _midtrans;

  // Transaction state
  int? _selectedRoom;
  // int? _selectedDeliveryOption;
  String? _selectedPaymentMethod;
  bool transactionCompleted = false;
  void _incompleteDataDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Data Tidak Lengkap!",
          message:
              "Harap isi data pemesanan terlebih dahulu sebelum melanjutkan.",
          onConfirmCancle: () {
            Navigator.of(context).pop(); // close dialog
          },
          textButtonCancel: "OK",
          textButtonCancelColor: AppColors.primaryColor,
          cancelBorderColor: AppColors.primaryColor,
        );
      },
    );
  }

  void _balanceCoinLow(coin, email) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomAlert(
          title: "Koin anda kurang",
          message:
              "Saldo koin anda kurang, harap top up terlebih dahulu sebelum melanjutkan.",
          onConfirmCancle: () {
            Navigator.of(context).pop(); // close dialog
          },
          textButtonCancel: "Tutup",
          textButtonCancelColor: AppColors.primaryColor,
          cancelBorderColor: AppColors.primaryColor,
          textButtonOk: "Top Up",
          onConfirmOk: () {
            Navigator.pushReplacement(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    TopupPage(
                  coin: coin,
                  email: email,
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset(0.0, 0.0);
                  const curve = Curves.easeInOut;

                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);

                  return SlideTransition(
                    position: offsetAnimation,
                    child: child,
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  // void handleTransaction(
  //   BuildContext context,
  //   KasirProvider kasirProvider,
  //   CartProvider cartProvider,
  //   CoinProvider coinProvider,
  //   UserModel user,
  //   int? selectRoom,
  //   String paymentMethod, // ✅ Tambahkan metode pembayaran sebagai parameter
  // ) {
  //   Route SuccessPageUser() {
  //     return PageRouteBuilder(
  //       pageBuilder: (context, animation, secondaryAnimation) =>
  //           const OrderSuccess(),
  //       transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //         const begin = Offset(1.0, 0.0);
  //         const end = Offset(0.0, 0.0);
  //         const curve = Curves.easeInOut;

  //         var tween =
  //             Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //         var offsetAnimation = animation.drive(tween);

  //         return SlideTransition(
  //           position: offsetAnimation,
  //           child: child,
  //         );
  //       },
  //     );
  //   }

  //   if (!kasirProvider.cart.isNotEmpty &&
  //       !cartProvider.isCartValid(selectRoom)) {
  //     _incompleteDataDialog();
  //     return;
  //   } else {
  //     cartProvider.setTransactionStatus(
  //       isLoading: true,
  //       isTransactionCompleted: true,
  //     );

  //     if (kasirProvider.cart.isNotEmpty) {
  //       kasirProvider.buatTransaksi(user.token).then((value) {
  //         kasirProvider.clearCart();
  //         Navigator.pushAndRemoveUntil(
  //           context,
  //           SuccessPageUser(),
  //           (route) => false,
  //         );
  //         cartProvider.setTransactionStatus(isLoading: false);
  //       });
  //     } else {
  //       cartProvider.createTransaction(context, user.token).then((value) async {
  //         if (value.status == 'success') {
  //           int totalHarga = cartProvider.getTotal();

  //           // bayar dengan metode transfer (bug)
  //           if (paymentMethod == 'transfer') {
  //             if (value.snap != null) {
  //               _midtrans.startPaymentUiFlow(token: value.snap!.token);
  //             } else {
  //               cartProvider.clearCart();
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 SuccessPageUser(),
  //                 (route) => false,
  //               );
  //             }
  //           }
  //           // bayar dengan metode coin (bug)
  //           else if (paymentMethod == 'koin') {
  //             bool success =
  //                 await coinProvider.deductCoin(user.token, totalHarga);
  //             if (success) {
  //               cartProvider.clearCart();
  //               Navigator.pushAndRemoveUntil(
  //                 context,
  //                 SuccessPageUser(),
  //                 (route) => false,
  //               );
  //             } else {
  //               print('Gagal mengurangi saldo koin');
  //               return;
  //             }
  //           }

  //           // bayar dengan metode bayar tunai (udah bisa)
  //           else if (paymentMethod == 'cod') {
  //             cartProvider.clearCart();
  //             Navigator.pushAndRemoveUntil(
  //               context,
  //               SuccessPageUser(),
  //               (route) => false,
  //             );
  //           }
  //         } else {
  //           print('Transaksi gagal');
  //         }
  //         cartProvider.setTransactionStatus(isLoading: false);
  //       });
  //     }
  //   }
  // }
  void handleTransaction(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    CoinProvider coinProvider,
    UserModel user,
    int? selectRoom,
    String paymentMethod,
    int saldoCoin,
  ) async {
    Route SuccessPageUser() {
      return PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const OrderSuccess(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset(0.0, 0.0);
          const curve = Curves.easeInOut;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      );
    }

    if (!kasirProvider.cart.isNotEmpty &&
        !cartProvider.isCartValid(selectRoom)) {
      _incompleteDataDialog();
      return;
    }

    cartProvider.setTransactionStatus(
      isLoading: true,
      isTransactionCompleted: true,
    );

    // CEK SALDO KOIN SEBELUM MEMBUAT TRANSAKSI
    if (paymentMethod == 'koin') {
      int totalHarga = cartProvider.getTotal();
      bool success = await coinProvider.deductCoin(user.token, totalHarga);

      if (!success) {
        print('Gagal mengurangi saldo koin, transaksi dibatalkan.');
        _balanceCoinLow(saldoCoin, user.email);
        cartProvider.setTransactionStatus(isLoading: false);
        return;
      }
    }

    if (kasirProvider.cart.isNotEmpty) {
      kasirProvider.buatTransaksi(user.token).then((value) {
        kasirProvider.clearCart();
        Navigator.pushAndRemoveUntil(
          context,
          SuccessPageUser(),
          (route) => false,
        );
        cartProvider.setTransactionStatus(isLoading: false);
      });
    } else {
      // BUAT TRANSAKSI JIKA SEMUA SYARAT TERPENUHI
      cartProvider.createTransaction(context, user.token).then((value) {
        if (value.status == 'success') {
          if (paymentMethod == 'transfer') {
            if (value.snap != null) {
              _midtrans.startPaymentUiFlow(token: value.snap!.token);
            } else {
              cartProvider.clearCart();
              Navigator.pushAndRemoveUntil(
                context,
                SuccessPageUser(),
                (route) => false,
              );
            }
          }
          // ✅ Pembayaran dengan koin (sudah dicek sebelumnya)
          else if (paymentMethod == 'koin') {
            cartProvider.clearCart();
            Navigator.pushAndRemoveUntil(
              context,
              SuccessPageUser(),
              (route) => false,
            );
          }
          // ✅ Pembayaran COD (Tunai)
          else if (paymentMethod == 'cod') {
            cartProvider.clearCart();
            Navigator.pushAndRemoveUntil(
              context,
              SuccessPageUser(),
              (route) => false,
            );
          }
        } else {
          print('Transaksi gagal');
        }
        cartProvider.setTransactionStatus(isLoading: false);
      });
    }
  }

  @override
  void initState() {
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    final user = authProvider.user;

    // Set the initial value of plihPengantaran and pilihRuangan to null
    _selectedRoom = null;
    _selectedPaymentMethod = kasirProvider.isKasir ? 'cod' : 'koin';
    // _selectedPaymentMethod = "koin";

    context.read<CoinProvider>().fetchData(user.token);

    // Fetch the list of ruangan from the API using the user's token
    fetchDataRuangan(user.token).then((value) {
      setState(() {
        // Set the list of ruangan to the state of this widget
        _roomList = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final int saldoCoin = context.watch<CoinProvider>().saldoKoin;

    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        title: Text(
          'Pembayaran',
          style: GoogleFonts.poppins(
            fontWeight: medium,
            fontSize: 18,
            color: AppColors.textColorBlack,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: AppColors.textColorBlack,
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
          child: Consumer2<CartProvider, KasirProvider>(
            builder: (context, cartProvider, kasirProvider, _) {
              final activeCart = kasirProvider.cart.isNotEmpty
                  ? kasirProvider.cart
                  : cartProvider.cart;
              final isKasirProviderActive = kasirProvider.cart.isNotEmpty;

              // back to menu if cart empty
              if (activeCart.isEmpty && !isKasirProviderActive) {
                Future.delayed(Duration.zero, () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                });
              }

              return Column(
                children: [
                  // The list of items in the cart
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const ScrollPhysics(),
                    itemCount: activeCart.length,
                    itemBuilder: (context, i) {
                      return ListCart(
                        cart: activeCart[i],
                        isKasir: isKasirProviderActive,
                      );
                    },
                  ),
                  const SizedBox(height: 15),

                  Container(
                    margin: EdgeInsets.only(bottom: 20, top: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Pesanan masih kurang?",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.textColorBlack,
                                fontWeight: semibold,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              "Tambah menu lainnya disini",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.textColorBlack,
                                fontWeight: regular,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                        PrimaryButton(
                          elevation: 0,
                          color: AppColors.primaryColor,
                          borderColor: AppColors.primaryColor,
                          // height: 45,
                          width: 25,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            'Tambah',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: AppColors.textColorwhite,
                              fontWeight: semibold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // The form for selecting the type of delivery
                  if (!isKasirProviderActive) ...[
                    Column(
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Tipe Pemesanan',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: semibold,
                              color: AppColors.textColorBlack,
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                        ToggleSwitch(
                          initialLabelIndex:
                              cartProvider.selectedDeliveryOption == 1 ? 0 : 1,
                          minWidth: (screenSize.width - 30) / 2,
                          labels: const ['Pesan Antar', 'Ambil Sendiri'],
                          activeBgColor: [AppColors.primaryColor],
                          activeFgColor: AppColors.backgroundColor,
                          activeBorders: [
                            Border.all(color: AppColors.primaryColor),
                          ],
                          inactiveFgColor: AppColors.textColorBlack,
                          inactiveBgColor: AppColors.backgroundColor,
                          borderColor: [AppColors.textColorBlack],
                          borderWidth: 1,
                          cornerRadius: 5,
                          onToggle: (index) {
                            cartProvider.setDeliveryOption(index == 0 ? 1 : 0);
                          },
                        ),
                      ],
                    ),

                    // The location selector (only visible if the user selects "Pesan Antar")
                    if (cartProvider.selectedDeliveryOption == 1) ...[
                      SizedBox(height: 20),
                      PilihLokasiRuangan(
                        listRuangan: _roomList,
                        token: user.token,
                        selectedLocation: _selectedRoom,
                        onLocationSelected: (option) {
                          setState(() {
                            _selectedRoom = option;
                            cartProvider.setIdRoom(option!);
                          });
                        },
                      ),
                    ],
                  ],
                  const SizedBox(height: 20),

                  // The summary of the order (either for the user or for the kasir)
                  RingkasanPembayaranCart(
                    isKasir: isKasirProviderActive,
                  ),
                  const SizedBox(height: 5),
                ],
              );
            },
          ),
        ),
      ),

      // The bottom navigation bar
      bottomNavigationBar: context.watch<CartProvider>().isCartVisible ||
              context.watch<KasirProvider>().isCartVisible
          ? Consumer3<CartProvider, KasirProvider, CoinProvider>(
              builder: (context, cartProvider, kasirProvider, coinProvider, _) {
                final isKasirProviderActive = kasirProvider.cart.isNotEmpty;
                final isCartProviderActive = cartProvider.cart.isNotEmpty;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 0.2,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PilihTipePembayaran(
                        isCartActive: isCartProviderActive,
                        isKasirActive: isKasirProviderActive,
                        // tipePembayaran: _paymentType,
                        pilihTipePembayaran: _selectedPaymentMethod,
                        selectedPembayaran: (option2) {
                          setState(() {
                            _selectedPaymentMethod = option2;
                            cartProvider.setPaymentMethod(option2!);
                            kasirProvider.setMetodePembayaran(option2);
                            log("total: " + cartProvider.getTotal().toString());
                          });
                        },
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      BottomNavigationButton(
                        isLoading: cartProvider.isLoading,
                        color: AppColors.primaryColor,
                        onTap: () {
                          if (_selectedPaymentMethod == null) {
                            _incompleteDataDialog();
                            return;
                          }
                          handleTransaction(
                            context,
                            kasirProvider,
                            cartProvider,
                            coinProvider,
                            user,
                            _selectedRoom,
                            _selectedPaymentMethod!,
                            saldoCoin,
                          );
                        },
                      )
                    ],
                  ),
                );
              },
            )
          : null,
    );
  }
}
