import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class CountChange extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;
  final double width;
  final double height;
  final bool withBorderSeparator;

  const CountChange({
    super.key,
    required this.withBorderSeparator,
    required this.count,
    required this.onChanged,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: withBorderSeparator
            ? const Border.symmetric(
                vertical: BorderSide(
                  color: AppColors.primaryColor,
                  width: 2,
                ),
              )
            : null,
      ),
      width: width,
      key: ValueKey(count),
      height: height,
      alignment: Alignment.center,
      child: TextFormField(
        initialValue: count.toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryColor,
        ),
        onChanged: (value) {
          final intCount = int.tryParse(value);
          if (intCount != null && intCount >= 0) {
            onChanged(intCount); // ← callback
          }
        },
      ),
    );
  }
}
