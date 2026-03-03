import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class TipePesanan extends StatelessWidget {
  final int isPriority;
  const TipePesanan({super.key, required this.isPriority});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(
              color: isPriority == 1 ? AppColors.primaryColor : Colors.grey),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            if (isPriority == 1)
              Icon(Iconsax.flash_1, size: 24, color: AppColors.primaryColor),
            Text(
              isPriority == 1 ? "Express" : "Reguler",
              style: GoogleFonts.poppins(
                color: isPriority == 1 ? AppColors.primaryColor : Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
