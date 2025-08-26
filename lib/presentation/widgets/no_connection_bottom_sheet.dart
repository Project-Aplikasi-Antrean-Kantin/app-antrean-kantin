import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

void showNoConnectionBottomSheet({
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
                        'assets/images/lost-connection.png',
                        width: screenSize.width * 0.5,
                        height: screenSize.width * 0.5,
                        fit: BoxFit.contain,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.02),
                    Text(
                      "Yah, Internetnya mati...",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        fontSize: isSmallScreen ? 16 : 20,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                    SizedBox(height: screenSize.height * 0.015),
                    Text(
                      "Cek koneksi WiFi atau Internet perangkatmu dan coba lagi ya....",
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
                              "Coba Lagi",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.primaryColor300,
                              ),
                            ),
                            onPressed: () async {
                              final interneConnection =
                                  await hasInternetAccess();
                              if (interneConnection) {
                                Navigator.pop(context);
                              } else {
                                Fluttertoast.showToast(
                                    msg: 'Periksa koneksi internet',
                                    backgroundColor: AppColors.errorColor);
                              }
                            },
                          ),
                        ),
                        SizedBox(width: screenSize.width * 0.03),
                        Expanded(
                          child: PrimaryButton(
                            elevation: 0,
                            height: screenSize.height * 0.06,
                            borderRadius: 100,
                            child: Text(
                              "Pengaturan",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: isSmallScreen ? 12 : 14,
                                color: AppColors.textColorwhite,
                              ),
                            ),
                            onPressed: () {
                              AppSettings.openAppSettings(
                                  type: AppSettingsType.settings);
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
