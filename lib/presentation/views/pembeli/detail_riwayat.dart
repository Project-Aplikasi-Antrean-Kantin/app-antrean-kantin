import 'dart:async';
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/step_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/step_progress.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class DetailRiwayat extends StatefulWidget {
  final Pesanan pesanan;
  final VoidCallback refreshData;
  final String token;
  final String label;

  const DetailRiwayat({
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

  @override
  void initState() {
    super.initState();
    if (_onMessageSubscription == null) {
      _onMessageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.data['title']?.toString().toLowerCase();
        if (title != null && title.contains('pesanan')) {
          _refreshData();
        }
      });
    }
  }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
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
        final List<StepModel> steps =
            historyProvider.selectedPesanan!.isAntar == 1
                ? historyProvider.selectedPesanan!.status == 'refund_selesai'
                    ? [
                        StepModel(
                          padding: EdgeInsets.only(left: 0),
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Ditolak',
                          icon: HugeIcons.strokeRoundedCancel02,
                        ),
                        StepModel(
                          textAlign: TextAlign.center,
                          title: 'Siap Diantar',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.center,
                          title: 'Diantar',
                          icon: HugeIcons.strokeRoundedUserRoadside,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                    : [
                        StepModel(
                          padding: EdgeInsets.only(left: 0),
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Diproses',
                          icon: HugeIcons.strokeRoundedPan03,
                        ),
                        StepModel(
                          textAlign: TextAlign.center,
                          title: 'Siap Diantar',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.center,
                          title: 'Diantar',
                          icon: HugeIcons.strokeRoundedUserRoadside,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                : historyProvider.selectedPesanan!.status == 'refund_selesai'
                    ? [
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.start,
                          title: 'Ditolak',
                          icon: HugeIcons.strokeRoundedCancel02,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 8),
                          textAlign: TextAlign.center,
                          title: 'Siap Diambil',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                    : [
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.start,
                          title: 'Diproses',
                          icon: HugeIcons.strokeRoundedPan03,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 8),
                          textAlign: TextAlign.center,
                          title: 'Siap Diambil',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ];
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          floatingActionButton: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              final chatType =
                  getChatType(historyProvider.selectedPesanan!.status);
              final isValidStatus = historyProvider.selectedPesanan!.status !=
                      'selesai' &&
                  historyProvider.selectedPesanan!.status !=
                      'pesanan_ditolak' &&
                  historyProvider.selectedPesanan!.status != 'refund_selesai';
              print(historyProvider.unreadMessagesList
                  .contains(historyProvider.selectedPesanan!.id));
              final canChatTenant = historyProvider.availableChatList
                      .contains(historyProvider.selectedPesanan!.id) &&
                  chatType == 'tenant';

              if (widget.label == 'Beli') if (isValidStatus) {
                return SizedBox(
                  width: screenWidth - 48, // ini dia kuncinya!
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      print("cek");
                      final connectivityResult = await hasInternetAccess();
                      print("yahaha");
                      if (!connectivityResult) {
                        Fluttertoast.showToast(
                            msg: "Tidak ada koneksi internet",
                            backgroundColor: AppColors.errorColor,
                            textColor: Colors.white);
                        return;
                      }
                      if (chatType == 'tenant' && widget.label == 'Beli') {
                        if (!canChatTenant) {
                          Fluttertoast.showToast(
                              msg:
                                  "Harus tenant yang melakukan chat terlebih dahulu");
                          return;
                        }
                      }
                      await historyProvider.removeUnreadMessages(
                          historyProvider.selectedPesanan!.id);
                      Navigator.push(
                          context,
                          CustomPageBuilder(
                              page: ChatPage(
                            pesanan: historyProvider.selectedPesanan!,
                            chatType: chatType,
                          )));
                    },
                    backgroundColor: chatType == 'tenant'
                        ? canChatTenant
                            ? AppColors.primaryColor
                            : Colors.grey
                        : AppColors.primaryColor,
                    label: Center(
                      child: Text(
                        'Chat ${chatType == 'driver' ? 'Driver' : widget.label == 'Beli' ? 'Penjual' : 'Pembeli'}',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  width: screenWidth - 48, // ini dia kuncinya!
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      final connectivityResult = await hasInternetAccess();
                      if (!connectivityResult) {
                        Fluttertoast.showToast(
                            msg: "Tidak ada koneksi internet",
                            backgroundColor: AppColors.errorColor,
                            textColor: Colors.white);
                        return;
                      }
                      if (historyProvider.selectedPesanan!
                              .listTransaksiDetail[0].menus?.tenants ==
                          null) return;
                      final cartMenu =
                          historyProvider.selectedPesanan!.toCartMenuList();

                      cartProvider.setCurrentTenant(
                        historyProvider.selectedPesanan!.listTransaksiDetail[0]
                            .menus!.tenants!,
                        cartMenu,
                      );

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
                    backgroundColor: AppColors.primaryColor,
                    label: Center(
                      child: Text(
                        'Pesan Lagi',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              else {
                if (isValidStatus) {
                  return SizedBox(
                    width: screenWidth - 48, // ini dia kuncinya!
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        print("cek");
                        final connectivityResult = await hasInternetAccess();
                        print("yahaha");
                        if (!connectivityResult) {
                          Fluttertoast.showToast(
                              msg: "Tidak ada koneksi internet",
                              backgroundColor: AppColors.errorColor,
                              textColor: Colors.white);
                          return;
                        }

                        await historyProvider.removeUnreadMessages(
                            historyProvider.selectedPesanan!.id);
                        Navigator.push(
                            context,
                            CustomPageBuilder(
                                page: ChatPage(
                              pesanan: historyProvider.selectedPesanan!,
                              chatType: chatType,
                            )));
                      },
                      backgroundColor: chatType == 'tenant'
                          ? canChatTenant
                              ? AppColors.primaryColor
                              : Colors.grey
                          : AppColors.primaryColor,
                      label: Center(
                        child: Text(
                          'Chat ${chatType == 'driver' ? 'Driver' : widget.label == 'Beli' ? 'Penjual' : 'Pembeli'}',
                          style: GoogleFonts.poppins(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: semibold,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            child: RefreshIndicator(
              backgroundColor: AppColors.backgroundColor,
              color: AppColors.primaryColor,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowLeft02,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Rincian Pesanan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildStatus(
                        historyProvider.selectedPesanan?.status ?? 'selesai'),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAlamatPengantaran(
                          historyProvider.selectedPesanan!),
                    ),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildHeaderPesanan(
                          historyProvider.selectedPesanan!, context, steps),
                    ),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        spacing: 16,
                        children: [
                          StepProgress(
                              isRefund:
                                  historyProvider.selectedPesanan!.status ==
                                      'refund_selesai',
                              currentStep: getCurrentStep(
                                  historyProvider.selectedPesanan!.status,
                                  historyProvider.selectedPesanan!.isAntar),
                              steps: steps),
                          if (historyProvider.selectedPesanan!.isAntar == 1 &&
                              (historyProvider.selectedPesanan!.status ==
                                      'diantar' ||
                                  historyProvider.selectedPesanan!.status ==
                                      'selesai'))
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  spacing: 8,
                                  children: [
                                    ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: ImageByUrl(
                                            url: historyProvider
                                                .selectedPesanan!.fotoDriver!,
                                            height: 48,
                                            width: 48)),
                                    Text(
                                      historyProvider
                                          .selectedPesanan!.namaDriver!,
                                      style: GoogleFonts.poppins(
                                        color: AppColors.blackColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  "Driver",
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                        ],
                      ),
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
                    ...pesananPembeli.map((item) => PesananItemWidget(
                          pesanan: item,
                          tolakPesanan: () {},
                          terimaPesanan: () {},
                        )),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSubtotalSection(
                          historyProvider.selectedPesanan!, totalItem),
                    ),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildBiayaLainSection(
                          historyProvider.selectedPesanan!),
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
                                  context, historyProvider.selectedPesanan!),
                              child: Text('Detail',
                                  style: GoogleFonts.poppins(
                                    color: AppColors.primaryColor,
                                    fontSize: 14,
                                  )),
                            )
                          ],
                        ),
                      ),

                    SizedBox(
                      height: 96,
                    )
                    // _buildDivider(),
                    // _buildRincianPesanan(pesanan),
                    // _buildButton(pesanan.status, context),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future showBottomSheetPenolakan(BuildContext context, Pesanan pesanan) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      builder: (context) => SafeArea(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 18,
                left: 18,
                right: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text('Catatan Penolakan',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor)),
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.blackColor100, width: 2),
                    ),
                    height: 124,
                    child: TextField(
                      controller:
                          TextEditingController(text: pesanan.catatanPenolakan),
                      readOnly: true,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan catatan...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                      ),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  PrimaryButton(
                      borderRadius: 16,
                      height: 48,
                      color: AppColors.primaryColor,
                      child: Text(
                        'Tutup',
                        style: GoogleFonts.poppins(
                            color: AppColors.whiteColor100,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(String status) {
    return Center(
      child: Text(
        capitalizeFirstLetter(status.replaceAll('_', ' ')),
        style: GoogleFonts.poppins(
          color: getStatusColor(status),
          fontWeight: FontWeight.w500,
          fontSize: 18,
        ),
      ),
    );
  }

  String getChatType(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return 'tenant';
      case 'pesanan_diproses':
        return 'tenant';
      case 'siap_diambil':
        return 'tenant';
      case 'siap_diantar':
        return 'tenant';
      case 'diantar':
        return 'driver';
      default:
        return 'proses';
    }
  }

  int getCurrentStep(String status, int isAntar) {
    if (isAntar == 1) {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diantar':
          return 3;
        case 'diantar':
          return 4;
        case 'selesai':
          return 5;
        case 'refund_selesai':
          return 2;
        case 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
    } else {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diambil':
          return 3;
        case 'selesai':
          return 4;
        case 'refund_selesai' || 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'refund_selesai':
        return AppColors.primaryColor;
      case 'selesai':
        return AppColors.successColor;
      case 'pesanan_ditolak':
        return AppColors.errorColor;
      case 'pesanan_diproses':
        return AppColors.warningColor;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildAlamatPengantaran(Pesanan pesanan) {
    return Container(
      width: double.infinity,
      child: Column(
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lokasi Pengantaran",
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tanggal',
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              )
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pesanan.isAntar == 1
                      ? '${pesanan.namaRuangan}${pesanan.catatanLokasi != null && pesanan.catatanLokasi!.trim().isNotEmpty ? ' (${pesanan.catatanLokasi})' : ''}'
                      : capitalizeFirstLetter(
                          'Tidak Diantar, Ambil Pesanan ke ${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant ?? "-"}'),
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPesanan(
      Pesanan pesanan, BuildContext context, List<StepModel> steps) {
    return Column(
      spacing: 4,
      children: [
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
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${pesanan.namaPembeli}',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                )),
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
        ),
      ],
    );
  }

  Widget _buildSubtotalSection(Pesanan pesanan, int totalItem) {
    return Column(
      spacing: 8,
      children: [
        DashedDivider(height: 2, color: AppColors.blackColor100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sub total : ${totalItem} Menu",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(
                  pesanan.total - pesanan.ongkosKirim),
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiayaLainSection(Pesanan pesanan) {
    return Column(
      children: [
        _buildRowText("Biaya layanan", pesanan.biayaLayanan),
        if (pesanan.isAntar == 1) const SizedBox(height: 10),
        if (pesanan.isAntar == 1)
          _buildRowText("Biaya Pengantaran", pesanan.ongkosKirim),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(pesanan.total),
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRowText(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(value),
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
