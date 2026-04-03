import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';

class DeliveryListItem extends StatelessWidget {
  final Pesanan pesanan;
  final int index;
  final int lengthListPesanan;
  const DeliveryListItem(
      {super.key,
      required this.pesanan,
      required this.index,
      required this.lengthListPesanan});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final showKodePenolakan =
        pesanan.isPriority == 1 && pesanan.driverId != null;

    final tenantName =
        (pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant ??
                    'Unknown Tenant')
                .trim()
                .isEmpty
            ? 'Unknown Tenant'
            : capitalizeFirstLetter(
                pesanan.listTransaksiDetail[0].menus!.tenants!.namaTenant);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        // Header tenant
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                    lengthListPesanan > 1 ? 'Tenant ${index}' : 'Tenant',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: AppColors.whiteColor100)),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: screenSize.width * 0.4),
                child: Text(
                  tenantName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showKodePenolakan)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Kode Penolakan",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    )),
                Container(
                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text("${pesanan.kodePenolakan}",
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor100,
                          fontSize: 12,
                          fontWeight: bold,
                        ))),
              ],
            ),
          ),

        // Subheader
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Detail Pesanan',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.whiteColor900),
          ),
        ),

        // Daftar item dari tenant ini
        ...pesanan.listTransaksiDetail.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: PesananItemWidget(
                isTenant: false,
                withPadding: false,
                pesanan: item,
              ),
            )),
      ],
    );
  }
}
