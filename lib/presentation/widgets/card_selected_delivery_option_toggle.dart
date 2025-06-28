import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class CardSelectedDeliveryOptionToggle extends StatelessWidget {
  final CartProvider cartProvider;
  final double screenWidth;

  const CardSelectedDeliveryOptionToggle({
    required this.cartProvider,
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
            Padding(
              padding: const EdgeInsets.all(6.0),
              child: Text(
                'Tipe Pemesanan',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: semibold,
                  color: AppColors.textColorBlack,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: cartProvider.isThereActiveDriver
                        ? () => cartProvider.setDeliveryOption(1)
                        : () {
                            Fluttertoast.showToast(
                              msg: "Driver tidak tersedia",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.TOP,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                              fontSize: 16.0,
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartProvider.selectedDeliveryOption == 1
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      foregroundColor: cartProvider.selectedDeliveryOption == 1
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text("Pesan Antar"),
                  ),
                ),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => cartProvider.setDeliveryOption(0),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cartProvider.selectedDeliveryOption == 0
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      foregroundColor: cartProvider.selectedDeliveryOption == 0
                          ? Colors.white
                          : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                    child: const Text("Ambil Sendiri"),
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
