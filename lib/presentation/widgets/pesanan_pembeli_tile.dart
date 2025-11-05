import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class PesananItemWidget extends StatelessWidget {
  final ListTransaksiDetail pesanan;
  final bool withPadding;
  final bool isTenant;
  final Function() tolakPesanan;
  final Function() terimaPesanan;

  PesananItemWidget({
    Key? key,
    required this.isTenant,
    required this.pesanan,
    required this.tolakPesanan,
    required this.terimaPesanan,
    this.withPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(
          horizontal: withPadding ? 24 : 0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageByUrl(
                key: Key('${pesanan.id}-${pesanan.namaMenu}'),
                url: pesanan.menus!.gambar,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width / 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  Text(
                    capitalizeFirstLetter(pesanan.namaMenu),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  if (isTenant)
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.warningColor200,
                      ),
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: 'Catatan :',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF313131),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w700,
                                height: 1.60,
                              ),
                            ),
                            TextSpan(
                              text: pesanan.catatan != '' &&
                                      pesanan.catatan != null
                                  ? '  ${pesanan.catatan}'
                                  : ' -',
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF313131),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w400,
                                height: 1.60,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isTenant)
                    pesanan.catatan != '' && pesanan.catatan != null
                        ? Text(
                            '${pesanan.catatan}',
                            style: TextStyle(
                                color: AppColors.blackColor200, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          )
                        : Text(
                            'Catatan Kosong',
                            style: TextStyle(
                                color: AppColors.blackColor200, fontSize: 12),
                          ),
                  if (!isTenant)
                    GestureDetector(
                      onTap: () {
                        _showDetailPesanan(context, pesanan);
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.warningColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          spacing: 4,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.note_2,
                                color: AppColors.whiteColor, size: 16),
                            Text('Detail',
                                style: GoogleFonts.poppins(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                )),
                          ],
                        ),
                      ),
                    )
                ],
              ),
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 8,
              children: [
                Text(
                  FormatCurrency.intToStringCurrency(pesanan.harga),
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    color: AppColors.primaryColor,
                  ),
                  alignment: Alignment.center, // ini alternatif dari Center()
                  child: Text(
                    '${pesanan.jumlah}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ))
          ],
        ));
  }

  Future<void> _showDetailPesanan(
    BuildContext context,
    ListTransaksiDetail pesanan,
  ) {
    return showModalBottomSheet(
        backgroundColor: AppColors.whiteColor100,
        enableDrag: false,
        context: context,
        builder: (context) {
          return SafeArea(
            child: Stack(children: [
              Container(
                padding: EdgeInsets.all(24),
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${pesanan.namaMenu}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.blackColor),
                        ),
                        Text(FormatCurrency.intToStringCurrency(pesanan.harga),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.blackColor))
                      ],
                    ),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageByUrl(
                                    key: Key(
                                        '${pesanan.id}-${pesanan.menus!.gambar}-${pesanan.catatan}'),
                                    url: pesanan.menus!.gambar,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(
                                            pesanan.menus!.nama),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      pesanan.catatan != '' &&
                                              pesanan.catatan != null
                                          ? Text(
                                              '${pesanan.catatan}',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColor200,
                                                  fontSize: 12),
                                            )
                                          : Text(
                                              'Catatan Kosong',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColor200,
                                                  fontSize: 12),
                                            ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  spacing: 8,
                                  children: [
                                    Text(
                                      FormatCurrency.intToStringCurrency(
                                          pesanan.harga),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: AppColors.primaryColor,
                                      ),
                                      alignment: Alignment
                                          .center, // ini alternatif dari Center()
                                      child: Text(
                                        '${pesanan.jumlah}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            SizedBox(height: 60)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.warningColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          );
        });
  }
}
