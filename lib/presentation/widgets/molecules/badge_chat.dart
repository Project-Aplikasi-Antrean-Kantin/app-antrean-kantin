import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class BadgeChat extends StatelessWidget {
  final Widget child;
  final bool isActive;
  const BadgeChat({super.key, this.isActive = false, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        // bulatan indikator
        if (isActive)
          Positioned(
            right: 4,
            top: -2,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
