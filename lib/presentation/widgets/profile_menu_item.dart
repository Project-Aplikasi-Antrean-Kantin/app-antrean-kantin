import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showIconArrow;
  Color? iconColor;
  bool? status;

  ProfileMenuItem({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.showIconArrow = true,
    this.iconColor,
    this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border(
            // top: BorderSide(
            //   width: 0.2,
            //   color: Colors.grey[900]!,
            // ),
            bottom: BorderSide(
              width: 0.2,
              color: Colors.grey,
            ),
          ),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: medium,
              ),
            ),
            const Spacer(
              flex: 1,
            ),
            if (title == 'Status Tenant') // Hanya untuk Status Tenant
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(
                    width: 0.5,
                    color: iconColor ??
                        AppColors.textColorBlack, // Fallback ke warna default
                  ),
                ),
                child: Text(
                  status! ? "Buka" : "Tutup",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: regular,
                    color: iconColor ?? AppColors.textColorBlack, // Fallback
                  ),
                ),
              ),
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
