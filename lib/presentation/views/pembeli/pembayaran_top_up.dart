import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:url_launcher/url_launcher.dart';

class PembayaranTopUp extends StatefulWidget {
  final int selectedNominal;
  final String selectedMethod;
  const PembayaranTopUp(
      {super.key, required this.selectedNominal, required this.selectedMethod});

  @override
  State<PembayaranTopUp> createState() => _PembayaranTopUpState();
}

class _PembayaranTopUpState extends State<PembayaranTopUp> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TopupProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final setting = provider.settings
        .firstWhere((element) => element.nama == widget.selectedMethod);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: AppColors.backgroundColor,
        toolbarHeight: 50,
        title: Text(
          'Pembayaran Isi Saldo',
          style: GoogleFonts.poppins(
            color: AppColors.textColorBlack,
            fontSize: 18,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 50),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Nominal: ',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.blackColor,
                            )),
                        Text(
                            '${FormatCurrency.intToStringCoin(widget.selectedNominal)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.primaryColor,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Metode bayar:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.blackColor,
                            )),
                        Text('${widget.selectedMethod}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.primaryColor,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tujuan:',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.blackColor,
                            )),
                        Text('${provider.namaPenerima}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              color: AppColors.primaryColor,
                            )),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          setting.nama == "Bank Mandiri"
                              ? provider.noMandiri
                              : setting.nilai,
                          style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(
                                text: setting.nama == "Bank Mandiri"
                                    ? provider.noMandiri
                                    : setting.nilai));
                            Fluttertoast.showToast(
                                msg: "Berhasil disalin",
                                backgroundColor: AppColors.successColor,
                                textColor: AppColors.whiteColor);
                          },
                          child: Text('Salin',
                              style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final message = Uri.encodeComponent(
                    "Verifikasi Topup Koin \n\nNominal: *Rp ${FormatCurrency.intToStringCoin(widget.selectedNominal)}* \nEmail: *${user.email}* \n\nSaya telah melakukan pembayaran via ${widget.selectedMethod}. Mohon untuk memverifikasi. \n\nBerikut bukti pembayaran saya:\n_[Bukti bayar]_",
                  );
                  final whatsappUrl = Uri.parse(
                      'https://wa.me/${provider.noKonfirmasi}?text=$message');
                  final playStoreUrl = Uri.parse(
                      'https://play.google.com/store/apps/details?id=com.whatsapp');

                  if (await canLaunchUrl(whatsappUrl)) {
                    await launchUrl(whatsappUrl,
                        mode: LaunchMode.externalApplication);
                  } else if (!await launchUrl(playStoreUrl,
                      mode: LaunchMode.externalApplication)) {
                    throw 'Could not launch $playStoreUrl';
                  }
                },
                child: Container(
                  margin: EdgeInsets.only(top: 50, left: 12, right: 12),
                  width: MediaQuery.of(context).size.width - 48,
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text('Konfirmasi Bayar',
                        style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 24),
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cara Isi Saldo  Via Transfer Bank Lain / Dompet Digital',
                      style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w700),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Langkah-langkah pembayaran',
                                style: GoogleFonts.poppins(
                                  color: AppColors.blackColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                )),
                            Container(
                                margin: const EdgeInsets.only(left: 8),
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          '1. Salin nomor rekening atau nomor dompet digital admin',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13)),
                                      Text(
                                          '2. Lakukan pembayaran, jangan tutup halaman pembayaran isi saldo ini',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13)),
                                      Text(
                                          '3. Setelah melakukan pebayaran, screenshoot bukti bayar',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13)),
                                      Text(
                                          '4. Lakukan konfirmasi pembayaran kepada admin',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13)),
                                      Text(
                                          '5. Tunggu maksimal 1 jam pembayaran akan di proses ',
                                          style: GoogleFonts.poppins(
                                              fontSize: 13)),
                                      Text(
                                          '6. Metode pengisian saldo ini hanya dilayani pada jam tertentu dengan durasi 30 menit (09.00, 12.00, 15.00, 18.00). ',
                                          style:
                                              GoogleFonts.poppins(fontSize: 13))
                                    ]))
                          ]),
                    ),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}
