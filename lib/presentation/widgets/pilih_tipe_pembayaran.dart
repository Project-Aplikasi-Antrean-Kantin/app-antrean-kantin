import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_keranjang.dart';

class PilihTipePembayaran extends StatelessWidget {
  final List<String> tipePembayaran;
  final String? pilihTipePembayaran;
  final Function(String?) selectedPembayaran;

  const PilihTipePembayaran({
    required this.tipePembayaran,
    required this.pilihTipePembayaran,
    required this.selectedPembayaran,
  });

  @override
  Widget build(BuildContext context) {
    log(pilihPembayaran.toString());
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          child: Text(
            'Tipe Pembayaran',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: semibold,
              color: AppColors.textColorBlack,
            ),
          ),
        ),
        const SizedBox(
          height: 7,
        ),
        GestureDetector(
          onTap: () {
            bottomSheetTipePembayaran(context, (option2) {
              if (option2 == 'Bayar Tunai') {
                selectedPembayaran('cod');
              } else {
                selectedPembayaran('Transfer');
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 25,
            ),
            height: MediaQuery.of(context).size.width * 0.18,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
              border: Border.all(
                color: Colors.grey,
                width: 0.2,
              ),
            ),
            child: Row(
              children: [
                if (pilihTipePembayaran != null)
                  Icon(
                    pilihTipePembayaran == 'cod'
                        ? Icons.payments_outlined
                        : Icons.credit_card,
                  ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: pilihTipePembayaran != null ? 25 : 0),
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          pilihTipePembayaran == null
                              ? 'Pilih Tipe Pembayaran'
                              : (pilihTipePembayaran == 'cod'
                                  ? 'Bayar Tunai'
                                  : pilihTipePembayaran!),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                          ),
                        ),
                        if (pilihTipePembayaran != null)
                          Text(
                            pilihTipePembayaran == 'cod'
                                ? 'Siapkan uang tunai kamu'
                                : 'Pastikan saldo kamu cukup',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ),
                const Icon(
                  Icons.arrow_drop_down,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
