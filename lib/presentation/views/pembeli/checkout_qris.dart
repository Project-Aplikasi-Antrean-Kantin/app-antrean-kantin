import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';

import 'package:testgetdata/presentation/widgets/organisms/qris_payment_card/qris_payment_card.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class CheckoutQris extends StatefulWidget {
  final Pesanan? pesanan;
  final CashierTransaction? cashierTransaction;
  const CheckoutQris({super.key, this.pesanan, this.cashierTransaction});

  @override
  State<CheckoutQris> createState() => _CheckoutQrisState();
}

class _CheckoutQrisState extends State<CheckoutQris>
    with WidgetsBindingObserver {
  Timer? _timer;
  int _secondsRemaining = 0;
  FlutterThermalPrinter printer = FlutterThermalPrinter.instance;
  StreamSubscription<RemoteMessage>? _onCashierSuccess;

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
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final printerProvider =
          Provider.of<PrinterProvider>(context, listen: false);
      cartProvider.clearCartOnly();
      _onCashierSuccess =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        final title = message.data['title']?.toString().toLowerCase();
        final body = message.data['body']?.toString().toLowerCase();

        if (title?.contains('kasir') != true || body == null) return;

        final parts = body.split(' ');
        if (parts.length < 2) return;

        try {
          final printerDevice = printerProvider.selectedPrinter;
          final transaction = widget.cashierTransaction;

          if (printerDevice == null || transaction == null) return;

          await printer.connect(printerDevice);

          final data = await generateReceiptCashier(
            transaction,
            printerDevice,
            context,
          );

          await printer.printData(
            printerDevice,
            data,
            longData: true,
          );

          if (!mounted) return;

          if (Navigator.canPop(context)) {
            Navigator.pop(context);
            CustomSnackbar.success('Pesanan terbuat');
          }
        } catch (e, s) {
          debugPrint('Print error: $e');
          debugPrint('$s');
        }
      });
    });

    checkTimeDifference();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _onCashierSuccess?.cancel();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Refresh data ketika app kembali dari background
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    final pesanan = widget.pesanan;
    if (state == AppLifecycleState.resumed && pesanan != null) {
      TransactionRemoteDataSource()
          .getOrderById(user.token, pesanan.id.toString())
          .then((pesanan) {
        historyProvider.updateSelectedPesanan(pesanan);
        historyProvider.updatedPesanan(pesanan, 'user');
        if (pesanan.status == 'pesanan_masuk') {
          Navigator.pop(context);
        }
      });
    }
  }

  Future<void> checkTimeDifference() async {
    // print("widget.pesanan.expiredQris: ${widget.pesanan?.expiredQris}");
    if (widget.pesanan != null) {
      final savedTime = widget.pesanan!.expiredQris;
      final count = 900;
      if (savedTime == null) return;

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
    } else {
      final savedTime = widget.cashierTransaction!.expiredQris;
      final count = 900;
      if (savedTime == null) return;

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
  }

  @override
  Widget build(BuildContext context) {
    final total =
        widget.pesanan?.totalQris ?? widget.cashierTransaction?.total ?? 0;

    final biayaAdmin = widget.pesanan?.biayaAdmin ?? 0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: _secondsRemaining == 0
            ? AppColors.textColorBlack
            : AppColors.whiteColor,
        backgroundColor: _secondsRemaining == 0
            ? AppColors.backgroundColor
            : AppColors.primaryColor,
        toolbarHeight: 50,
        title: Text(
          'Pembayaran Pesanan',
          style: GoogleFonts.poppins(
            color: _secondsRemaining == 0
                ? AppColors.textColorBlack
                : AppColors.whiteColor,
            fontSize: 18,
            fontWeight: semibold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: _secondsRemaining == 0
          ? AppColors.backgroundColor
          : AppColors.primaryColor,
      body: _secondsRemaining == 0
          ? _buildExpiredPayment()
          : SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: QrisPaymentCard(
                  nominal: total - biayaAdmin,
                  admin: widget.pesanan?.biayaAdmin,
                  total: widget.pesanan?.totalQris ??
                      widget.cashierTransaction?.total,
                  urlQris: widget.pesanan?.urlQris ??
                      widget.cashierTransaction?.urlQris ??
                      '',
                  secondsRemaining: _secondsRemaining,
                ),
              ),
            ),
    );
  }

  Widget _buildExpiredPayment() {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
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
              onTap: () async {
                final connectivityResult = await hasInternetAccess();
                if (!connectivityResult) {
                  CustomSnackbar.error("Tidak ada koneksi internet");
                  return;
                }
                if (widget.cashierTransaction != null) {
                  Navigator.pop(context);
                  return;
                }
                if (historyProvider.selectedPesanan!.listTransaksiDetail[0]
                        .menus?.tenants ==
                    null) return;
                final cartMenu =
                    historyProvider.selectedPesanan!.toCartMenuList();

                cartProvider.setCurrentTenant(
                    historyProvider.selectedPesanan!.listTransaksiDetail[0]
                        .menus!.tenants!,
                    cartMenu,
                    null);
                Navigator.pop(context);
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.push(
                    context,
                    CustomPageBuilder(
                      page: MenuTenant(
                        url:
                            '${MasbroConstants.url}/tenants/${historyProvider.selectedPesanan!.listTransaksiDetail[0].menus!.tenants!.id}',
                        cart: cartMenu,
                      ),
                    ),
                  );
                });
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
                    child: Text('Pesan Lagi',
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
