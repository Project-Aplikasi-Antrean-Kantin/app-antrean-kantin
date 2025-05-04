import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:toggle_switch/toggle_switch.dart';

class DeliveryOptionToggle extends StatelessWidget {
  final CartProvider cartProvider;
  final double screenWidth;

  const DeliveryOptionToggle({
    required this.cartProvider,
    required this.screenWidth,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
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
        ToggleSwitch(
          initialLabelIndex: cartProvider.selectedDeliveryOption == 1 ? 0 : 1,
          minWidth: (screenWidth - 30) / 2,
          labels: const ['Pesan Antar', 'Ambil Sendiri'],
          activeBgColor: const [AppColors.primaryColor],
          activeFgColor: AppColors.backgroundColor,
          activeBorders: [Border.all(color: AppColors.primaryColor)],
          inactiveFgColor: AppColors.textColorBlack,
          inactiveBgColor: AppColors.backgroundColor,
          borderColor: const [AppColors.textColorBlack],
          borderWidth: 1,
          cornerRadius: 5,
          onToggle: (index) =>
              cartProvider.setDeliveryOption(index == 0 ? 1 : 0),
        ),
      ],
    );
  }
}
