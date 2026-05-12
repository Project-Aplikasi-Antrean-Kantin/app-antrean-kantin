import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:saver_gallery/saver_gallery.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/organisms/qris_payment_card/qris_payment_card.dart';
import 'package:testgetdata/utils/qris_image_saver.dart';

class KodeVaPage extends StatefulWidget {
  final TopUpModel currentVa;
  const KodeVaPage({super.key, required this.currentVa});

  @override
  State<KodeVaPage> createState() => _KodeVaPageState();
}

class _KodeVaPageState extends State<KodeVaPage> {
  Timer? _timer;
  int _secondsRemaining = 0;

  String formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final secs = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$secs";
  }

  void startCountdown() {
    _timer?.cancel(); // stop timer sebelumnya kalau ada
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void initState() {
    super.initState();
    checkTimeDifference();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> checkTimeDifference() async {
    final savedTime = widget.currentVa.akhirBayar;
    final count = widget.currentVa.kodeBayar.contains('https') ? 900 : 3600;

    final now = DateTime.now();
    final secondsDiff = savedTime.difference(now).inSeconds;
    if (secondsDiff <= 0) {
      // waktu sudah habis
      _secondsRemaining = 0;
    } else if (secondsDiff > count) {
      _secondsRemaining = count;
    } else {
      _secondsRemaining = secondsDiff;
    }
    startCountdown();
  }

  // Di _QrisPaymentCardState

  @override
  Widget build(BuildContext context) {
    final isQris = widget.currentVa.kodeBayar.contains('https');
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _secondsRemaining == 0
            ? AppColors.textColorBlack
            : isQris
                ? AppColors.whiteColor
                : AppColors.textColorBlack,
        backgroundColor: _secondsRemaining == 0
            ? AppColors.backgroundColor
            : isQris
                ? AppColors.primaryColor
                : AppColors.backgroundColor,
        toolbarHeight: 50,
        title: Text(
          'Pembayaran Isi Saldo',
          style: GoogleFonts.poppins(
            color: _secondsRemaining == 0
                ? AppColors.textColorBlack
                : isQris
                    ? AppColors.whiteColor
                    : AppColors.textColorBlack,
            fontSize: 18,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: _secondsRemaining == 0
          ? AppColors.backgroundColor
          : isQris
              ? AppColors.primaryColor
              : AppColors.backgroundColor,
      body: _secondsRemaining == 0
          ? _buildExpiredPayment()
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: isQris ? 24 : 12),
                child: QrisPaymentCard(
                  nominal: int.parse(widget.currentVa.nominal),
                  admin: int.parse(widget.currentVa.biayaAdmin ?? '0'),
                  total: int.parse(widget.currentVa.nominal) +
                      int.parse(widget.currentVa.biayaAdmin ?? '0'),
                  urlQris: widget.currentVa.kodeBayar,
                  secondsRemaining: _secondsRemaining,
                  onGantiNominal: () {
                    final prefs = SharedPreferences.getInstance();
                    final user = Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).user;
                    prefs.then((value) => value.remove('current_va'));
                    Navigator.pushReplacement(
                      context,
                      CustomPageBuilder(page: TopupPage()),
                    );
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildExpiredPayment() {
    return SafeArea(
        child: Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(image: const AssetImage('assets/images/payment-end.png')),
            Text(
              'Sesi Telah Berakhir',
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor900,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'yah... sesi pembayaranmu telah berakhir ',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: const Color(0xFF585858),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            GestureDetector(
              onTap: () {
                final prefs = SharedPreferences.getInstance();
                prefs.then((value) => value.remove('current_va'));
                Navigator.pushReplacement(
                  context,
                  CustomPageBuilder(page: TopupPage()),
                );
              },
              child: Container(
                margin: EdgeInsets.only(top: 16),
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                width: MediaQuery.of(context).size.width - 48,
                child: Center(
                    child: Text('Ganti Nominal',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ))),
              ),
            )
          ],
        ),
      ),
    ));
  }

  Widget _buildQrisPayment() {
    return Center(
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 70),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white,
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(20),
                    child: Image.asset(
                      'assets/images/watermark-foodlab.png',
                      fit: BoxFit
                          .cover, // atau BoxFit.contain tergantung kebutuhan
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          _rowText('Metode Bayar:', 'QRIS'),
                          DashedDivider(
                              height: 1.5, color: AppColors.blackColor100),
                          _rowText(
                              'Nominal:',
                              FormatCurrency.intToStringCoin(
                                  int.parse(widget.currentVa.nominal))),
                          _rowText(
                              'Admin:',
                              FormatCurrency.intToStringCoin(int.parse(
                                  widget.currentVa.biayaAdmin ?? '0'))),
                          _rowText(
                              'Total:',
                              FormatCurrency.intToStringCoin(
                                  int.parse(widget.currentVa.nominal) +
                                      int.parse(
                                          widget.currentVa.biayaAdmin ?? '0'))),
                          DashedDivider(
                              height: 1.5, color: AppColors.blackColor100),
                          Center(
                            child: Text('QR Bayar',
                                style: GoogleFonts.poppins(
                                    color: AppColors.blackColor400)),
                          ),
                          Center(
                            child: Column(
                              children: [
                                if (_secondsRemaining > 0)
                                  Image.network(
                                    widget.currentVa.kodeBayar,
                                    width: 200,
                                    height: 200,
                                    loadingBuilder:
                                        (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        width: 200,
                                        height: 200,
                                        child: Image.asset(
                                          'assets/images/dummy.jpeg', // placeholder statis
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    },
                                  ),
                                Text(
                                  'Sisa waktu: ${formatDuration(_secondsRemaining)}',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            height: 64,
          ),
          Row(spacing: 8, children: [
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: AppColors.primaryColor100,
                        padding: EdgeInsets.all(16)),
                    child: Text('Ganti Nominal',
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        )),
                    onPressed: () {
                      final prefs = SharedPreferences.getInstance();
                      final user = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).user;
                      prefs.then((value) => value.remove('current_va'));
                      Navigator.pushReplacement(
                        context,
                        CustomPageBuilder(page: TopupPage()),
                      );
                    })),
            Expanded(
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        backgroundColor: AppColors.primaryColor700,
                        padding: EdgeInsets.all(16)),
                    child: Text('Unduh',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontWeight: FontWeight.w600,
                        )),
                    onPressed: () async {
                      if (_secondsRemaining <= 0) {
                        Fluttertoast.showToast(
                            msg: "Waktu telah habis, silahkan ganti nominal");
                        return;
                      }
                      final url = "${widget.currentVa.kodeBayar}";

                      final response = await http.get(Uri.parse(url));

                      if (response.statusCode == 200) {
                        String imageName =
                            "top_up_foodlab_qris_${DateTime.now().millisecondsSinceEpoch}";

                        await SaverGallery.saveImage(
                          Uint8List.fromList(response.bodyBytes),
                          quality: 60,
                          fileName: imageName,
                          androidRelativePath: "Pictures/foodlab/images",
                          skipIfExists: false,
                        );

                        Fluttertoast.showToast(
                          msg: "Berhasil disimpan",
                          backgroundColor: AppColors.successColor,
                          textColor: AppColors.whiteColor,
                        );
                      } else {
                        Fluttertoast.showToast(
                          msg: "Gagal disimpan, silahkan coba lagi",
                          backgroundColor: AppColors.errorColor,
                          textColor: AppColors.whiteColor,
                        );
                      }
                    })),
          ])
        ],
      ),
    );
  }

  Widget _rowText(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.blackColor,
                fontWeight: FontWeight.w600)),
        Text(value,
            style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}
