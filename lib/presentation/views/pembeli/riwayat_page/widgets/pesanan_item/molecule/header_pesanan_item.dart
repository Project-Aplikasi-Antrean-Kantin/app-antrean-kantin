import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/molecules/tipe_pesanan.dart';

class HeaderPesananItem extends StatelessWidget {
  final Pesanan pesanan;
  const HeaderPesananItem({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ImageByUrl(
              url: pesanan.listTransaksiDetail.isNotEmpty
                  ? pesanan.listTransaksiDetail[0].menus?.tenants?.gambar ?? ''
                  : '',
              height: 76,
              width: 76,
              fit: BoxFit.cover),
        ),
        Flexible(
          child: Column(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TipePesanan(
                    isPriority: pesanan.isPriority ?? 0,
                    size: 12,
                  ),
                  StatusPesanan(
                    status: pesanan.status,
                    size: 12,
                  ),
                ],
              ),
              Row(
                spacing: 8,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pesanan.listTransaksiDetail.isNotEmpty
                          ? pesanan.listTransaksiDetail[0].menus?.tenants
                                  ?.namaTenant ??
                              '-'
                          : '-',
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        color: AppColors.blackColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    FormatDate.dateTimeToStringDate(pesanan.createdAt),
                    style: GoogleFonts.poppins(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ],
              ),
              Wrap(
                spacing: 8, // Jarak antar item horizontal
                runSpacing: 4, // Jarak antar baris
                children:
                    pesanan.listTransaksiDetail.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isLast =
                      index == pesanan.listTransaksiDetail.length - 1;

                  return Text(
                    "${item.menus?.nama}${isLast ? '' : ', '}",
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontSize: 12,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
