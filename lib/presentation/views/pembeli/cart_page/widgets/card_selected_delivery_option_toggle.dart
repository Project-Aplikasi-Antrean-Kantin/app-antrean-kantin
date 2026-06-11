import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

class CardSelectedDeliveryOptionToggle extends StatelessWidget {
  final double screenWidth;

  const CardSelectedDeliveryOptionToggle({
    required this.screenWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Semantics(
                    identifier: 'Pesan Antar',
                    child: OutlinedButton(
                      key: const Key('Pesan Antar'),
                      onPressed: cartProvider.isThereActiveDriver
                          ? () => cartProvider.setDeliveryOption(1)
                          : () {
                              CustomSnackbar.info("Driver tidak tersedia");
                            },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: EdgeInsets.all(16),
                        backgroundColor:
                            cartProvider.selectedDeliveryOption == 1
                                ? AppColors.primaryColor
                                : Colors.transparent,
                        foregroundColor:
                            cartProvider.selectedDeliveryOption == 1
                                ? Colors.white
                                : AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            bottomLeft: Radius.circular(16),
                          ),
                        ),
                      ),
                      child: Text(
                        "Pesan Antar",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Semantics(
                    identifier: 'Ambil Sendiri',
                    child: OutlinedButton(
                      key: const Key('Ambil Sendiri'),
                      onPressed: () {
                        cartProvider.setDeliveryOption(0);
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.primaryColor),
                        padding: EdgeInsets.all(16),
                        backgroundColor:
                            cartProvider.selectedDeliveryOption == 0
                                ? AppColors.primaryColor
                                : Colors.transparent,
                        foregroundColor:
                            cartProvider.selectedDeliveryOption == 0
                                ? Colors.white
                                : AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            bottomRight: Radius.circular(16),
                          ),
                        ),
                      ),
                      child: Text(
                        "Ambil Sendiri",
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
