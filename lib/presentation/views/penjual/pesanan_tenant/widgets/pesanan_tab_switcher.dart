import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class PesananTabSwitcher extends StatelessWidget {
  final int selectedActivity;
  final ValueChanged<int> onSwitch;

  const PesananTabSwitcher({
    Key? key,
    required this.selectedActivity,
    required this.onSwitch,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryColor600,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 8,
          children: [
            _TabItem(
                label: 'Online',
                index: 0,
                selectedActivity: selectedActivity,
                onTap: onSwitch),
            _TabItem(
                label: 'Kasir',
                index: 1,
                selectedActivity: selectedActivity,
                onTap: onSwitch),
          ],
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final int index;
  final int selectedActivity;
  final ValueChanged<int> onTap;

  const _TabItem({
    required this.label,
    required this.index,
    required this.selectedActivity,
    required this.onTap,
  });

  bool get isSelected => selectedActivity == index;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isSelected ? AppColors.whiteColor : Colors.transparent,
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color:
                    isSelected ? AppColors.primaryColor : AppColors.whiteColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
