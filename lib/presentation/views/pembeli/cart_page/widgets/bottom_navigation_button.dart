import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/cart_page.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class BottomNavigationButton extends StatelessWidget {
  final bool isEnabled;
  final bool isCoinInsufficient;
  final VoidCallback? onTap;
  final Color color;
  final bool isThere10Item;
  final PaymentMethod paymentMethod;

  const BottomNavigationButton({
    required this.isCoinInsufficient,
    required this.paymentMethod,
    Key? key,
    required this.isEnabled,
    required this.onTap,
    required this.color,
    this.isThere10Item = false,
  }) : super(key: key);

  static const _height = 48.0;
  static const _borderRadius = 30.0;

  @override
  Widget build(BuildContext context) {
    final buttonColor = !isEnabled ? Colors.grey[400]! : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Semantics(
            identifier: 'Navigasi pembayaran keranjang',
            button: true,
            child: InkWell(
              key: Key("checkoutButton"),
              onTap: !isEnabled
                  ? () {
                      if (isCoinInsufficient) {
                        CustomSnackbar.info('Koin kamu tidak cukup');
                      }
                      CustomSnackbar.info('Tunggu Sebentar');
                    }
                  : onTap,
              child: Center(
                child: Text(
                  'Pesan sekarang',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: semibold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
