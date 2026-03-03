import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class RadioCircle extends StatelessWidget {
  final bool isSelected;

  const RadioCircle({required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.primaryColor : Colors.grey,
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? AppColors.primaryColor : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
