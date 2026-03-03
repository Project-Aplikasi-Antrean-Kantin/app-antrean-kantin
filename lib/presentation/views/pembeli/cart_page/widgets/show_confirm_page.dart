import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

void showConfirmOrderBottomSheet(
  BuildContext context,
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
                                        cartProvider,
                                        coinProvider,
                                        user,
                                        paymentMethod,
                                        saldoCoin,
                                      );
                                    } catch (e) {
                                      setState(() => isLoading = false);

                                      Fluttertoast.showToast(
                                          msg: e
                                              .toString()
                                              .replaceFirst('Exception: ', ''),
                                          textColor: Colors.white,
                                          backgroundColor: AppColors.errorColor,
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
        pageIndex: user.menu.indexWhere((element) => element.url == '/riwayat'),
      ),
    ),
    (route) => false,
  );
}

Future<void> _handleTransaction(
  BuildContext context,
  CartProvider cartProvider,
  CoinProvider coinProvider,
  UserModel user,
  PaymentMethod paymentMethod,
  int saldoCoin,
) async {
  cartProvider.setTransactionStatus(
      isLoading: true, isTransactionCompleted: true);
  final historyProvider = Provider.of<HistoryProvider>(context, listen: false);

  final result = await cartProvider.createTransaction(
      context, user.token, paymentMethod.name);

  if (result?.status == 'success') {
    historyProvider.updateSelectedPesanan(result!.pesanan);

    await cartProvider.clearCart(true);
    _navigateToSuccessPage(
        context, cartProvider, result.pesanan, user, historyProvider);
  } else {
    cartProvider.setTransactionStatus(isTransactionCompleted: false);
  }

  cartProvider.setTransactionStatus(isLoading: false);
}
