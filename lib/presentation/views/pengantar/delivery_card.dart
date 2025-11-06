import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/show_bottom_sheet_ping.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class DeliveryCard extends StatefulWidget {
  final VoidCallback onSuccess;
  final Pesanan pesanan;
  final int ongkir;
  final List<ListTransaksiDetail> listTransaksiDetail;
  final DeliveryStatus status;
  final String userToken;

  const DeliveryCard({
    required this.ongkir,
    required this.listTransaksiDetail,
    Key? key,
    required this.onSuccess,
    required this.pesanan,
    required this.status,
    required this.userToken,
  }) : super(key: key);

  @override
  State<DeliveryCard> createState() => _DeliveryCardState();
}

class _DeliveryCardState extends State<DeliveryCard> {
  bool _isLoading = false; // Local loading state for this card's button
  bool _isCooldown = false; // state untuk cooldown
  int _cooldownSeconds = 30; // lama cooldown (detik)
  Timer? _timer;
  String? deliveryImagePath;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
    });

    _timer = Timer(Duration(seconds: _cooldownSeconds), () {
      if (mounted) {
        setState(() {
          _isCooldown = false;
        });
      }
    });
  }

  Future<void> _handlePress() async {
    final connectivityResult = await hasInternetAccess();
    if (!connectivityResult) {
      Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');
      showNoConnectionBottomSheet(context: context, onRetry: () {});
      return;
    }
    try {
      final success = await DriverDataSource()
          .pingCustomer(widget.userToken, widget.pesanan.id.toString());

      if (success.success) {
        Fluttertoast.showToast(msg: 'Ping terkirim');
        Navigator.pop(context);
        _startCooldown(); // mulai cooldown kalau sukses
      } else {
        Fluttertoast.showToast(
            msg: '${success.error ?? 'Ping gagal terkirim'}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context, listen: true);
    final totalItemMenu = widget.pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);
    final groupedByTenant = <String, List<dynamic>>{};

// Kelompokkan berdasarkan tenant name
    for (var detail in widget.listTransaksiDetail) {
      final tenantName =
          (detail.menus?.tenants?.namaTenant ?? 'Unknown Tenant').trim().isEmpty
              ? 'Unknown Tenant'
              : capitalizeFirstLetter(detail.menus!.tenants!.namaTenant!);

      groupedByTenant.putIfAbsent(tenantName, () => []).add(detail);
    }

    final screenSize = MediaQuery.of(context).size;
    final isThereNewChat =
        historyProvider.unreadMessagesList.contains(widget.pesanan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.blackColor400.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey, width: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lokasi Pengantaran',
                      style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: semibold),
                    ),
                    Text(
                      'Tanggal',
                      style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: semibold),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                        child: Text(
                            '${widget.pesanan.namaRuangan} ${widget.pesanan.catatanLokasi != null && widget.pesanan.catatanLokasi!.trim().isNotEmpty ? ' (${widget.pesanan.catatanLokasi})' : ''}',
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.blackColor))),
                    Flexible(
                        child: Text(
                            FormatDate.formatDateTimeWithWIB(
                                widget.pesanan.createdAt),
                            style: GoogleFonts.poppins(
                                fontSize: 12, color: AppColors.blackColor)))
                  ],
                ),
              ],
            ),
          ),
          DashedDivider(color: AppColors.blackColor100, height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 4,
              children: [
                if (widget.status == DeliveryStatus.diantar)
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
                        '${widget.pesanan.kodePemesanan}',
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
                    Text('Pembeli',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: AppColors.blackColor)),
                    Text('No. Pesanan',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.blackColor,
                        ))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${widget.pesanan.namaPembeli}',
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w600)),
                    Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        'ORDER-${widget.pesanan.id}',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor100,
                          fontSize: 10,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          DashedDivider(color: AppColors.blackColor100, height: 2),
          // Widget utama
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: groupedByTenant.entries.map((entry) {
              final tenantName = entry.key;
              final items = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header tenant
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tenant',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600)),
                        ConstrainedBox(
                          constraints:
                              BoxConstraints(maxWidth: screenSize.width * 0.4),
                          child: Text(
                            tenantName,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                            style: GoogleFonts.poppins(
                              fontWeight: semibold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Subheader
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Detail Pesanan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),

                  // Daftar item dari tenant ini
                  ...items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: PesananItemWidget(
                          isTenant: false,
                          withPadding: false,
                          pesanan: item,
                          tolakPesanan: () {},
                          terimaPesanan: () {},
                        ),
                      )),
                ],
              );
            }).toList(),
          ),

          DashedDivider(color: AppColors.blackColor100, height: 2),
          _buildCostSection(widget.pesanan, totalItemMenu,
              widget.status == DeliveryStatus.siapDiantar),
          Consumer<DeliveryProvider>(
            builder: (context, deliveryProvider, child) => Padding(
              padding: const EdgeInsets.only(bottom: 16, right: 16, left: 16),
              child: Row(
                spacing: 8,
                mainAxisAlignment: widget.status == DeliveryStatus.siapDiantar
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.center,
                children: [
                  if ((widget.status == DeliveryStatus.diantar ||
                      widget.pesanan.driverId != null))
                    Expanded(
                        child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                shape:
                                    const CircleBorder(), // ✅ ini yang bikin benar-benar bundar
                                side: BorderSide(
                                    color: AppColors.primaryColor300, width: 2),
                                padding: const EdgeInsets.all(
                                    12), // jarak icon dengan border
                              ),
                              onPressed: () async {
                                final connectivityResult =
                                    await hasInternetAccess();
                                if (!connectivityResult) {
                                  Fluttertoast.showToast(
                                      msg: 'Tidak ada koneksi internet');
                                  showNoConnectionBottomSheet(
                                      context: context, onRetry: () {});
                                  return;
                                }
                                historyProvider
                                    .removeUnreadMessages(widget.pesanan.id);

                                Navigator.push(
                                  context,
                                  CustomPageBuilder(
                                    page: ChatPage(
                                      pesanan: widget.pesanan,
                                      chatType: "driver",
                                    ),
                                  ),
                                );
                              },
                              child: const Icon(
                                Iconsax.message_text_copy,
                                size: 24,
                                color: AppColors.primaryColor300,
                              ),
                            ),

                            // bulatan indikator
                            if (isThereNewChat)
                              Positioned(
                                right: 8,
                                top: 4,
                                child: Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            shape: const CircleBorder(),
                            side: BorderSide(
                              color: _isCooldown
                                  ? Colors.grey // abu kalau cooldown
                                  : AppColors.primaryColor300,
                              width: 2,
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                          onPressed: _isCooldown
                              ? null
                              : () => showBottomSheetPing(
                                  context: context,
                                  onFinish: _handlePress,
                                  canSend:
                                      !_isCooldown), // disable pas cooldown
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedMegaphone02,
                            color: _isCooldown
                                ? Colors.grey
                                : AppColors.primaryColor300,
                          ),
                        )
                      ],
                    )),
                  if (widget.pesanan.status == 'siap_diantar' ||
                      widget.pesanan.driverId == null)
                    PrimaryButton(
                      isLoading: _isLoading, // Use local loading state
                      elevation: 0,
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.065,
                      borderRadius: 20,
                      child: Text(
                        widget.status == DeliveryStatus.siapDiantar
                            ? widget.pesanan.driverId == null &&
                                    widget.pesanan.status == 'siap_diantar'
                                ? 'Antar Pesanan'
                                : 'Ambil'
                            : 'Selesai Diantar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true; // Set local loading state
                        });
                        final result = await deliveryProvider.updateOrder(
                          widget.status == DeliveryStatus.siapDiantar
                              ? 'diantar'
                              : 'selesai',
                          widget.userToken,
                          widget.pesanan.id,
                          widget.pesanan,
                        );
                        if (widget.pesanan.status == 'siap_diantar') {
                          Fluttertoast.showToast(
                            msg: result.success
                                ? widget.status == DeliveryStatus.siapDiantar
                                    ? 'Segera antar pesanan!'
                                    : 'Pesanan selesai 🎉'
                                : result.error ??
                                    'ORDER-${widget.pesanan.id} telah diantar oleh driver lain',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor:
                                result.success ? Colors.grey : Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          Fluttertoast.showToast(
                            msg: result.success
                                ? 'Segera datang ke tenant! Ini adalah pesanan Prioritas'
                                : result.error ??
                                    'ORDER-${widget.pesanan.id} telah diantar oleh driver lain',
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.BOTTOM,
                            backgroundColor:
                                result.success ? Colors.grey : Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        if (result.error != null) {
                          deliveryProvider.fetchOrders(
                              widget.userToken, widget.status);
                        }

                        if (mounted) {
                          // Check if the widget is still mounted
                          setState(() {
                            _isLoading = false;
                          });
                        }
                        if (result.success &&
                            widget.pesanan.status == 'siap_diantar')
                          widget.onSuccess();
                      },
                    ),
                  if ((widget.pesanan.status == 'pesanan_masuk' ||
                          widget.pesanan.status == 'pesanan_diproses') &&
                      widget.pesanan.driverId != null)
                    PrimaryButton(
                      isLoading: _isLoading, // Use local loading state
                      elevation: 0,
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.065,
                      borderRadius: 20,
                      child: Text(
                        widget.pesanan.status == 'pesanan_masuk'
                            ? 'Pesanan Diproses'
                            : 'Ubah ke Antar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onLongPress: () {
                        setState(() {
                          _isLoading = true; // Set local loading state
                        });
                        try {
                          deliveryProvider.updateOrder(
                            widget.pesanan.status == 'pesanan_masuk'
                                ? 'pesanan_diproses'
                                : 'diantar',
                            widget.userToken,
                            widget.pesanan.id,
                            widget.pesanan,
                          );
                          if (mounted) {
                            // Check if the widget is still mounted
                            setState(() {
                              _isLoading = false;
                            });
                          }
                          Fluttertoast.showToast(msg: 'Success');
                          if (widget.pesanan.status != 'pesanan_masuk')
                            widget.onSuccess();
                        } catch (e) {
                          Fluttertoast.showToast(msg: e.toString());
                        }
                      },
                    ),
                  if (widget.status == DeliveryStatus.diantar)
                    PrimaryButton(
                      isLoading: _isLoading, // Use local loading state
                      elevation: 0,
                      width: screenSize.width * 0.4,
                      height: screenSize.height * 0.065,
                      borderRadius: 20,
                      child: Text(
                        widget.status == DeliveryStatus.siapDiantar
                            ? 'Antar Pesanan'
                            : 'Selesai Diantar',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, setModalState) {
                                return DeliveryBottomSheet(
                                  onLoading: _isLoading,
                                  onImageSelected: (path) {
                                    if (path != null) {
                                      setState(() {
                                        deliveryImagePath = path;
                                      });
                                    }
                                  },
                                  canSend: true,
                                  onFinish: () async {
                                    if (deliveryImagePath == null) {
                                      Fluttertoast.showToast(
                                          msg: 'Foto tidak boleh kosong');
                                      return;
                                    }

                                    setModalState(() {
                                      _isLoading = true;
                                    });
                                    try {
                                      final result =
                                          await deliveryProvider.updateOrder(
                                        'selesai',
                                        widget.userToken,
                                        widget.pesanan.id,
                                        widget.pesanan,
                                        buktiPath: deliveryImagePath,
                                      );

                                      if (result.success) {
                                        Fluttertoast.showToast(
                                          msg: 'Pesanan selesai 🎉',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor:
                                              AppColors.successColor,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: result.error ??
                                              'ORDER-${widget.pesanan.id} telah diantar oleh driver lain',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0,
                                        );
                                      }
                                      Navigator.pop(
                                          context); // tutup sheet dulu
                                      if (mounted) {
                                        setState(() {
                                          deliveryImagePath = null;
                                          _isLoading = false;
                                        });
                                      }
                                    } catch (e) {
                                      Fluttertoast.showToast(msg: e.toString());
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    String? label,
    required String value,
    required TextStyle valueStyle,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label ?? '',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontSize: 10,
              fontWeight: regular,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: valueStyle,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildCostSection(Pesanan pesanan, int totalItemMenu, bool value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Biaya Pengantaran',
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 16,
                  fontWeight: bold,
                ),
              ),
              Text(
                FormatCurrency.intToStringCurrency(widget.ongkir),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 16,
                  fontWeight: bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStatus(String status) {
    switch (status) {
      case 'refund_selesai':
        return 'Refund';
      case 'gagal_bayar':
        return 'Gagal Bayar';
      case 'pending':
        return 'Pending';
      case 'selesai':
        return 'Selesai';
      case 'pesanan_ditolak':
        return 'Ditolak';
      case 'pesanan_diproses':
        return 'Diproses';
      case 'pesanan_masuk':
        return 'Pesanan Masuk';
      case 'diantar':
        return 'Diantar';
      case 'siap_diambil':
        return 'Siap Diambil';
      case 'siap_diantar':
        return 'Siap Diantar';
      default:
        return '';
    }
  }

  IconData getIconByStatus(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return Iconsax.login_1_copy;
      case 'pesanan_diproses':
        return Iconsax.repeat;
      case 'siap_diantar':
        return Iconsax.reserve;
      case 'siap_diambil':
        return Iconsax.flag_2;
      case 'diantar':
        return Iconsax.routing;
      case 'selesai':
        return Iconsax.tick_circle;
      case 'gagal_bayar':
        return Iconsax.money_remove;
      case 'refund_selesai':
        return Iconsax.directbox_send;
      case 'pending':
        return HugeIcons.strokeRoundedLoading03;
      default:
        return HugeIcons.strokeRoundedArrowReloadVertical;
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'pesanan_masuk':
        return AppColors.warningColor400;
      case 'pesanan_diproses':
        return AppColors.warningColor;
      case 'siap_diambil':
        return AppColors.secondaryColor;
      case 'siap_diantar':
        return AppColors.primaryColor300;

      case 'selesai':
        return AppColors.successColor;
      case 'pending':
        return AppColors.whiteColor600;
      case 'gagal_bayar':
        return AppColors.errorColor;
      case 'refund_selesai':
        return AppColors.blackColor;
      default:
        return AppColors.primaryColor;
    }
  }
}
