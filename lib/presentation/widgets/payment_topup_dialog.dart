import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/payment_method_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentTopupDialog {
  static void show(BuildContext context, String email, int? selectedNominal) {
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);
    final nominal = selectedNominal?.toString() ?? "0";

    if (nominal == "0") {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CustomAlertDialog(
            title: "Pengingat",
            message: "Silakan pilih nominal topup terlebih dahulu",
            showCancelButton: false,
            textButtonOk: "OK",
            onOkPressed: () => Navigator.of(context).pop(),
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: AppColors.backgroundColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Pembayaran Topup',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Nominal Topup: ',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: regular,
                          color: AppColors.textColorBlack,
                        ),
                      ),
                      TextSpan(
                        text: '${FormatCurrency.formatNumber(nominal)}',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: semibold,
                          color: AppColors.textColorBlack,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                PaymentMethodWidget(
                  iconPath: 'assets/icons/dana.png',
                  methodName: topUpProvider.namaDgs,
                  accountNumber: topUpProvider.noDgs,
                ),
                const SizedBox(height: 15),
                PaymentMethodWidget(
                  iconPath: 'assets/icons/gopay.png',
                  methodName: topUpProvider.namaMandiri,
                  accountNumber: topUpProvider.noMandiri,
                ),
                const SizedBox(height: 15),
                PaymentMethodWidget(
                  iconPath: 'assets/icons/shopeepay.png',
                  methodName: topUpProvider.namaJago,
                  accountNumber: topUpProvider.noJago,
                ),
                const SizedBox(height: 20),
                _buildActionButtons(context, email, nominal, topUpProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _openWhatsappChat({
    required BuildContext context,
    required String email,
    required String nominal,
    required TopupProvider topUpProvider,
  }) async {
    // Use the last copied payment method, default to a generic message if none copied
    final paymentMethod = topUpProvider.lastCopiedPaymentMethod.isNotEmpty
        ? topUpProvider.lastCopiedPaymentMethod
        : 'DANA/GoPay/ShopeePay';
    final message = Uri.encodeComponent(
      "Verifikasi Topup Koin \n\nNominal: *Rp $nominal* \nEmail: *$email* \n\nSaya telah melakukan pembayaran via $paymentMethod. Mohon untuk memverifikasi. \n\nBerikut bukti pembayaran saya:\n_[Bukti bayar]_",
    );
    final whatsappUrl =
        Uri.parse('https://wa.me/${topUpProvider.noKonfirmasi}?text=$message');
    final playStoreUrl =
        Uri.parse('https://play.google.com/store/apps/details?id=com.whatsapp');

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
    } else if (!await launchUrl(playStoreUrl,
        mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $playStoreUrl';
    }
  }

  static Widget _buildActionButtons(
    BuildContext context,
    String email,
    String nominal,
    TopupProvider topUpProvider,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ButtonStyle(
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
                side: const BorderSide(color: Colors.grey),
              ),
            ),
            minimumSize: WidgetStateProperty.all(const Size(120, 40)),
          ),
          child: Text(
            'Batal',
            style: GoogleFonts.poppins(
                color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(width: 10),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _openWhatsappChat(
              context: context,
              email: email,
              nominal: nominal,
              topUpProvider: topUpProvider,
            );
          },
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.primaryColor),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
            minimumSize: WidgetStateProperty.all(const Size(120, 40)),
          ),
          child: Text(
            'Kirim Bukti',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
