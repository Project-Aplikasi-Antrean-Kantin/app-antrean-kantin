import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/alamat_pengantaran.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/bottom_sheet_penolakan.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/bukti_pengantaran.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/cetak_nota.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/bayar_button.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/chat_button.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/fab/pesan_lagi_button.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/hubungi_pembeli.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/info_pesanan.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/ringkasan_pembayaran.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/step_with_driver.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat/widgets/subtotal_section.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/molecules/tipe_pesanan.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';

class DetailRiwayat extends StatefulWidget {
  final Pesanan pesanan;
  final VoidCallback refreshData;
  final bool? fromCartPage;
  final String token;
  final String label;

  const DetailRiwayat({
    this.fromCartPage,
    super.key,
    required this.refreshData,
    required this.token,
    required this.label,
    required this.pesanan,
  });

  @override
  State<DetailRiwayat> createState() => _DetailRiwayatState();
}

class _DetailRiwayatState extends State<DetailRiwayat> {
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  Timer? _timer;
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;

  bool isBleTurnedOn = false;
  bool isLoadingBluetooth = false;
  late HistoryProvider historyProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      historyProvider = Provider.of<HistoryProvider>(context, listen: false);

      if (widget.label.toLowerCase() == 'jual' &&
          authProvider.user.role.contains('tenant')) {
        // startScan(printerProvider);
      }

