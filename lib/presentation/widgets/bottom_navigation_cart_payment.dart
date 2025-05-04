import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
import 'package:testgetdata/presentation/widgets/pilih_tipe_pembayaran.dart';

class BottomNavigationCartPayment extends StatelessWidget {
  final CartProvider cartProvider;
  final KasirProvider kasirProvider;
  final CoinProvider coinProvider;
  final UserModel user;
  final int saldoCoin;
  final PaymentMethod? selectedPaymentMethod;
  final int? selectedRoom;
  final ValueChanged<PaymentMethod> onPaymentMethodSelected;
  final VoidCallback onConfirmOrder;
  final VoidCallback onBalanceCoinLow;
  final VoidCallback onIncompleteData;

  const BottomNavigationCartPayment({
    required this.cartProvider,
    required this.kasirProvider,
    required this.coinProvider,
    required this.user,
    required this.saldoCoin,
    required this.selectedPaymentMethod,
    required this.selectedRoom,
    required this.onPaymentMethodSelected,
    required this.onConfirmOrder,
    required this.onBalanceCoinLow,
    required this.onIncompleteData,
  });

  @override
  Widget build(BuildContext context) {
    final isKasirProviderActive = kasirProvider.cart.isNotEmpty;
    final isCartProviderActive = cartProvider.cart.isNotEmpty;
    final totalHarga = isKasirProviderActive
        ? kasirProvider.getTotal()
        : cartProvider.getTotal();
    final isCoinInsufficient =
        selectedPaymentMethod == PaymentMethod.koin && saldoCoin < totalHarga;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isCoinInsufficient) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            decoration:
                const BoxDecoration(color: AppColors.containerColorGrey),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saldo Koin Kurang',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: semibold,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                    Text(
                      'Sisa Saldo: $saldoCoin Koin',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: regular,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          TopupPage(
                        coin: saldoCoin,
                        email: user.email,
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
                            position: offsetAnimation, child: child);
                      },
                    ),
                  ),
                  child: Container(
                    width: 90,
                    height: 33,
                    decoration: BoxDecoration(
                      color: AppColors.containerColorGrey,
                      border: Border.all(
                          color: AppColors.containerColorWhite, width: 1.5),
                      borderRadius: BorderRadius.circular(10),
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
              ],
            ),
          ),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(width: 0.2, color: Colors.grey)),
          ),
          child: Column(
            children: [
              PilihTipePembayaran(
                isCartActive: isCartProviderActive,
                isKasirActive: isKasirProviderActive,
                pilihTipePembayaran:
                    selectedPaymentMethod?.toString().split('.').last,
                selectedPembayaran: (option) {
                  if (option == 'koin')
                    onPaymentMethodSelected(PaymentMethod.koin);
                  if (option == 'cod')
                    onPaymentMethodSelected(PaymentMethod.cod);
                },
              ),
              const SizedBox(height: 10),
              BottomNavigationButton(
                isLoading: cartProvider.isLoading,
                color: AppColors.primaryColor,
                onTap: cartProvider.isLoading
                    ? null
                    : () {
                        log("room id: ${cartProvider.roomId}");
                        if (!isKasirProviderActive &&
                            cartProvider.selectedDeliveryOption == 1 &&
                            (cartProvider.roomId == null ||
                                cartProvider.roomId! <= 0)) {
                          onIncompleteData();
                          return;
                        }
                        if (!isKasirProviderActive &&
                            !cartProvider.isCartValid(cartProvider.roomId)) {
                          onIncompleteData();
                          return;
                        }
                        if (isCoinInsufficient) {
                          onBalanceCoinLow();
                          return;
                        }
                        onConfirmOrder();
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
