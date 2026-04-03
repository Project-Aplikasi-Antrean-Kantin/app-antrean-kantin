import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class AppBarForm extends StatelessWidget {
  final String title;
  const AppBarForm({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft02,
                  color: AppColors.blackColor,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.blackColor,
            ),
          ),
        ],
      ),
    );
  }
}
