import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class ExitConfirmationBottomSheet extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  const ExitConfirmationBottomSheet({
    super.key,
    required this.onCancel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.height < 700;

    return SafeArea(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.8,
            ),
            padding: EdgeInsets.all(screenSize.width * 0.05),
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(
                        vertical: screenSize.height * 0.01),
                    child: Image.asset(
                      'assets/images/confirmation-exit.png',
                      width: screenSize.width * 0.5,
                      height: screenSize.width * 0.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.02),
                  Text(
                    "Keluar Aplikasi",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 20,
                      color: AppColors.textColorBlack,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.015),
                  Text(
                    "Yakin mau keluar aplikasi?",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: AppColors.textColorBlack,
                    ),
                  ),
                  SizedBox(height: screenSize.height * 0.03),
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          borderColor: AppColors.primaryColor,
                          borderRadius: 20,
                          height: screenSize.height * 0.06,
                          elevation: 0,
                          color: AppColors.containerColorWhite,
                          onPressed: onCancel,
                          child: Text(
                            "Batal",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: screenSize.width * 0.03),
                      Expanded(
                        child: PrimaryButton(
                          elevation: 0,
                          color: AppColors.primaryColor,
                          height: screenSize.height * 0.06,
                          borderRadius: 20,
                          onPressed: onConfirm,
                          child: Text(
                            "Keluar",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.textColorwhite,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            top: -50,
            right: 10,
            child: GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textColorBlack,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
