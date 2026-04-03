import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class OptionItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final Function() onTap;

  const OptionItem(
      {super.key, required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: BoxBorder.all(color: AppColors.blackColor100, width: 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            HugeIcon(
              icon: icon,
              color: AppColors.primaryColor,
            ),
            Text(
              text,
              style: GoogleFonts.poppins(
                  fontSize: 12, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}
