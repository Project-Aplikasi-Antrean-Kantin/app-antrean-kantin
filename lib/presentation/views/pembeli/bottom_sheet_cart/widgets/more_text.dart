import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class MoreText extends StatelessWidget {
  final VoidCallback onTapMore;
  final String text;
  const MoreText({super.key, required this.onTapMore, required this.text});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapMore,
      child: Row(
        children: [
          Text(text,
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontWeight: semibold,
                fontSize: 14,
              )),
          HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              color: AppColors.primaryColor)
        ],
      ),
    );
  }
}
