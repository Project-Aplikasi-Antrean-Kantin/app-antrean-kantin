import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class PrimaryActionButton extends StatelessWidget {
  final Size screenSize;
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;

  const PrimaryActionButton({
    required this.screenSize,
    required this.isLoading,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return PrimaryButton(
      isLoading: isLoading,
      width: screenSize.width * 0.4,
      height: screenSize.height * 0.065,
      borderRadius: 20,
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
