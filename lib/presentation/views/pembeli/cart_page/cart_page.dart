import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/delivery_option.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/purchase_type.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/detail_pesanan.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/show_confirm_page.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/voucher_section.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_voucher_page.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/bottom_navigation_cart_payment.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/ringkasan_pembayaran_cart.dart';

enum PaymentMethod { koin, qris }

class CartPage extends StatefulWidget {
  final String? tenantId;
  const CartPage({Key? key, this.tenantId}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Ruangan> _roomList = [];
  PaymentMethod _selectedPaymentMethod = PaymentMethod.koin;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  bool _hasPopped = false;

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

  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isInit) {
        _isInit = true;
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        cartProvider.clearRoomIdAndOngkir();
        cartProvider.getActiveDriver(authProvider.user.token);
        cartProvider
            .fetchCashback(authProvider.user.token, true)
            .then((listCashback) {
          cartProvider.fetchVoucher(authProvider.user.token, listCashback);
        });
        cartProvider.syncCartWithServer(authProvider.user.token);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);
    final user = authProvider.user;

    topUpProvider.setTopUp().then((_) async {
      if (topUpProvider.topUp != null) {
        final kodeBayar = topUpProvider.topUp!.kodeBayar;
        await topUpProvider.getVirtualAccount(user.token, kodeBayar);
      }
      coinProvider.getCoinAmount(user.token);
    });

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'top-up berhasil') {
        _handleCoinCartByNotification(coinProvider, user);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      TransactionRemoteDataSource().getRoomData(user.token).then((value) {
        if (!mounted) return; // ⛑️ Cegah crash jika widget sudah dispose
        setState(() {
          cartProvider.setListRuangan(value);
          _roomList = value;
          if (cartProvider.roomId != null &&
              !value.any((ruangan) => ruangan.id == cartProvider.roomId)) {
            cartProvider.roomId = null; // ❗ perbaikan juga: bukan == null
          }
        });
      });
    });
  }

  void _handleCoinCartByNotification(
      CoinProvider coinProvider, UserModel user) {
    coinProvider.getCoinAmount(user.token);
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
    final user = authProvider.user;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.whiteColor100,
        surfaceTintColor: AppColors.backgroundColor,
        title: const Text("Pembayaran",
            style: TextStyle(
                color: AppColors.textColorBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final selectedRoom = _roomList.firstWhereOrNull(
                  (e) => e.id == cartProvider.roomId,
                );
                final gedung = selectedRoom?.gedung;
                final ongkirReguler = (gedung?.ongkir ?? 0) +
                    (cartProvider.totalItemCountSelected > 10
                        ? (cartProvider.totalItemCountSelected - 10) * 500
                        : 0) +
                    (cartProvider.selectedCartTenant.length >= 2
                        ? (gedung?.ongkirMultitenant ?? 0)
                        : 0);

                final ongkirExpress = (gedung?.ongkir ?? 0) +
                    3000 +
                    (cartProvider.totalItemCountSelected > 10
                        ? (cartProvider.totalItemCountSelected - 10) * 500
                        : 0) +
                    (cartProvider.selectedCartTenant.length >= 2
                        ? (gedung?.ongkirMultitenant ?? 0)
                        : 0);
                final voucher = cartProvider.selectedVoucher ??
                    cartProvider.recommendedVoucher;
                final recommendedCashback = cartProvider.recommendedCashback;
                if (cartProvider.totalItemCountSelected == 0 && !_hasPopped) {
                  _hasPopped = true;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                  });
                  return const SizedBox();
                }

                if (cartProvider.isFetchingActiveDriver == true ||
                    cartProvider.isFetchingVoucher == true ||
                    cartProvider.isFetchCashback == true) {
                  return ShimmerCard(pageType: 'cartPage');
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 8,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Detail Pesanan',
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      DetailPesanan(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Tipe Pembelian',
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      ...[
                        PurchaseType(cartProvider: cartProvider),
                        if (cartProvider.selectedDeliveryOption == 1) ...[
                          PilihLokasiRuangan(
                            onChange: (value) {
                              cartProvider.setCatatanLokasi(value);
                            },
                            listRuangan: _roomList,
                            token: user.token,
                            selectedLocation: cartProvider.roomId,
                            onLocationSelected: (option) {
                              cartProvider.setIdRoom(option!);
                              final roomSelected = _roomList.firstWhere(
                                  (element) => element.id == option);
                              cartProvider.getOngkir(
                                  user.token,
                                  roomSelected.gedung.ongkir,
                                  roomSelected.gedung.ongkirMultitenant);
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              "Opsi Pengantaran",
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor400,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          DeliveryOption(
                              isPriority: cartProvider.priority,
                              roomId: cartProvider.roomId,
                              ongkirExpress: ongkirExpress,
                              ongkirReguler: ongkirReguler,
                              onTapExpress: () {
                                if (cartProvider.priority == 0)
                                  cartProvider.setIsPriority(1);
                              },
                              onTapReguler: () {
                                if (cartProvider.priority == 1)
                                  cartProvider.setIsPriority(0);
                              }),
                        ],
                      ],
                      if (cartProvider.recommendedCashback != null ||
                          cartProvider.recommendedVoucher != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            "Voucher ${cartProvider.selectedVoucher != null ? 'Terpilih' : 'Rekomendasi'}",
                            style: GoogleFonts.poppins(
                                color: AppColors.blackColor400,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      if (cartProvider.recommendedCashback != null ||
                          cartProvider.recommendedVoucher != null)
                        VoucherSection(
                          isSelected: cartProvider.selectedVoucher != null,
                          isRecommendedCashback: recommendedCashback != null,
                          title: _voucherTitle(cartProvider),
                          subtitle: _voucherSubtitle(cartProvider),
                          onTap: () {
                            Navigator.push(
                              context,
                              CustomPageBuilder(
                                page: DetailVoucherPage(
                                  fromProfile: false,
                                  voucher: voucher,
                                  cashback: recommendedCashback,
                                ),
                              ),
                            );
                          },
                          canClaim: cartProvider.selectedVoucher == null,
                          onClaim: () async {
                            if (recommendedCashback != null) {
                              await cartProvider.getCashback(
                                  user.token, recommendedCashback.referralCode);
                              CustomSnackbar.success(
                                'Voucher berhasil diklaim',
                              );
                            } else if (voucher != null) {
                              cartProvider.setSelectedVoucher(voucher);
                              CustomSnackbar.success(
                                'Voucher berhasil dipilih',
                              );
                            }
                          },
                        ),
                      if (cartProvider.selectedVoucher != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.infoColor100,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.infoColor),
                              ),
                              child: Row(
                                spacing: 16,
                                children: [
                                  Image.asset(
                                    'assets/images/icon-koin-blue.png',
                                    width: 32,
                                    height: 32,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Yeiy! Cashback ${(cartProvider.selectedVoucher!.cashback.value * 100).toInt()}% jadi milik kamu",
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: AppColors.blackColor400),
                                        ),
                                        Text(
                                            "Cashback ${(cartProvider.selectedVoucher!.cashback.value * 100).toInt()}% akan masuk ke FoodLAB koin milik kamu maksimal 1 x 24 jam",
                                            style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12,
                                              color: AppColors.blackColor400,
                                            ))
                                      ],
                                    ),
                                  )
                                ],
                              )),
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: RingkasanPembayaranCart(),
                      ),
                      SizedBox(
                        height: 40,
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
      bottomNavigationBar:
          context.watch<CartProvider>().totalItemCountSelected > 0
              ? SafeArea(
                  child: Consumer<CoinProvider>(
                    builder: (context, coinProvider, _) {
                      return BottomNavigationCartPayment(
                        cartProvider: cartProvider,
                        coinProvider: coinProvider,
                        user: user,
                        saldoCoin: coinProvider.saldoKoin,
                        selectedPaymentMethod: _selectedPaymentMethod,
                        onPaymentMethodSelected: (method) =>
                            setState(() => _selectedPaymentMethod = method),
                        onConfirmOrder: () => showConfirmOrderBottomSheet(
                          context,
                          cartProvider,
                          coinProvider,
                          user,
                          _selectedPaymentMethod,
                          coinProvider.saldoKoin,
                        ),
                        onIncompleteData: _showIncompleteLocationDialog,
                      );
                    },
                  ),
                )
              : null,
    );
  }

  String _voucherTitle(CartProvider cart) {
    if (cart.selectedVoucher != null) {
      final v = cart.selectedVoucher!.cashback;
      return "Cashback ${(v.value * 100).toInt()}% maks ${v.maxCashback ~/ 1000}rb";
    }
    if (cart.recommendedCashback != null) {
      final v = cart.recommendedCashback!;
      return "Cashback ${(v.value * 100).toInt()}% maks ${v.maxCashback ~/ 1000}rb";
    }
    final v = cart.recommendedVoucher!.cashback;
    return "Cashback ${(v.value * 100).toInt()}% maks ${v.maxCashback ~/ 1000}rb";
  }

  String _voucherSubtitle(CartProvider cart) {
    if (cart.selectedVoucher != null) {
      return "Min. pembelian ${cart.selectedVoucher!.cashback.minimalOrder ~/ 1000}rb";
    }
    final cb = cart.recommendedCashback ?? cart.recommendedVoucher!.cashback;
    return "Min. pembelian ${cb.minimalOrder ~/ 1000}rb";
  }
}
