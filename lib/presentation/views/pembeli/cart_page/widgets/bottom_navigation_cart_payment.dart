import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/bottom_navigation_button.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/pilih_tipe_pembayaran.dart';
import 'package:testgetdata/presentation/widgets/show_bottom_sheet_usevoucher.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class BottomNavigationCartPayment extends StatefulWidget {
  final CartProvider cartProvider;
  final CoinProvider coinProvider;
  final UserModel user;
  final int saldoCoin;
  final PaymentMethod selectedPaymentMethod;
  final ValueChanged<PaymentMethod>
      onPaymentMethodSelected; // Diperbaiki ke PaymentMethod?
  final VoidCallback onConfirmOrder;
  final VoidCallback onIncompleteData;

  const BottomNavigationCartPayment({
    Key? key,
    required this.cartProvider,
    required this.coinProvider,
    required this.user,
    required this.saldoCoin,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodSelected,
    required this.onConfirmOrder,
    required this.onIncompleteData,
  }) : super(key: key);

  static const _padding = EdgeInsets.symmetric(horizontal: 15, vertical: 10);
  static const _borderColor = Colors.grey;
  static const _borderWidth = 0.2;
  static const _spacing = 10.0;

  @override
  State<BottomNavigationCartPayment> createState() =>
      _BottomNavigationCartPaymentState();
}

class _BottomNavigationCartPaymentState
    extends State<BottomNavigationCartPayment> {
  /// Checks if the coin balance is insufficient for the transaction.
  bool _isCoinInsufficient(int totalHarga) =>
      widget.selectedPaymentMethod == PaymentMethod.koin &&
      widget.saldoCoin < totalHarga;

  /// Checks if delivery location data is incomplete.
  bool _isDataIncomplete() =>
      widget.cartProvider.selectedDeliveryOption == 1 &&
      (widget.cartProvider.roomId == null || widget.cartProvider.roomId! <= 0);

  /// Navigates to the top-up page.
  void _navigateToTopup(BuildContext context) async {
    final internetConnection = await hasInternetAccess();
    if (!internetConnection) {
      Fluttertoast.showToast(msg: "Tidak ada koneksi internet");
      return;
    }
    Navigator.push(
      context,
      CustomPageBuilder(page: TopupPage(email: widget.user.email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalHarga = widget.cartProvider.getTotal();
    final isCoinInsufficient = _isCoinInsufficient(totalHarga);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCoinInsufficient)
          _LowCoinWarning(onTopup: () => _navigateToTopup(context)),
        Container(
          padding: BottomNavigationCartPayment._padding,
          decoration: const BoxDecoration(
            border: Border(
                top: BorderSide(
                    width: BottomNavigationCartPayment._borderWidth,
                    color: BottomNavigationCartPayment._borderColor)),
          ),
          child: Column(
            children: [
              PilihTipePembayaran(
                isCartActive: widget.cartProvider.cart.isNotEmpty,
                selectedPaymentMethod: widget.selectedPaymentMethod,
                onPaymentMethodSelected: widget.onPaymentMethodSelected,
              ),
              const SizedBox(height: BottomNavigationCartPayment._spacing),
              BottomNavigationButton(
                isCoinInsufficient: isCoinInsufficient,
                paymentMethod: widget.selectedPaymentMethod,
                isThere10Item: widget.cartProvider.totalItemCount > 10,
                isEnabled: !isCoinInsufficient,
                color: AppColors.primaryColor,
                onTap: widget.cartProvider.isLoading
                    ? null
                    : () {
                        log("room id: ${widget.cartProvider.roomId}");
                        if (_isDataIncomplete()) {
                          widget.onIncompleteData();
                          return;
                        }
                        if (widget.cartProvider.showBottomSheetVoucher()) {
                          showBottomSheetUseVoucher(
                              context: context,
                              onFinish: () {
                                Navigator.pop(context);
                                widget.onConfirmOrder();
                              },
                              canSend: true);
                          return;
                        }
                        if (!widget.cartProvider
                            .isCartValid(widget.cartProvider.roomId)) {
                          widget.onIncompleteData();
                          return;
                        }
                        widget.onConfirmOrder();
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LowCoinWarning extends StatelessWidget {
  final VoidCallback onTopup;

  const _LowCoinWarning({required this.onTopup});

  static const _buttonWidth = 90.0;
  static const _buttonHeight = 30.0;
  static const _borderRadius = 25.0;
  static const _borderWidth = 1.5;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: BottomNavigationCartPayment._padding,
      decoration: const BoxDecoration(color: AppColors.containerColorSemiBlack),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              'FoodLAB Koin-mu tidak mencukupi',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: medium,
                color: AppColors.textColorwhite,
              ),
            ),
          ),
          Semantics(
            label: 'Top up saldo koin',
            child: GestureDetector(
              onTap: onTopup,
              child: Container(
                width: _buttonWidth,
                height: _buttonHeight,
                decoration: BoxDecoration(
                  color: AppColors.containerColorSemiBlack,
                  border: Border.all(
                    color: AppColors.containerColorWhite,
                    width: _borderWidth,
                  ),
                  borderRadius: BorderRadius.circular(_borderRadius),
                ),
                child: Center(
                  child: Text(
                    'Top Up',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textColorwhite,
                      fontWeight: semibold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
