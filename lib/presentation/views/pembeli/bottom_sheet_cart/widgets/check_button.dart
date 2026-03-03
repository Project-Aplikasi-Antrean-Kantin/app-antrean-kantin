import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class CheckButton extends StatelessWidget {
  final bool onChecked;
  final VoidCallback onCheck;
  const CheckButton(
      {super.key, required this.onChecked, required this.onCheck});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onCheck,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: onChecked ? AppColors.primaryColor : Colors.grey,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.check,
            size: 18,
            color: onChecked ? AppColors.primaryColor : Colors.transparent,
          ),
        ),
      ),
    );
  }
}
