import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

void showBottomSheetPing(
    {required BuildContext context, required VoidCallback onFinish}) {
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
                        'assets/images/megaphone.png',
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      "Kirim Notifikasi ke Pembeli",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 20,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    Text(
                      "Pembeli akan menerima pemberitahuan bahwa Anda sedang mencoba menghubungi mereka.",
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
                            borderRadius: 100,
                            height: screenSize.height * 0.06,
                            elevation: 0,
                            color: AppColors.containerColorWhite,
                            child: Text(
                              "Batal",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.primaryColor300,
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.03),
                        Expanded(
                          child: PrimaryButton(
                            color: AppColors.primaryColor,
                            elevation: 0,
                            height: screenSize.height * 0.06,
                            borderRadius: 100,
                            child: Text(
                              "Kirim",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.textColorwhite,
                              ),
                            ),
                            onPressed: onFinish,
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
