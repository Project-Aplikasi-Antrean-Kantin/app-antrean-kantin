import 'dart:developer';
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
import 'package:testgetdata/presentation/widgets/delivery_option_toggle.dart';
import 'package:testgetdata/presentation/widgets/list_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
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

  void _showBalanceCoinLowDialog(int coin, String email) {
    showDialog(
      context: context,
      builder: (context) => CustomAlert(
        title: "Transaksi Gagal!",
        message:
            "Saldo koin anda kurang, harap isi ulang saldo koin sebelum melanjutkan.",
        onConfirmCancle: () => Navigator.of(context).pop(),
        textButtonCancel: "Tutup",
        textButtonCancelColor: AppColors.primaryColor,
        cancelBorderColor: AppColors.primaryColor,
        textButtonOk: "Top Up",
        onConfirmOk: () => Navigator.push(
          context,
          CustomPageBuilder(page: TopupPage(coin: coin, email: email)),
        ),
      ),
    );
  }

  void _showConfirmOrderDialog(
    BuildContext context,
    KasirProvider kasirProvider,
    CartProvider cartProvider,
    CoinProvider coinProvider,
    UserModel user,
    int? selectedRoom,
    PaymentMethod paymentMethod,
    int saldoCoin,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) => CustomAlert(
            title: "Konfirmasi Pesanan",
            message:
                "Yakin ingin membuat pesanan? Kamu tidak bisa membatalkan pesanan yang telah dibuat, ya.",
            textButtonCancel: "Bentar",
            textButtonCancelColor: AppColors.primaryColor,
            cancelBorderColor: AppColors.primaryColor,
            textButtonOk: "Yakin!",
            textButtonOkColor: Colors.white,
            okBorderColor: AppColors.primaryColor,
            isLoading: isLoading,
            onConfirmCancle:
                isLoading ? null : () => Navigator.of(context).pop(),
            onConfirmOk: isLoading
                ? null
                : () async {
                    setState(() => isLoading = true);
                    try {
                      await _handleTransaction(
                        context,
                        kasirProvider,
                        cartProvider,
                        coinProvider,
                        user,
                        selectedRoom,
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
                          onConfirmCancle: () => Navigator.pop(context),
                          textButtonCancelColor: AppColors.primaryColor,
                          cancelBorderColor: AppColors.primaryColor,
                        ),
                      );
                    }
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
    int? selectedRoom,
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
    final user = authProvider.user;

    _selectedPaymentMethod =
        kasirProvider.isKasir ? PaymentMethod.cod : PaymentMethod.koin;
    context.read<CoinProvider>().getCoinAmount(user.token);

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

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final kasirProvider = Provider.of<KasirProvider>(context);
    final coinProvider = Provider.of<CoinProvider>(context);
    final user = authProvider.user;
    final saldoCoin = context.watch<CoinProvider>().saldoKoin;
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
                    DeliveryOptionToggle(
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
          ? BottomNavigationCartPayment(
              cartProvider: cartProvider,
              kasirProvider: kasirProvider,
              coinProvider: coinProvider,
              user: user,
              saldoCoin: saldoCoin,
              selectedPaymentMethod: _selectedPaymentMethod,
              selectedRoom: cartProvider.roomId,
              onPaymentMethodSelected: (method) =>
                  setState(() => _selectedPaymentMethod = method),
              onConfirmOrder: () => _showConfirmOrderDialog(
                context,
                Provider.of<KasirProvider>(context, listen: false),
                Provider.of<CartProvider>(context, listen: false),
                Provider.of<CoinProvider>(context, listen: false),
                user,
                cartProvider.roomId,
                _selectedPaymentMethod!,
                saldoCoin,
              ),
              onBalanceCoinLow: () =>
                  _showBalanceCoinLowDialog(saldoCoin, user.email),
              onIncompleteData: _showIncompleteLocationDialog,
            )
          : null,
    );
  }
}
