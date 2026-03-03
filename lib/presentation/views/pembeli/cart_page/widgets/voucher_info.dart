import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class VoucherInfo extends StatelessWidget {
  final bool isSelected;
  final bool isRecommendedCashback;
  final String title;
  final String subtitle;
  final VoidCallback? onClaim;
  final bool canClaim;
  const VoucherInfo(
      {super.key,
      required this.isSelected,
      required this.isRecommendedCashback,
      required this.title,
      required this.subtitle,
      this.onClaim,
      required this.canClaim});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.successColor100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: HugeIcon(
            icon: HugeIcons.strokeRoundedDiscount,
            color: AppColors.successColor,
            size: 24,
          ),
        ),

        // text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor400,
                    fontSize: 12,
                  )),
              Text(subtitle, style: GoogleFonts.poppins(fontSize: 12)),
            ],
          ),
        ),

        // tombol klaim/pakai
        if (!isSelected && canClaim && onClaim != null)
          GestureDetector(
            onTap: onClaim,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.successColor),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                isRecommendedCashback ? 'Klaim' : 'Pakai',
                style: GoogleFonts.poppins(
                  color: AppColors.successColor400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

        if (isSelected)
          HugeIcon(
            icon: HugeIcons.strokeRoundedCheckmarkCircle02,
            color: AppColors.successColor,
          ),
      ],
    );
  }
}
