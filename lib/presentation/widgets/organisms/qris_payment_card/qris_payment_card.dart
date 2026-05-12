import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/utils/qris_image_saver.dart';

class QrisPaymentCard extends StatelessWidget {
  final String metodeBayar;
  final int nominal;
  final int? admin;
  final int? total;
  final String urlQris;
  final int secondsRemaining;
  final VoidCallback? onGantiNominal;

  const QrisPaymentCard({
    Key? key,
    this.metodeBayar = 'QRIS',
    required this.nominal,
    this.admin,
    this.total,
    required this.urlQris,
    required this.secondsRemaining,
    this.onGantiNominal,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          _buildCard(),
          const SizedBox(height: 64),
          _buildButtons(),
        ],
      ),
    );
  }

  Future<void> _downloadQris() async {
    await QrisImageSaver.save(urlQris, secondsRemaining);
  }

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.only(top: 70),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/watermark-foodlab.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 8,
              children: [
                _rowText('Metode Bayar:', metodeBayar),
                DashedDivider(height: 1.5, color: AppColors.blackColor100),
                _rowText('Nominal:', FormatCurrency.intToStringCoin(nominal)),
                if (admin != null)
                  _rowText('Admin:', FormatCurrency.intToStringCoin(admin!)),
                if (total != null)
                  _rowText('Total:', FormatCurrency.intToStringCoin(total!)),
                DashedDivider(height: 1.5, color: AppColors.blackColor100),
                Center(
                  child: Text(
                    'QR Bayar',
                    style: GoogleFonts.poppins(color: AppColors.blackColor400),
                  ),
                ),
                Center(child: _buildQrSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrSection() {
    return Column(
      children: [
        if (secondsRemaining > 0)
          Image.network(
            urlQris,
            width: 200,
            height: 200,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return SizedBox(
                width: 200,
                height: 200,
                child: Image.asset(
                  'assets/images/dummy.jpeg',
                  fit: BoxFit.cover,
                ),
              );
            },
          ),
        Text(
          'Sisa waktu: ${formatDuration(secondsRemaining)}',
          style: GoogleFonts.poppins(
            color: AppColors.primaryColor,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    final hasGanti = onGantiNominal != null;

    return Row(
      spacing: 8,
      children: [
        if (hasGanti)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                backgroundColor: AppColors.primaryColor100,
                padding: const EdgeInsets.all(16),
              ),
              onPressed: onGantiNominal,
              child: Text(
                'Ganti Nominal',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              backgroundColor: AppColors.primaryColor700,
              padding: const EdgeInsets.all(16),
            ),
            onPressed: _downloadQris,
            child: Text(
              'Unduh',
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.poppins(color: AppColors.blackColor400)),
        Text(value, style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
