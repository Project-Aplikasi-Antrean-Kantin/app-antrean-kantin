import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class BuktiPengantaran extends StatelessWidget {
  final Pesanan pesanan;
  const BuktiPengantaran({super.key, required this.pesanan});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        spacing: 8,
        children: [
          Text(
            'Bukti Pengantaran',
            style: GoogleFonts.poppins(
              color: AppColors.primaryColor,
              fontSize: 14,
              fontWeight: semibold,
            ),
          ),
          GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => Dialog(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ImageByUrl(
                      height: MediaQuery.of(context).size.height / 2,
                      width: MediaQuery.of(context).size.width - 48,
                      url:
                          '/storage/${pesanan.buktiPengantaran!}', // ganti dengan path/URL gambarnya
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
            child: Text(
              'Lihat Foto',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
