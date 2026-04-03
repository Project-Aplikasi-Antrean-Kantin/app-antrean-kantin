import 'package:flutter/material.dart';

class _PrimaryActionButton extends StatelessWidget {
  final Size screenSize;
  final bool isLoading;
  final String text;
  final VoidCallback onPressed;

  const _PrimaryActionButton({
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
