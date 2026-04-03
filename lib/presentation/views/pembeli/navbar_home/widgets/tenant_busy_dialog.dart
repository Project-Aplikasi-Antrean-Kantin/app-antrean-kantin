import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class TenantBusyDialog extends StatelessWidget {
  final VoidCallback onClose;
  final Future<void> Function() onConfirm;

  const TenantBusyDialog({
    super.key,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tenant Sibuk',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.warningColor,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: HugeIcon(
                    size: 24,
                    icon: HugeIcons.strokeRoundedCancelCircle,
                    color: AppColors.warningColor.withOpacity(0.5),
                  ),
                )
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tenant sedang sibuk, tekan siap untuk mengubah status menjadi buka kembali dalam 3 menit.',
              style: GoogleFonts.poppins(),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: PrimaryButton(
                height: 32,
                width: 96,
                borderRadius: 16,
                color: AppColors.warningColor,
                onPressed: () async {
                  await onConfirm();
                  Navigator.pop(context);
                },
                child: Text(
                  "Siap",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
