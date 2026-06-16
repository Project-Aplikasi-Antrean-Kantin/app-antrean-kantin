import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/kode_va_page.dart';
import 'package:testgetdata/presentation/views/pembeli/koin_info_page.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class SaldoInfo extends StatefulWidget {
  const SaldoInfo({super.key});

  @override
  State<SaldoInfo> createState() => _SaldoInfoState();
}

class _SaldoInfoState extends State<SaldoInfo> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            flex: 60,
            child: Semantics(
              identifier: 'riwayatSaldoButton',
              button: true,
              child: Material(
                key: const Key('riwayatSaldoButton'),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent, // hilangkan efek ripple
                  onTap: () async {
                    if (_isNavigating) return;
                    _isNavigating = true;
                    final internetConnection = await hasInternetAccess();
                    if (!internetConnection) {
                      CustomSnackbar.warning('Tidak ada koneksi internet');
                      return;
                    }
                    Navigator.push(
                        context, CustomPageBuilder(page: const KoinInfoPage())).then((value) => _isNavigating = false);
                  },
                  child: Consumer<CoinProvider>(
                      builder: (context, coinProvider, child) {
                    return Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/images/icon-koin-blue.png',
                                height: 32),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FoodLAB Koin',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                                Text(
                                  FormatCurrency.intToStringCurrency(
                                    coinProvider.saldoKoin,
                                  ),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: const SizedBox(
              height: 52,
              child: VerticalDivider(
                color: Color(0xFFCDCDCD),
                thickness: 1,
              ),
            ),
          ),
          Expanded(
            flex: 30,
            child: Semantics(
              identifier: 'topUpButton',
              button: true,
              child: Material(
                key: const Key('topUpButton'),
                color: Colors.transparent,
                child: InkWell(
                  splashColor: Colors.transparent, // hilangkan efek ripple
                  // behavior: HitTestBehavior
                  //     .opaque, // ✅ area tap jadi selebar parent-nya

                  onTap: () async {
                     if (_isNavigating) return;
                    _isNavigating = true;
                    final prefs = await SharedPreferences.getInstance();
                    final jsonCurrentVa = prefs.getString('current_va');
                    TopUpModel? currentVa;
                    final internetConnection = await hasInternetAccess();
                    if (!internetConnection) {
                      CustomSnackbar.warning('Tidak ada koneksi internet');
                      return;
                    }
                    if (jsonCurrentVa != null) {
                      final decoded =
                          jsonDecode(jsonCurrentVa); // ini Map<String, dynamic>
                      final kodeBayar = decoded['kode_bayar'] as String;
                      if (kodeBayar.contains('https:')) {
                        currentVa = TopUpModel.fromJsonQris(decoded);
                      } else {
                        currentVa =
                            TopUpModel.fromJson(decoded); // ini TopUpModel
                      }
                    }

                    if (jsonCurrentVa != null &&
                        jsonCurrentVa.isNotEmpty &&
                        currentVa != null) {
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: KodeVaPage(
                            currentVa: currentVa,
                          ),
                        ),
                      ).then((value) => _isNavigating = false);
                    } else {
                      Navigator.push(
                          context, CustomPageBuilder(page: TopupPage())).then((value) => _isNavigating = false);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/icon-koin-plus-blue.png',
                          height: 32,
                        ),
                        Text(
                          'Isi Koin',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
