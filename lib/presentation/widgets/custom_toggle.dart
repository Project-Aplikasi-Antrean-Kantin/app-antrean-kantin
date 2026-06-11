import 'package:flutter/material.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

class CustomToggle extends StatelessWidget {
  final bool value; // Ganti dari initialValue ke value
  final ValueChanged<bool> onChanged;
  final String? label;

  const CustomToggle({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
  }) : super(key: key);

  void _toggle() {
    onChanged(!value);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (label != null) ...[
          Text(label!),
          const SizedBox(width: 10),
        ],
        Semantics(
          identifier: 'toggleButton',
          button: true,
          child: GestureDetector(
            key: const Key('toggleButton'),
            onTap: _toggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 30,
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: value ? AppColors.primaryColor200 : Colors.grey.shade400,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? AppColors.primaryColor
                        : AppColors.blackColor300,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
