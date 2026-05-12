import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

class TenantInfo extends StatelessWidget {
  final TenantModel tenant;
  const TenantInfo({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 3,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          tenant.namaTenant,
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            HugeIcon(
              icon: Iconsax.clock,
              size: 20,
              color: tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? AppColors.warningColor
                      : AppColors.successColor
                  : AppColors.errorColor,
            ),
            const SizedBox(width: 4),
            Text(
              tenant.isOnline == true
                  ? tenant.busyUntil != null
                      ? 'Sibuk'
                      : 'Buka'
                  : 'Tutup',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
            const SizedBox(width: 4),
            const Text('|'),
            const SizedBox(width: 4),
            Text(
              '${tenant.jamBuka?.substring(0, 5) ?? '09:30'} - ${tenant.jamTutup?.substring(0, 5) ?? '17:00'}',
              style: TextStyle(
                color: tenant.isOnline == true
                    ? tenant.busyUntil != null
                        ? AppColors.warningColor
                        : AppColors.successColor
                    : AppColors.errorColor,
              ),
            ),
          ],
        ),
        Row(
          children: [
            HugeIcon(
              icon: Iconsax.bag_tick,
              color: AppColors.secondaryColor,
              size: 20,
            ),
            const SizedBox(width: 4),
            Text(
              tenant.transaksiBerhasil.toString(),
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'pesanan berhasil',
              style: TextStyle(color: AppColors.primaryColor, fontSize: 14),
            )
          ],
        ),
        Text(
          'Harga mulai dari ${tenant.range}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
