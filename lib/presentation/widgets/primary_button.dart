// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class PrimaryButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final VoidCallback? onLongPress;

  final bool? isLoading;
  final double? paddingVertical;
  final double? paddingHorizontal;
  final bool? isEnabled;
  final Color? color;
  final double? width;
  final double? height;
  final double? elevation;
  final Color? borderColor;
  final bool? reverseLoading;
  final double? borderRadius;
  final Color? forgroundColor;
  final String? waitingText;
  const PrimaryButton({
    this.paddingVertical,
    this.paddingHorizontal,
    this.onLongPress,
    super.key,
    required this.child,
    this.onPressed,
    this.isLoading = false,
    this.reverseLoading = false,
    this.isEnabled = true,
    this.color,
    this.width,
    this.height,
    this.elevation,
    this.borderColor,
    this.borderRadius,
    this.forgroundColor,
    this.waitingText,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onLongPress: onLongPress,
      onPressed: isEnabled!
          ? !isLoading!
              ? onPressed
              : () {}
          : () {
              Fluttertoast.showToast(msg: waitingText ?? 'Tunggu sebentar');
            },
      style: ElevatedButton.styleFrom(
        elevation: elevation ?? 1,
        padding: EdgeInsets.symmetric(
            horizontal: paddingHorizontal ?? 16,
            vertical: paddingVertical ?? 14),
        shape: RoundedRectangleBorder(
          // borderRadius: BorderRadius.all(
          //   Radius.circular(6.0),
          // ),
          borderRadius: BorderRadius.all(
            Radius.circular(
              borderRadius ?? 6.0,
            ),
          ),
          side: borderColor != null
              ? BorderSide(
                  color:
                      isEnabled! ? borderColor! : AppColors.containerColorGrey,
                )
              : BorderSide.none,
        ),
        backgroundColor: isEnabled!
            ? !isLoading!
                ? color ?? AppColors.primaryColor
                : reverseLoading!
                    ? Colors.white
                    : AppColors.containerColorGrey
            : AppColors.blackColor100,
        foregroundColor:
            forgroundColor ?? AppColors.primaryColor.withOpacity(0.5),
        shadowColor: elevation != 0 ? null : Colors.transparent,
        minimumSize: Size(
          width ?? double.infinity,
          height ?? 40,
        ),
      ),
      child: !isLoading!
          ? child
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 15,
                  width: 15,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color:
                        reverseLoading! ? AppColors.primaryColor : Colors.white,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  "Loading",
                  style: GoogleFonts.poppins(
                    fontWeight: semibold,
                    fontSize: 16,
                    color:
                        reverseLoading! ? AppColors.primaryColor : Colors.white,
                  ),
                )
              ],
            ),
    );
  }
}
