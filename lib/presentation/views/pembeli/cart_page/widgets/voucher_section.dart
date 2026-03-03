import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/voucher_info.dart';
import 'package:testgetdata/presentation/views/pembeli/list_promo_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class VoucherSection extends StatelessWidget {
  final bool isSelected;
  final bool isRecommendedCashback;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback? onClaim;
  final bool canClaim;
  const VoucherSection(
      {super.key,
      required this.isSelected,
      required this.isRecommendedCashback,
      required this.title,
      required this.subtitle,
      required this.onTap,
      this.onClaim,
      required this.canClaim});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
          color: isSelected ? AppColors.successColor100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          spacing: 8,
          children: [
            VoucherInfo(
                onClaim: onClaim,
                isSelected: isSelected,
                isRecommendedCashback: isRecommendedCashback,
                title: title,
                subtitle: subtitle,
                canClaim: canClaim),
            DashedDivider(
              color: AppColors.blackColor300,
              dashWidth: 2,
              dashSpace: 2,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  CustomPageBuilder(
                      page: ListPromoPage(
                    fromProfile: false,
                  )),
                );
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text('Cek promo lainnya',
                        style: GoogleFonts.poppins(
                          color: AppColors.successColor,
                        )),
                  ),
                  HugeIcon(
                      icon: HugeIcons.strokeRoundedArrowRight02,
                      color: AppColors.successColor)
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
