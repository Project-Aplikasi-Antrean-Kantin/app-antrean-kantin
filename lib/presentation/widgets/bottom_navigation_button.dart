import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class BottomNavigationButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onTap;
  final Color color;

  const BottomNavigationButton({
    Key? key,
    required this.isEnabled,
    required this.onTap,
    required this.color,
  }) : super(key: key);

  static const _height = 48.0;
  static const _borderRadius = 30.0;

  @override
  Widget build(BuildContext context) {
    final buttonColor = !isEnabled ? Colors.grey[400]! : color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: _height,
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(_borderRadius),
      ),
      child: InkWell(
        onTap: !isEnabled ? null : onTap,
        child: Center(
          child: Text(
            'Pesan sekarang',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
              fontWeight: semibold,
            ),
          ),
        ),
      ),
    );
  }
}
