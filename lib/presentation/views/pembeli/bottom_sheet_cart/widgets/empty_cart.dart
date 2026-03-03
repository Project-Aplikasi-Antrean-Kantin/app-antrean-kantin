import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        spacing: 8,
        children: [
          Image(
            width: MediaQuery.of(context).size.width / 2,
            image: const AssetImage("assets/images/404-Not-Found.png"),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width / 2,
            child: Text('Keranjang kamu kosong nih, yuk pesan menu!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.blackColor400)),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Pesan sekarang',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontSize: 16),
              ),
            ),
          )
        ],
      ),
    );
  }
}
