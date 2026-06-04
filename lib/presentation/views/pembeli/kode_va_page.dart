import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/organisms/qris_payment_card/qris_payment_card.dart';

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
}
