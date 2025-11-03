import 'dart:async';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_voucher_page.dart';
import 'package:testgetdata/presentation/views/pembeli/list_promo_page.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/add_more_items_button.dart';
import 'package:testgetdata/presentation/widgets/bottom_navigation_cart_payment.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/card_selected_delivery_option_toggle.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/list_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_alert.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/presentation/widgets/sukses_order.dart';
import 'package:testgetdata/presentation/widgets/pilihan_lokasi_ruangan.dart';
import 'package:testgetdata/presentation/widgets/ringkasan_pembayaran_cart.dart';

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
  DateTime? _lastFetch;
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
        return SafeArea(
          child: WillPopScope(
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

                                        Fluttertoast.showToast(
                                            msg: e.toString().replaceFirst(
                                                'Exception: ', ''),
                                            textColor: Colors.white,
                                            backgroundColor:
                                                AppColors.errorColor,
                                            toastLength: Toast.LENGTH_LONG);
                                      } finally {
                                        setState(() => isLoading = false);
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
    int total = cartProvider.totalItemCount;
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    final result = await cartProvider.createTransaction(
        context, user.token, paymentMethod.name);
    if (result?.status == 'success') {
      print('Transaction successful ${result?.pesanan}');
      historyProvider.updateSelectedPesanan(result!.pesanan);
      _navigateToSuccessPage(
          context, cartProvider, result.pesanan, user, historyProvider);
      cartProvider.clearCart(true);
    } else {
      print(
        'Transaction failed ${result?.messages}',
      );
      cartProvider.setTransactionStatus(isTransactionCompleted: false);
    }

    cartProvider.setTransactionStatus(isLoading: false);
  }

  // void _navigateToSuccessPage(
  //     BuildContext context, CartProvider cartProvider, Pesanan pesanan) {
  //   Navigator.pushAndRemoveUntil(
  //     context,
  //     CustomPageBuilder(
  //         page: OrderSuccess(
  //       pesanan: pesanan,
  //     )),
  //     (route) => false,
  //   );
  // }

  void _navigateToSuccessPage(
    BuildContext context,
    CartProvider cartProvider,
    Pesanan pesanan,
    UserModel user,
    HistoryProvider historyProvider,
  ) {
    Navigator.pushAndRemoveUntil(
      context,
      CustomPageBuilder(
        page: NavbarHome(
          initialRouteAfterOpen: DetailRiwayat(
            fromCartPage: true,
            label: "Beli",
            token: user.token.toString(),
            pesanan: pesanan,
            refreshData: () {
              TransactionRemoteDataSource()
                  .getOrderById(user.token, pesanan.id.toString())
                  .then((pesanan) {
                historyProvider.updateSelectedPesanan(pesanan);
                historyProvider.updatedPesanan(pesanan, 'user');
              });
            },
          ),
          pageIndex:
              user.menu.indexWhere((element) => element.url == '/riwayat'),
        ),
      ),
      (route) => false,
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
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
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

    // _selectedPaymentMethod =
    //     kasirProvider.isKasir ? PaymentMethod.cod : PaymentMethod.koin;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      TransactionRemoteDataSource().getRoomData(user.token).then((value) {
        if (!mounted) return; // ⛑️ Cegah crash jika widget sudah dispose
        setState(() {
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
            child: Consumer2<CartProvider, KasirProvider>(
              builder: (context, cartProvider, kasirProvider, _) {
                final activeCart = cartProvider.cart;
                // final isKasirProviderActive = kasirProvider.cart.isNotEmpty;
                print('cartProvider ${cartProvider.cart}');
                if (activeCart.isEmpty && !_hasPopped) {
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
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          spacing: 12,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cartProvider.currentTenant?.namaTenant ?? '',
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            Consumer<CartProvider>(
                              builder: (context, cartProvider, _) =>
                                  ListView.separated(
                                separatorBuilder: (context, index) {
                                  return SizedBox(height: 8);
                                },
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activeCart.length,
                                itemBuilder: (context, i) => Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: ImageByUrl(
                                        key: Key(
                                            '${activeCart[i].menuId}-${activeCart[i].menuNama}'),
                                        url: activeCart[i].menuGambar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalizeFirstLetter(
                                                activeCart[i].menuNama),
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          activeCart[i].catatan != '' &&
                                                  activeCart[i].catatan != null
                                              ? Text(
                                                  '${activeCart[i].catatan}',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                )
                                              : Text(
                                                  'Catatan Kosong',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CustomPageBuilder(
                                                      page: DetailFoodPage(
                                                          cartItem:
                                                              activeCart[i],
                                                          addNewItem: true,
                                                          catatan: activeCart[i]
                                                              .catatan,
                                                          tenant: cartProvider
                                                              .currentTenant!)));
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 6, vertical: 4),
                                              decoration: BoxDecoration(
                                                  color: AppColors.infoColor,
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Row(
                                                spacing: 8,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  HugeIcon(
                                                      size: 16,
                                                      icon: HugeIcons
                                                          .strokeRoundedEdit02,
                                                      color:
                                                          AppColors.whiteColor),
                                                  Text('Edit',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: AppColors
                                                            .whiteColor,
                                                        fontSize: 12,
                                                      )),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                              activeCart[i].menuPrice *
                                                  activeCart[i].count),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.blackColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                              color: AppColors.primaryColor,
                                              width: 2,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize
                                                .min, // biar pas dengan isi
                                            children: [
                                              // Tombol -
                                              GestureDetector(
                                                onTap: () => cartProvider
                                                    .removeItemFromTenantCart(
                                                        catatan: activeCart[i]
                                                            .catatan,
                                                        cartProvider
                                                            .selectedCartTenant!
                                                            .tenantId,
                                                        activeCart[i].menuId,
                                                        context),
                                                child: Container(
                                                  width: 28,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    // color: AppColors
                                                    //     .backgroundColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(10),
                                                      bottomLeft:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '-',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),

                                              // Counter
                                              Container(
                                                width: 28,
                                                height: 32,
                                                alignment: Alignment.center,
                                                // decoration: BoxDecoration(
                                                //   border: Border.symmetric(
                                                //     vertical: BorderSide(
                                                //       color: AppColors
                                                //           .primaryColor,
                                                //       width: 2,
                                                //     ),
                                                //   ),
                                                // ),
                                                child: TextFormField(
                                                  key: ValueKey(
                                                      activeCart[i].count),
                                                  initialValue: activeCart[i]
                                                      .count
                                                      .toString(),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  textAlign: TextAlign.center,
                                                  decoration:
                                                      const InputDecoration(
                                                    border: InputBorder.none,
                                                    isDense: true,
                                                    contentPadding:
                                                        EdgeInsets.zero,
                                                  ),
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  onChanged: (value) {
                                                    final intCount =
                                                        int.tryParse(value);
                                                    if (intCount != null &&
                                                        intCount >= 0) {
                                                      cartProvider
                                                          .updateItemCount(
                                                        tenantId: cartProvider
                                                            .selectedCartTenant!
                                                            .tenantId,
                                                        menuId: activeCart[i]
                                                            .menuId,
                                                        count: intCount,
                                                      );
                                                    }
                                                  },
                                                ),
                                              ),

                                              // Tombol +
                                              GestureDetector(
                                                onTap: () =>
                                                    cartProvider.addItemToCart(
                                                  catatan:
                                                      activeCart[i].catatan,
                                                  tenantId: cartProvider
                                                      .selectedCartTenant!
                                                      .tenantId,
                                                  cart: activeCart[i],
                                                ),
                                                child: Container(
                                                  width: 28,
                                                  height: 32,
                                                  decoration: BoxDecoration(
                                                    // color: AppColors
                                                    //     .backgroundColor,
                                                    borderRadius:
                                                        const BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      '+',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: AppColors
                                                            .primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ))
                                  ],
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Sub total : ${activeCart.length} Menu',
                                    style: GoogleFonts.poppins(
                                        color: AppColors.primaryColor)),
                                Text(
                                  FormatCurrency.intToStringCurrency(
                                      activeCart.fold(
                                          0,
                                          (prev, item) =>
                                              prev +
                                              (item.count * item.menuPrice))),
                                  style: GoogleFonts.poppins(
                                      color: AppColors.blackColor,
                                      fontWeight: FontWeight.w600),
                                )
                              ],
                            ),
                            DashedDivider(
                              color: AppColors.blackColor100,
                              dashWidth: 2,
                              dashSpace: 2,
                            ),
                            AddMoreItemsButton(widget.tenantId),
                          ],
                        ),
                      ),
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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            spacing: 8,
                            children: [
                              if (cartProvider.selectedDeliveryOption == 1)
                                Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Driver Aktif',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w600,
                                          )),
                                      Text(
                                        '${cartProvider.totalActiveDriver} Driver',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: cartProvider
                                                      .totalActiveDriver ==
                                                  0
                                              ? Colors.red
                                              : cartProvider.totalActiveDriver >
                                                          0 &&
                                                      cartProvider
                                                              .totalActiveDriver <=
                                                          5
                                                  ? AppColors.warningColor
                                                  : AppColors.successColor,
                                        ),
                                      )
                                    ]),
                              CardSelectedDeliveryOptionToggle(
                                cartProvider: cartProvider,
                                screenWidth: screenSize.width,
                              ),
                            ],
                          ),
                        ),
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
                                  user.token, roomSelected.gedung.ongkir);
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
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              spacing: 8,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (cartProvider.priority == 0)
                                      cartProvider.setIsPriority(1);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: cartProvider.priority == 1
                                            ? AppColors.primaryColor
                                            : AppColors.blackColor100,
                                      ),
                                      color: AppColors.whiteColor100,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Iconsax.flash_1,
                                                      color: AppColors
                                                          .primaryColor),
                                                  Text(
                                                    'Express',
                                                    style: GoogleFonts.poppins(
                                                      color:
                                                          AppColors.blackColor,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              if (cartProvider.roomId != null)
                                                Text(
                                                  'Jaminan pesan tidak tertolak, lebih cepat sampai tempatmu',
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.primaryColor,
                                                  ),
                                                  softWrap: true,
                                                )
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: Row(
                                            spacing: 8,
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                cartProvider.roomId == null
                                                    ? '-'
                                                    : '${_roomList.firstWhere((element) => element.id == cartProvider.roomId).gedung.ongkir + 3000 + (cartProvider.totalItemCount > 10 ? (cartProvider.totalItemCount - 10) * 500 : 0)}',
                                                style: GoogleFonts.poppins(
                                                    color: AppColors.blackColor,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              Container(
                                                width: 24,
                                                height: 24,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: cartProvider
                                                                .priority ==
                                                            1
                                                        ? AppColors.primaryColor
                                                        : Colors.grey,
                                                    width: 2,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Container(
                                                    width: 24 / 2,
                                                    height: 24 / 2,
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      color: cartProvider
                                                                  .priority ==
                                                              1
                                                          ? AppColors
                                                              .primaryColor
                                                          : Colors.transparent,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (cartProvider.priority == 1)
                                      cartProvider.setIsPriority(0);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 8),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: cartProvider.priority == 0
                                            ? AppColors.primaryColor
                                            : AppColors.blackColor100,
                                      ),
                                      color: AppColors.whiteColor100,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Reguler',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Row(
                                          spacing: 8,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              cartProvider.roomId == null
                                                  ? '-'
                                                  : '${_roomList.firstWhere((element) => element.id == cartProvider.roomId).gedung.ongkir}',
                                              style: GoogleFonts.poppins(
                                                  color: AppColors.blackColor,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                            Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color:
                                                      cartProvider.priority == 0
                                                          ? AppColors
                                                              .primaryColor
                                                          : Colors.grey,
                                                  width: 2,
                                                ),
                                              ),
                                              child: Center(
                                                child: Container(
                                                  width: 24 / 2,
                                                  height: 24 / 2,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: cartProvider
                                                                .priority ==
                                                            0
                                                        ? AppColors.primaryColor
                                                        : Colors.transparent,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 15),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                spreadRadius: 1,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            spacing: 8,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  final voucher =
                                      cartProvider.selectedVoucher ??
                                          cartProvider.recommendedVoucher;
                                  print('voucher $voucher');
                                  print(
                                      'selected voucher ${cartProvider.selectedVoucher}');

                                  if (voucher == null) {
                                    // misal kasih snackbar / balik ke halaman sebelumnya
                                    if (cartProvider.recommendedCashback !=
                                        null) {
                                      Navigator.push(
                                          context,
                                          CustomPageBuilder(
                                              page: DetailVoucherPage(
                                            cashback: cartProvider
                                                .recommendedCashback,
                                          )));
                                      return;
                                    }
                                  }
                                  Navigator.push(
                                      context,
                                      CustomPageBuilder(
                                          page: DetailVoucherPage(
                                        voucher: voucher,
                                      )));
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                      color:
                                          cartProvider.selectedVoucher != null
                                              ? AppColors.successColor100
                                              : Colors.transparent,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppColors.successColor,
                                      )),
                                  child: Row(
                                    spacing: 8,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: AppColors.successColor100,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: HugeIcon(
                                          icon: HugeIcons.strokeRoundedDiscount,
                                          color: AppColors.successColor,
                                          size: 24,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  cartProvider.selectedVoucher !=
                                                          null
                                                      ? 'Cashback ${(cartProvider.selectedVoucher!.cashback.value * 100).toInt()}% maks ${cartProvider.selectedVoucher!.cashback.maxCashback ~/ 1000}rb'
                                                      : cartProvider
                                                                  .recommendedCashback !=
                                                              null
                                                          ? 'Cashback ${(cartProvider.recommendedCashback!.value * 100).toInt()}% maks ${cartProvider.recommendedCashback!.maxCashback ~/ 1000}rb'
                                                          : 'Cashback ${(cartProvider.recommendedVoucher!.cashback.value * 100).toInt()}% maks ${cartProvider.recommendedVoucher!.cashback.maxCashback ~/ 1000}rb',
                                                  style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        AppColors.blackColor400,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                                Text(
                                                  cartProvider.selectedVoucher !=
                                                          null
                                                      ? 'Min. pembelian ${cartProvider.selectedVoucher!.cashback.minimalOrder ~/ 1000}rb'
                                                      : 'Min. pembelian ${(cartProvider.recommendedCashback != null ? cartProvider.recommendedCashback!.minimalOrder : cartProvider.recommendedVoucher!.cashback.minimalOrder) ~/ 1000}rb',
                                                  style: GoogleFonts.poppins(
                                                      fontSize: 12),
                                                ),
                                              ]),
                                        ),
                                      ),
                                      if (cartProvider.selectedVoucher == null)
                                        GestureDetector(
                                          onTap: () async {
                                            try {
                                              if (cartProvider
                                                      .recommendedCashback !=
                                                  null) {
                                                await cartProvider.getCashback(
                                                    user.token,
                                                    cartProvider
                                                        .recommendedCashback!
                                                        .referralCode);
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Voucher berhasil diklaim, silahkan Pakai',
                                                    backgroundColor:
                                                        AppColors.successColor,
                                                    textColor: Colors.white);
                                              } else if (cartProvider
                                                      .recommendedVoucher !=
                                                  null) {
                                                if (cartProvider.totalPrice <
                                                    cartProvider
                                                        .recommendedVoucher!
                                                        .cashback
                                                        .minimalOrder) {
                                                  Fluttertoast.showToast(
                                                      msg:
                                                          'Minimal pembelian ${cartProvider.recommendedVoucher!.cashback.minimalOrder ~/ 1000}rb');
                                                  return;
                                                }
                                                cartProvider.setSelectedVoucher(
                                                    cartProvider
                                                        .recommendedVoucher!);
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'Voucher berhasil dipilih',
                                                    backgroundColor:
                                                        AppColors.successColor,
                                                    textColor: Colors.white);
                                              }
                                            } catch (e) {
                                              Fluttertoast.showToast(
                                                  msg: e.toString());
                                            }
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: AppColors.successColor,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                                cartProvider.recommendedCashback !=
                                                        null
                                                    ? 'Klaim'
                                                    : 'Pakai',
                                                style: GoogleFonts.poppins(
                                                  color:
                                                      AppColors.successColor400,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                      if (cartProvider.selectedVoucher != null)
                                        HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedCheckmarkCircle02,
                                          color: AppColors.successColor,
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              DashedDivider(
                                color: AppColors.blackColor300,
                                dashWidth: 2,
                                dashSpace: 2,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    CustomPageBuilder(page: ListPromoPage()),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text('Cek promo lainnya',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.successColor,
                                          )),
                                    ),
                                    HugeIcon(
                                        icon:
                                            HugeIcons.strokeRoundedArrowRight02,
                                        color: AppColors.successColor)
                                  ],
                                ),
                              )
                            ],
                          ),
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
      bottomNavigationBar: context.watch<CartProvider>().totalItemCount > 0
          ? SafeArea(
              child: Consumer<CoinProvider>(
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
              ),
            )
          : null,
    );
  }
}