      if (widget.pesanan.status == 'pending' && widget.fromCartPage == true) {
        Navigator.push(context,
            CustomPageBuilder(page: CheckoutQris(pesanan: widget.pesanan)));
      }
    });
    if (_onMessageSubscription == null) {
      _onMessageSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        final title = message.data['title']?.toString().toLowerCase();
        final transaksiId = message.data['body']?.split(' ')[1].trim();
        final historyProvider =
            Provider.of<HistoryProvider>(context, listen: false);

        if (title != null &&
            title.contains('pesanan') &&
            !title.contains('diantar') &&
            transaksiId != null &&
            historyProvider.selectedPesanan!.id.toString() == transaksiId) {
          _refreshData();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _onMessageSubscription?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      historyProvider.clearSelectedPesanan();
    });
    _flutterThermalPrinterPlugin.stopScan();
    super.dispose();
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final List<ListTransaksiDetail> pesananPembeli =
        widget.pesanan.listTransaksiDetail;

    int totalItem = 0;

    for (var item in pesananPembeli) {
      // subtotal dari BE masih bermasalah, sementara pakai ini
      totalItem += item.jumlah;
    }

    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          floatingActionButton: Consumer2<CartProvider, AuthProvider>(
              builder: (context, cartProvider, authProvider, child) {
            final pesanan = historyProvider.selectedPesanan!;
            final chatType = getChatType(pesanan, authProvider.user.nama);

            final isValidStatus = ![
              'selesai',
              'pesanan_ditolak',
              'refund_selesai',
              'gagal_bayar'
            ].contains(pesanan.status);

            final canChatTenant =
                (historyProvider.availableChatList.contains(pesanan.id) &&
                        chatType == 'tenant') ||
                    widget.label == 'Jual';

            /// =============================
            /// 1️⃣ BAYAR BUTTON
            /// =============================
            if (pesanan.status == 'pending' && widget.label == 'Beli') {
              return BayarButton(pesanan: pesanan);
            }

            /// =============================
            /// 2️⃣ HIDE BUTTON CASE
            /// =============================
            if (pesanan.status == 'diantar' && widget.label == 'Jual') {
              return const SizedBox();
            }

            /// =============================
            /// 3️⃣ BELI FLOW
            /// =============================
            if (widget.label == 'Beli') {
              if (!isValidStatus) {
                return PesanLagiButton(
                  cartProvider: cartProvider,
                  pesanan: pesanan,
                );
              }

              return ChatButton(
                chatType: chatType,
                pesanan: pesanan,
                label: widget.label,
                canChatTenant: canChatTenant,
                historyProvider: historyProvider,
              );
            }

            /// =============================
            /// 4️⃣ SELLER FLOW
            /// =============================
            if (isValidStatus) {
              return ChatButton(
                chatType: chatType,
                pesanan: pesanan,
                label: widget.label,
                canChatTenant: canChatTenant,
                historyProvider: historyProvider,
              );
            }

            return const SizedBox();
          }),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          appBar: AppBar(
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: HugeIcon(
                color: AppColors.whiteColor900,
                icon: HugeIcons.strokeRoundedArrowLeft01,
                size: 32,
              ),
            ),
            backgroundColor: AppColors.backgroundColor,
            centerTitle: true,
            title: Text(
              "Detail Pesanan",
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
            child: RefreshIndicator(
              backgroundColor: AppColors.backgroundColor,
              color: AppColors.primaryColor,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TipePesanan(
                              isPriority:
                                  historyProvider.selectedPesanan!.isPriority ??
                                      0),
                          StatusPesanan(
                            status: historyProvider.selectedPesanan?.status ??
                                'selesai',
                          ),
                        ],
                      ),
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: AlamatPengantaran(
                        pesanan: historyProvider.selectedPesanan!,
                      ),
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: InfoPesanan(
                        pesanan: historyProvider.selectedPesanan!,
                      ),
                    ),
                    if (historyProvider.selectedPesanan!.status != 'pending' &&
                        historyProvider.selectedPesanan!.status !=
                            'gagal_bayar')
                      DashedDivider(height: 2, color: AppColors.blackColor100),
                    if (historyProvider.selectedPesanan!.status != 'pending' &&
                        historyProvider.selectedPesanan!.status !=
                            'gagal_bayar')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: StepWithDriver(
                            pesanan: historyProvider.selectedPesanan!),
                      ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${historyProvider.selectedPesanan!.listTransaksiDetail[0].menus?.tenants?.namaTenant}',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                    ...pesananPembeli.map(
                      (item) => PesananItemWidget(
                        isTenant: widget.label == 'Jual' ? true : false,
                        pesanan: item,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: SubtotalSection(
                        pesanan: historyProvider.selectedPesanan!,
                        totalItem: totalItem,
                      ),
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: RingkasanPembayaran(
                        pesanan: historyProvider.selectedPesanan!,
                      ),
                    ),
                    if (historyProvider.selectedPesanan!.catatanPenolakan !=
                        null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              'Catatan Penolakan',
                              style: GoogleFonts.poppins(
                                color: AppColors.errorColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => showBottomSheetPenolakan(
                                context,
                                historyProvider.selectedPesanan!,
                              ),
                              child: Text(
                                'Detail',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (historyProvider.selectedPesanan!.buktiPengantaran !=
                        null)
                      BuktiPengantaran(
                          pesanan: historyProvider.selectedPesanan!),
                    if (widget.label == 'Antar' &&
                        widget.pesanan.status == 'diantar')
                      HubungiPembeli(
                          pesanan: widget.pesanan,
                          historyProvider: historyProvider),
                    if (widget.pesanan.status != 'pending' &&
                        widget.pesanan.status != 'refund_selesai' &&
                        widget.pesanan.status != 'pesanan_masuk' &&
                        widget.pesanan.status != 'gagal_bayar' &&
                        widget.pesanan.cashbackAmount != null &&
                        widget.pesanan.cashbackAmount! > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              "Cashback",
                              style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: AppColors.successColor),
                            ),
                            const Spacer(),
                            Text(
                              FormatCurrency.intToStringCurrency(
                                  widget.pesanan.cashbackAmount ?? 0),
                              style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: AppColors.successColor),
                            ),
                          ],
                        ),
                      ),
                    if (widget.label.toLowerCase() == 'jual')
                      CetakNota(
                          pesanan: historyProvider.selectedPesanan!,
                          flutterThermalPrinter: _flutterThermalPrinterPlugin),
                    SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String getChatType(Pesanan pesanan, String namaUser) {
    switch (pesanan.status) {
      case 'pesanan_masuk':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'pesanan_diproses':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diambil':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diantar':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'diantar':
        return 'driver';
      default:
        return 'proses';
    }
  }
}
