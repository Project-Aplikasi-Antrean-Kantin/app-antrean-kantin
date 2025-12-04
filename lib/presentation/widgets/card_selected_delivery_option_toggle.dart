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
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: EdgeInsets.all(16),
                      backgroundColor: cartProvider.selectedDeliveryOption == 1
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      foregroundColor: cartProvider.selectedDeliveryOption == 1
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
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // if (cartProvider.selectedCartTenant.length >= 2) {
                      //   Fluttertoast.showToast(
                      //       backgroundColor: AppColors.warningColor,
                      //       textColor: Colors.white,
                      //       msg:
                      //           "Multitenant hanya mendukung layanan pesan antar");
                      //   return;
                      // }
                      cartProvider.setDeliveryOption(0);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primaryColor),
                      padding: EdgeInsets.all(16),
                      backgroundColor: cartProvider.selectedDeliveryOption == 0
                          ? AppColors.primaryColor
                          : Colors.transparent,
                      foregroundColor: cartProvider.selectedDeliveryOption == 0
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
              ],
            ),
          ],
        );
      },
    );
  }
}
