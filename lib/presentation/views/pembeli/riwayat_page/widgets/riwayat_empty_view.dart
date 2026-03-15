import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class RiwayatEmptyView extends StatelessWidget {
  const RiwayatEmptyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          children: [
            Image(
              width: MediaQuery.of(context).size.width / 2,
              image: const AssetImage("assets/images/404-Not-Found.png"),
            ),
            Text('Belum ada riwayat',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.blackColor400))
          ],
        ),
      ),
    );
  }
}
