import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/bottom_navigation_button.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/pilih_tipe_pembayaran.dart';

class BottomNavigationCartPayment extends StatelessWidget {
  final CartProvider cartProvider;
  final KasirProvider kasirProvider;
  final CoinProvider coinProvider;
  final UserModel user;
  final int saldoCoin;
  final PaymentMethod? selectedPaymentMethod;
  final ValueChanged<PaymentMethod?>
      onPaymentMethodSelected; // Diperbaiki ke PaymentMethod?
  final VoidCallback onConfirmOrder;
  final VoidCallback onIncompleteData;

  const BottomNavigationCartPayment({
    Key? key,
    required this.cartProvider,
    required this.kasirProvider,
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

  /// Checks if the coin balance is insufficient for the transaction.
  bool _isCoinInsufficient(int totalHarga) =>
      selectedPaymentMethod == PaymentMethod.koin && saldoCoin < totalHarga;

  /// Checks if delivery location data is incomplete.
  bool _isDataIncomplete() =>
      !kasirProvider.cart.isNotEmpty &&
      cartProvider.selectedDeliveryOption == 1 &&
      (cartProvider.roomId == null || cartProvider.roomId! <= 0);

  /// Navigates to the top-up page.
  void _navigateToTopup(BuildContext context) {
    Navigator.push(
      context,
      CustomPageBuilder(page: TopupPage(email: user.email)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isKasirActive = kasirProvider.cart.isNotEmpty;
    final totalHarga =
        isKasirActive ? kasirProvider.getTotal() : cartProvider.getTotal();
    final isCoinInsufficient = _isCoinInsufficient(totalHarga);

    return Semantics(
      label: 'Navigasi pembayaran keranjang',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isCoinInsufficient)
            _LowCoinWarning(onTopup: () => _navigateToTopup(context)),
          Container(
            padding: _padding,
            decoration: const BoxDecoration(
              border: Border(
                  top: BorderSide(width: _borderWidth, color: _borderColor)),
            ),
            child: Column(
              children: [
                PilihTipePembayaran(
                  isCartActive: cartProvider.cart.isNotEmpty,
                  isKasirActive: isKasirActive,
                  selectedPaymentMethod: selectedPaymentMethod,
                  onPaymentMethodSelected: onPaymentMethodSelected,
                ),
                const SizedBox(height: _spacing),
                BottomNavigationButton(
                  isEnabled: !isCoinInsufficient,
                  color: AppColors.primaryColor,
                  onTap: cartProvider.isLoading
                      ? null
                      : () {
                          log("room id: ${cartProvider.roomId}");
                          if (_isDataIncomplete()) {
                            onIncompleteData();
                            return;
                          }
                          if (!isKasirActive &&
                              !cartProvider.isCartValid(cartProvider.roomId)) {
                            onIncompleteData();
                            return;
                          }
                          onConfirmOrder();
                        },
                ),
              ],
            ),
          ),
        ],
      ),
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
              'Saldo Koin-mu tidak mencukupi',
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
