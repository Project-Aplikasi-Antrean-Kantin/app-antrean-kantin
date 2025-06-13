import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/add_more_items_button.dart';
import 'package:testgetdata/presentation/widgets/bottom_navigation_cart_payment.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/card_selected_delivery_option_toggle.dart';
import 'package:testgetdata/presentation/widgets/list_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/presentation/widgets/ringkasan_pembayaran_cart.dart';

enum PaymentMethod { koin, cod }

class CartPage extends StatefulWidget {
  const CartPage({Key? key}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Ruangan> _roomList = [];
  PaymentMethod? _selectedPaymentMethod;
  DateTime? _lastFetch;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  void _showIncompleteLocationDialog() {
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        title: "Lokasi Kosong!",
        message: "Mohon pilih lokasi pengantaran untuk memudahkan driver 🫡",
        onConfirmCancle: () => Navigator.of(context).pop(),
        textButtonCancel: "OK",
        textButtonCancelColor: AppColors.primaryColor,
        cancelBorderColor: AppColors.primaryColor,
      ),
    );
  }

  // void _showConfirmOrderDialog(
  //   BuildContext context,
  //   KasirProvider kasirProvider,
  //   CartProvider cartProvider,
  //   CoinProvider coinProvider,
  //   UserModel user,
  //   PaymentMethod paymentMethod,
  //   int saldoCoin,
  // ) {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       bool isLoading = false;

  //       return StatefulBuilder(
  //         builder: (context, setState) => CustomAlert(
  //           title: "Konfirmasi Pesanan",
  //           message:
  //               "Yakin ingin membuat pesanan? Kamu tidak bisa membatalkan pesanan yang telah dibuat, ya.",
  //           textButtonCancel: "Bentar",
  //           textButtonCancelColor: AppColors.primaryColor,
  //           cancelBorderColor: AppColors.primaryColor,
  //           textButtonOk: "Yakin!",
  //           textButtonOkColor: Colors.white,
  //           okBorderColor: AppColors.primaryColor,
  //           isLoading: isLoading,
  //           onConfirmCancle:
  //               isLoading ? null : () => Navigator.of(context).pop(),
  //           onConfirmOk: isLoading
  //               ? null
  //               : () async {
  //                   setState(() => isLoading = true);
  //                   try {
  //                     await _handleTransaction(
  //                       context,
  //                       kasirProvider,
  //                       cartProvider,
  //                       coinProvider,
  //                       user,
  //                       paymentMethod,
  //                       saldoCoin,
  //                     );
  //                   } catch (e) {
  //                     setState(() => isLoading = false);
  //                     showDialog(
  //                       context: context,
  //                       builder: (context) => CustomAlert(
  //                         title: "Error",
  //                         message: "Gagal membuat pesanan: $e",
  //                         textButtonCancel: "OK",
  //                         onConfirmCancle: () => Navigator.pop(context),
  //                         textButtonCancelColor: AppColors.primaryColor,
  //                         cancelBorderColor: AppColors.primaryColor,
  //                       ),
  //                     );
  //                   }
  //                 },
  //         ),
  //       );
  //     },
  //   );
  // }
  void _showConfirmOrderBottomSheet(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    CoinProvider coinProvider,
    UserModel user,
    PaymentMethod paymentMethod,
    int saldoCoin,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: false,
      builder: (context) {
        bool isLoading = false;

        // ignore: deprecated_member_use
        return WillPopScope(
          onWillPop: () async => !isLoading,
          child: StatefulBuilder(
            builder: (context, setState) {
              // Get screen size using MediaQuery
              final screenSize = MediaQuery.of(context).size;
              final isSmallScreen =
                  screenSize.height < 600; // For very small screens

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    // Limit max height to 80% of screen height
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.8,
                    ),
                    padding: EdgeInsets.all(
                        screenSize.width * 0.05), // 5% of screen width
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      // Allow scrolling if content overflows
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Responsive Image
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.01),
                            child: Image.asset(
                              'assets/images/confirmation_order.png',
                              // Scale image to 40% of screen width
                              width: screenSize.width * 0.5,
                              height: screenSize.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          // Responsive Title
                          Text(
                            "Konfirmasi Pesanan",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen
                                  ? 16
                                  : 20, // Smaller font for small screens
                              color: AppColors.textColorBlack,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          // Responsive Message
                          Text(
                            "Yakin ingin membuat pesanan? Kamu tidak bisa membatalkan pesanan yang telah dibuat, ya.",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.textColorBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenSize.height * 0.03),
                          // Responsive Buttons
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  isEnabled: !isLoading,
                                  borderColor: AppColors.primaryColor,
                                  borderRadius: 100,
                                  height: screenSize.height *
                                      0.06, // 6% of screen height
                                  elevation: 0,
                                  color: AppColors.containerColorWhite,
                                  child: Text(
                                    "Kembali",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: isLoading
                                          ? AppColors.containerColorGrey
                                          : AppColors.primaryColor,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.03),
                              Expanded(
                                child: PrimaryButton(
                                  isLoading: isLoading,
                                  elevation: 0,
                                  height: screenSize.height * 0.06,
                                  borderRadius: 100,
                                  child: Text(
                                    "Buat Pesanan!",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: AppColors.textColorwhite,
                                    ),
                                  ),
                                  onPressed: () async {
                                    setState(() => isLoading = true);
                                    try {
                                      await _handleTransaction(
                                        context,
                                        kasirProvider,
                                        cartProvider,
                                        coinProvider,
                                        user,
                                        paymentMethod,
                                        saldoCoin,
                                      );
                                    } catch (e) {
                                      setState(() => isLoading = false);
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomAlert(
                                          title: "Error",
                                          message: "Gagal membuat pesanan: $e",
                                          textButtonCancel: "OK",
                                          onConfirmCancle: () =>
                                              Navigator.pop(context),
                                          textButtonCancelColor:
                                              AppColors.primaryColor,
                                          cancelBorderColor:
                                              AppColors.primaryColor,
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: 10,
                    child: GestureDetector(
                      onTap: isLoading ? null : () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textColorBlack,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _handleTransaction(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    CoinProvider coinProvider,
    UserModel user,
    PaymentMethod paymentMethod,
    int saldoCoin,
  ) async {
    cartProvider.setTransactionStatus(
        isLoading: true, isTransactionCompleted: true);

    if (kasirProvider.cart.isNotEmpty) {
      await kasirProvider.buatTransaksi(user.token);
      kasirProvider.clearCart();
      _navigateToSuccessPage(context);
    } else {
      final result = await cartProvider.createTransaction(context, user.token);
      if (result.status == 'success') {
        cartProvider.clearCart();
        _navigateToSuccessPage(context);
      } else {
        cartProvider.setTransactionStatus(isTransactionCompleted: false);
        throw Exception('Transaksi gagal');
      }
    }
    cartProvider.setTransactionStatus(isLoading: false);
  }

  void _navigateToSuccessPage(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      CustomPageBuilder(page: const OrderSuccess()),
      (route) => false,
    );
  }

  // PageRouteBuilder _buildPageRoute(Widget page) {
  //   return PageRouteBuilder(
  //     pageBuilder: (context, animation, secondaryAnimation) => page,
  //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
  //       const begin = Offset(1.0, 0.0);
  //       const end = Offset(0.0, 0.0);
  //       const curve = Curves.easeInOut;
  //       var tween =
  //           Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  //       var offsetAnimation = animation.drive(tween);
  //       return SlideTransition(position: offsetAnimation, child: child);
  //     },
  //   );
  // }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final user = authProvider.user;

    coinProvider.getCoinAmount(authProvider.user.token);

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'top-up berhasil') {
        _handleCoinCartByNotification(coinProvider, user);
      }
    });

    _selectedPaymentMethod =
        kasirProvider.isKasir ? PaymentMethod.cod : PaymentMethod.koin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      log("CartPage initState: roomId = ${cartProvider.roomId}");
      cartProvider.getOngkir(user.token);
      kasirProvider.getOngkir(user.token);
      TransactionRemoteDataSource().getRoomData(user.token).then((value) {
        setState(() {
          _roomList = value;
          // Validasi roomId jika tidak ada di _roomList
          if (cartProvider.roomId != null &&
              !value.any((ruangan) => ruangan.id == cartProvider.roomId)) {
            cartProvider.roomId == null;
          }
        });
      });
    });
  }

  void _handleCoinCartByNotification(
      CoinProvider coinProvider, UserModel user) {
    print("Handling top-up notification at ${DateTime.now()}");
    coinProvider.getCoinAmount(user.token);
    _lastFetch = DateTime.now();
  }

  @override
  void dispose() {
    // Cancel Firebase listeners to prevent accessing context after unmount
    _onMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final kasirProvider = Provider.of<KasirProvider>(context);
    final coinProvider = Provider.of<CoinProvider>(context);
    final user = authProvider.user;
    final screenSize = MediaQuery.of(context).size;

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
          onPressed: () => Navigator.pop(context),
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

              if (activeCart.isEmpty && !isKasirProviderActive) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                });
                return const SizedBox();
              }

              return Column(
                children: [
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, _) => ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeCart.length,
                      itemBuilder: (context, i) => ListCart(
                        cart: activeCart[i],
                        isKasir: isKasirProviderActive,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  AddMoreItemsButton(),
                  const SizedBox(height: 20),
                  if (!isKasirProviderActive) ...[
                    CardSelectedDeliveryOptionToggle(
                      cartProvider: cartProvider,
                      screenWidth: screenSize.width,
                    ),
                    if (cartProvider.selectedDeliveryOption == 1) ...[
                      const SizedBox(height: 20),
                      PilihLokasiRuangan(
                        listRuangan: _roomList,
                        token: user.token,
                        selectedLocation: cartProvider.roomId,
                        onLocationSelected: (option) {
                          cartProvider.setIdRoom(option!);
                        },
                      )
                    ],
                  ],
                  const SizedBox(height: 20),
                  RingkasanPembayaranCart(isKasir: isKasirProviderActive),
                  const SizedBox(height: 5),
                ],
              );
            },
          ),
        ),
      ),
      bottomNavigationBar: context.watch<CartProvider>().isCartVisible ||
              context.watch<KasirProvider>().isCartVisible
          ? Consumer<CoinProvider>(
              builder: (context, coinProvider, _) {
                return BottomNavigationCartPayment(
                  cartProvider: cartProvider,
                  kasirProvider: kasirProvider,
                  coinProvider: coinProvider,
                  user: user,
                  saldoCoin: coinProvider.saldoKoin,
                  selectedPaymentMethod: _selectedPaymentMethod,
                  onPaymentMethodSelected: (method) =>
                      setState(() => _selectedPaymentMethod = method),
                  onConfirmOrder: () => _showConfirmOrderBottomSheet(
                    context,
                    kasirProvider,
                    cartProvider,
                    coinProvider,
                    user,
                    _selectedPaymentMethod!,
                    coinProvider.saldoKoin,
                  ),
                  onIncompleteData: _showIncompleteLocationDialog,
                );
              },
            )
          : null,
    );
  }
}
