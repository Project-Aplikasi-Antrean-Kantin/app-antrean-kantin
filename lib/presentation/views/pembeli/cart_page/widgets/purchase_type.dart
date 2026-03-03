import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/card_selected_delivery_option_toggle.dart';

class PurchaseType extends StatelessWidget {
  final CartProvider cartProvider;
  const PurchaseType({super.key, required this.cartProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
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
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Driver Aktif',
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                  )),
              Text(
                '${cartProvider.totalActiveDriver} Driver',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: cartProvider.totalActiveDriver == 0
                      ? Colors.red
                      : cartProvider.totalActiveDriver > 0 &&
                              cartProvider.totalActiveDriver <= 5
                          ? AppColors.warningColor
                          : AppColors.successColor,
                ),
              )
            ]),
          CardSelectedDeliveryOptionToggle(
            screenWidth: MediaQuery.of(context).size.width,
          ),
        ],
      ),
    );
  }
}
