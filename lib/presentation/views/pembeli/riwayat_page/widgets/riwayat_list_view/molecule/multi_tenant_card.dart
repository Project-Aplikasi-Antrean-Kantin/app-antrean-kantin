import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page/widgets/pesanan_item/pesanan_item.dart';

class MultiTenantCard extends StatelessWidget {
  final int? tenantId;
  final List<Pesanan> pesananList;
  final String role;
  final String tabLabel;

  const MultiTenantCard({
    super.key,
    required this.tenantId,
    required this.pesananList,
    required this.role,
    required this.tabLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.blackColor600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "No. Pesanan Multitenant",
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor900,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor900,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "MLT-$tenantId",
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor100,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          ...pesananList.map((p) => PesananItem(
                pesanan: p,
                role: role,
                tabLabel: tabLabel,
              )),
        ],
      ),
    );
  }
}
