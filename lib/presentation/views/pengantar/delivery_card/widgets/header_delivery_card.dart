import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/molecules/tipe_pesanan.dart';

class HeaderDeliveryCard extends StatelessWidget {
  final Pesanan pesanan;
  final int lengthListPesanan;
  final bool isMultiTenantHidden;
  const HeaderDeliveryCard(
      {super.key,
      required this.pesanan,
      required this.lengthListPesanan,
      required this.isMultiTenantHidden});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TipePesanan(isPriority: pesanan.isPriority ?? 0),
              StatusPesanan(status: pesanan.status),
            ],
          ),
          SizedBox(
            height: 8,
          ),
          if (isMultiTenantHidden)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lokasi Pengantaran',
                  style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 14,
                      fontWeight: semibold),
                ),
                Text(
                  'Tanggal',
                  style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 14,
                      fontWeight: semibold),
                ),
              ],
            ),
          if (pesanan.multitenantId == null || lengthListPesanan == 1)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                    child: Text(
                        '${pesanan.namaRuangan} ${pesanan.catatanLokasi != null && pesanan.catatanLokasi!.trim().isNotEmpty ? ' (${pesanan.catatanLokasi})' : ''}',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.blackColor))),
                Flexible(
                    child: Text(
                        FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.blackColor)))
              ],
            ),
        ],
      ),
    );
  }
}
