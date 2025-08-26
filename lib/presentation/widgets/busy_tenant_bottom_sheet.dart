import 'package:app_settings/app_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

void showBusyBottomSheet({
  required BuildContext context,
  required VoidCallback onRetry,
}) {
  final screenSize = MediaQuery.of(context).size;
  final isSmallScreen = screenSize.height < 600;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    enableDrag: false,
    builder: (_) {
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.symmetric(
                          vertical: screenSize.height * 0.01),
                      child: Image.asset(
                        'assets/images/tenant-sibuk.png',
                        width: screenSize.width * 0.5,
                        height: screenSize.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      "Yah, tenant sedang sibuk",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 20,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    Text(
                      "Pelayanan akan membutuhkan waktu lebih lama, mau tetap melanjutkan pembelian atau mengganti tenant?",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.normal,
                        fontSize: isSmallScreen ? 12 : 14,
                        color: AppColors.textColorBlack,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.height * 0.03),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            borderColor: AppColors.primaryColor300,
                            borderRadius: 20,
                            height: screenSize.height * 0.07,
                            elevation: 0,
                            color: AppColors.containerColorWhite,
                            child: Text(
                              "Ganti",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.primaryColor300,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.05),
                        Expanded(
                          child: PrimaryButton(
                            elevation: 0,
                            height: screenSize.height * 0.07,
                            borderRadius: 20,
                            child: Text(
                              "Lanjut",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: AppColors.textColorwhite,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
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
                onTap: () {
                  Navigator.pop(context);
                },
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
    },
  );
}
