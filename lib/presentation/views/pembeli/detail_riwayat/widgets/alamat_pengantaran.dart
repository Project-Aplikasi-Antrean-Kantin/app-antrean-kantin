import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';

class AlamatPengantaran extends StatelessWidget {
  final Pesanan pesanan;
  const AlamatPengantaran({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Column(
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lokasi Pengantaran",
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tanggal',
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pesanan.isAntar == 1
                      ? '${pesanan.namaRuangan}${pesanan.catatanLokasi != null && pesanan.catatanLokasi!.trim().isNotEmpty ? ' (${pesanan.catatanLokasi})' : ''}'
                      : capitalizeFirstLetter(
                          'Tidak Diantar, Ambil Pesanan ke ${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant ?? "-"}',
                        ),
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
