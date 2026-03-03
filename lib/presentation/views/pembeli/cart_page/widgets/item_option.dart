import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/atoms/radio_circle.dart';

class ItemOption extends StatelessWidget {
  final bool isSelected;
  final String title;
  final String price;
  final VoidCallback onTap;
  final IconData? leadingIcon;
  final String? description;

  const ItemOption({
    super.key,
    required this.isSelected,
    required this.title,
    required this.price,
    required this.onTap,
    this.leadingIcon,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isSelected ? AppColors.primaryColor : AppColors.blackColor100,
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // LEFT CONTENT
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (leadingIcon != null)
                        Icon(leadingIcon, color: AppColors.primaryColor),
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  if (description != null)
                    Text(
                      description!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primaryColor,
                      ),
                    ),
                ],
              ),
            ),

            // RIGHT CONTENT
            Expanded(
              flex: 1,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RadioCircle(isSelected: isSelected),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
