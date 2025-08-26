import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/custom_toggle.dart';

// ignore: must_be_immutable
class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showIconArrow;
  Color? iconColor;
  Color? titleColor;
  bool? status;
  final Future<void> Function(bool value)? onChangeToggle;

  ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showIconArrow = true,
    this.iconColor,
    this.titleColor,
    this.status,
    this.onChangeToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1,
            color: AppColors.blackColor100,
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: HugeIcon(
                icon: icon,
                size: 24,
                color: AppColors.primaryColor,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: titleColor,
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            if (title == 'Tenant Buka' ||
                title == 'Status Driver' &&
                    status != null &&
                    onChangeToggle != null) // Hanya untuk Status Tenant
              CustomToggle(
                  value: status ?? false,
                  onChanged: (status) {
                    onChangeToggle!(status);
                  }),
            if (showIconArrow)
              const Icon(
                Icons.keyboard_arrow_right_outlined,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
