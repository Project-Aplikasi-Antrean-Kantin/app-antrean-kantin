import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';

class PaymentMethodWidget extends StatelessWidget {
  final String iconPath;
  final String methodName;
  final String accountNumber;

  const PaymentMethodWidget({
    super.key,
    required this.iconPath,
    required this.methodName,
    required this.accountNumber,
  });

  @override
  Widget build(BuildContext context) {
    final topupProvider = Provider.of<TopupProvider>(context, listen: false);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 40,
            height: 40,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.account_balance_wallet,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  methodName,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textColorBlack,
                  ),
                ),
                Text(
                  accountNumber,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: AppColors.textColorBlack,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: accountNumber));
              topupProvider.setLastCopiedPaymentMethod(methodName);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Nomor $methodName disalin!'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                'Salin',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: semibold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
