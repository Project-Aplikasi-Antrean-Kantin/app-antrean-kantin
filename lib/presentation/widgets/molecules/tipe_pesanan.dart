import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class TipePesanan extends StatelessWidget {
  final int isPriority;
  final double size;
  const TipePesanan({super.key, required this.isPriority, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: size / 2, vertical: size / 4),
        decoration: BoxDecoration(
          border: Border.all(
              color: isPriority == 1 ? AppColors.primaryColor : Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: size / 4,
          children: [
            if (isPriority == 1)
              Icon(Iconsax.flash_1,
                  size: size * 1.5, color: AppColors.primaryColor),
            Text(
              isPriority == 1 ? "Express" : "Reguler",
              style: GoogleFonts.poppins(
                color: isPriority == 1 ? AppColors.primaryColor : Colors.black,
                fontSize: size,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
