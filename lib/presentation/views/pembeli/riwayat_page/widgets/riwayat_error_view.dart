import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class RiwayatErrorView extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;
  const RiwayatErrorView(
      {super.key, required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: errorMessage.contains('Failed host lookup') ||
              errorMessage.contains('Connection')
          ? Column(
              spacing: 8,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image(
                    image: const AssetImage('assets/images/No-connection.png')),
                Text(
                  'Upss Koneksimu Hilang!',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor900,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Cek jaringan internet kamu dulu, ya.    Tenang, kami tetap nungguin kamu balik 😄',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF585858),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                GestureDetector(
                  onTap: onRetry,
                  child: Container(
                    margin: EdgeInsets.only(top: 16),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    width: MediaQuery.of(context).size.width - 48,
                    child: Center(
                        child: Text('Coba Lagi',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ))),
                  ),
                )
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  errorMessage,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: regular,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text("Coba Lagi"),
                ),
              ],
            ),
    );
  }
}
