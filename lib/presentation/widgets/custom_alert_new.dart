import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class CustomAlertDialog extends StatelessWidget {
  final String title;
  String? textButtonCancel;
  String? textButtonOk;
  final String message;
  final bool showCancelButton;
  final bool showOkButton;
  final VoidCallback? onOkPressed;
  final VoidCallback? onCancelPressed;
  final Color? colorOkButton;
  final Color? titleColor;

  CustomAlertDialog({
    Key? key,
    this.colorOkButton,
    this.titleColor,
    required this.title,
    this.textButtonCancel,
    this.textButtonOk,
    required this.message,
    this.showCancelButton = true,
    this.showOkButton = true,
    this.onOkPressed,
    this.onCancelPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(25),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: title.toLowerCase().contains('peringatan')
                    ? Colors.red
                    : titleColor ?? AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (showCancelButton) ...[
                  TextButton(
                    onPressed:
                        onCancelPressed ?? () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(100, 30)),
                    ),
                    child: Text(
                      textButtonCancel ?? "Batal",
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                if (showOkButton) ...[
                  TextButton(
                    onPressed: onOkPressed ?? () => Navigator.of(context).pop(),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          colorOkButton ?? AppColors.primaryColor),
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                          side: BorderSide(
                              color: colorOkButton ?? AppColors.primaryColor),
                        ),
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(100, 30)),
                    ),
                    child: Text(
                      textButtonOk ?? "OK",
                      style: GoogleFonts.poppins(
                        color: AppColors.textColorwhite,
                        fontWeight: semibold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
