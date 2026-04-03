import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';

class DeliveryInfo extends StatelessWidget {
  final DeliveryStatus status;
  final Pesanan pesanan;
  const DeliveryInfo({super.key, required this.status, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 4,
        children: [
          if (status == DeliveryStatus.diantar)
            Row(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text('Kode Pemesanan',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: semibold,
                            color: AppColors.blackColor))),
                Expanded(
                    child: Text(
                  '${pesanan.kodePemesanan}',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ))
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Pembeli',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.blackColor)),
              Text('No. Pesanan',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.blackColor,
                  ))
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${pesanan.namaPembeli}',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600)),
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  'ORDER-${pesanan.id}',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor100,
                    fontSize: 10,
                    fontWeight: bold,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
