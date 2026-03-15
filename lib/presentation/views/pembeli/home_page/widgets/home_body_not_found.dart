import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class HomeBodyNotFound extends StatelessWidget {
  const HomeBodyNotFound({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Center(
        child: Column(
          children: [
            Image(
              width: MediaQuery.of(context).size.width / 2,
              image: const AssetImage("assets/images/404-Not-Found.png"),
            ),
            Text('Yah menu yang kamu cari masih belum tersedia nih :(',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.blackColor400))
          ],
        ),
      ),
    );
  }
}
