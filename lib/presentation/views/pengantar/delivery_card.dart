import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  final int lengthListPesanan;
  final int ongkir;
  final DeliveryStatus status;
  final String userToken;
  final bool isMultiple;
  final bool showChatOnly;
  final int index;
  final int userId;

  const DeliveryCard({
    required this.lengthListPesanan,
    required this.userId,
    required this.index,
    required this.ongkir,
    required this.showChatOnly,
    Key? key,
    required this.onSuccess,
    required this.pesanan,
    required this.status,
    required this.userToken,
    required this.isMultiple,
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
    final tenantName = (widget.pesanan.listTransaksiDetail[0].menus?.tenants
                    ?.namaTenant ??
                'Unknown Tenant')
            .trim()
            .isEmpty
        ? 'Unknown Tenant'
        : capitalizeFirstLetter(
            widget.pesanan.listTransaksiDetail[0].menus!.tenants!.namaTenant!);

    final screenSize = MediaQuery.of(context).size;
    final isThereNewChat =
        historyProvider.unreadMessagesList.contains(widget.pesanan.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.whiteColor900, width: 0.6),
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
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: widget.pesanan.isPriority == 1
                                  ? AppColors.primaryColor
                                  : Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            if (widget.pesanan.isPriority == 1)
                              Icon(Iconsax.flash_1,
                                  size: 16, color: AppColors.primaryColor),
                            Text(
                              widget.pesanan.isPriority == 1
                                  ? "Express"
                                  : "Reguler",
                              style: GoogleFonts.poppins(
                                color: widget.pesanan.isPriority == 1
                                    ? AppColors.primaryColor
                                    : AppColors.whiteColor800,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildStatus(
                      widget.pesanan.status,
                    ),
                  ],
                ),
                SizedBox(
                  height: 8,
                ),
                if ((widget.pesanan.multitenantId == null ||
                    widget.lengthListPesanan == 1))
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
                if (widget.pesanan.multitenantId == null ||
                    widget.lengthListPesanan == 1)
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
          if (widget.pesanan.multitenantId == null ||
              widget.lengthListPesanan == 1)
            DashedDivider(color: AppColors.blackColor100, height: 2),
          if (widget.pesanan.multitenantId == null ||
              widget.lengthListPesanan == 1)
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
            spacing: 8,
            children: [
              // Header tenant
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                          widget.isMultiple
                              ? 'Tenant ${widget.index}'
                              : 'Tenant',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: AppColors.whiteColor100)),
                    ),
                    ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: screenSize.width * 0.4),
                      child: Text(
                        tenantName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.end,
                        style: GoogleFonts.poppins(
                          fontWeight: semibold,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.pesanan.isPriority == 1 &&
                  widget.pesanan.driverId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Kode Penolakan",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                          )),
                      Container(
                          padding:
                              EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text("${widget.pesanan.kodePenolakan}",
                              style: GoogleFonts.poppins(
                                color: AppColors.whiteColor100,
                                fontSize: 12,
                                fontWeight: bold,
                              ))),
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
                      fontSize: 14,
                      color: AppColors.whiteColor900),
                ),
              ),

              // Daftar item dari tenant ini
              ...widget.pesanan.listTransaksiDetail.map((item) => Padding(
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
          ),
          if (widget.pesanan.multitenantId == null ||
              widget.lengthListPesanan == 1)
            DashedDivider(color: AppColors.blackColor100, height: 2),
          _buildCostSection(
              widget.pesanan,
              widget.pesanan.listTransaksiDetail.length,
              widget.status == DeliveryStatus.siapDiantar),
          if (widget.pesanan.multitenantId == null ||
              widget.pesanan.isPriority == 1 ||
              widget.lengthListPesanan == 1 ||
              widget.showChatOnly)
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
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              ElevatedButton(
                                key: Key('chatButton${widget.pesanan.id}'),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: AppColors.primaryColor100,
                                  shape:
                                      const CircleBorder(), // ✅ ini yang bikin benar-benar bundar

                                  padding: const EdgeInsets.all(
                                      8), // jarak icon dengan border
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
                                  Iconsax.message,
                                  size: 20,
                                  color: AppColors.primaryColor,
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
                          ElevatedButton(
                            key: Key('ping${widget.pesanan.id}'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isCooldown
                                  ? Colors.grey[300]
                                  : AppColors.primaryColor100,
                              elevation: 0,
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(8),
                            ),
                            onPressed: _isCooldown
                                ? null
                                : () => showBottomSheetPing(
                                    context: context,
                                    onFinish: _handlePress,
                                    canSend:
                                        !_isCooldown), // disable pas cooldown
                            child: SvgPicture.asset(
                              'assets/images/megaphone.svg',
                              color: _isCooldown
                                  ? Colors.grey
                                  : AppColors.primaryColor,
                              width: 20,
                              height: 20,
                            ),
                          )
                        ],
                      )),
                    if (widget.pesanan.status == 'siap_diantar' ||
                        widget.pesanan.driverId == null)
                      PrimaryButton(
                        key: Key('antarPesanan${widget.pesanan.id}'),
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
                            widget.userId,
                            widget.status == DeliveryStatus.siapDiantar
                                ? 'diantar'
                                : 'selesai',
                            widget.userToken,
                            widget.pesanan.id,
                            widget.status,
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
                            await deliveryProvider.fetchOrders(
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
                    if ((widget.pesanan.status == 'pesanan_masuk' &&
                                widget.pesanan.isPriority == 1 ||
                            widget.pesanan.status == 'pesanan_diproses' &&
                                widget.pesanan.isPriority == 1) &&
                        widget.pesanan.driverId != null &&
                        widget.pesanan.isPriority == 1)
                      PrimaryButton(
                        key: Key('ubahStatusPesanan${widget.pesanan.id}'),
                        isLoading: _isLoading, // Use local loading state
                        elevation: 0,
                        width: screenSize.width * 0.2,
                        height: screenSize.height * 0.065,
                        borderRadius: 20,
                        child: Text(
                          widget.pesanan.status == 'pesanan_masuk'
                              ? 'Pesanan Diproses'
                              : 'Ubah ke Antar',
                          style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        onLongPress: () {
                          setState(() {
                            _isLoading = true; // Set local loading state
                          });
                          try {
                            deliveryProvider.updateOrder(
                              widget.userId,
                              widget.pesanan.status == 'pesanan_masuk'
                                  ? 'pesanan_diproses'
                                  : 'diantar',
                              widget.userToken,
                              widget.pesanan.id,
                              widget.status,
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
                    if ((widget.status == DeliveryStatus.diantar &&
                        widget.pesanan.status == 'diantar'))
                      PrimaryButton(
                        key: Key('diantarPesanan${widget.pesanan.id}'),
                        isLoading: _isLoading, // Use local loading state
                        elevation: 0,
                        width: screenSize.width * 0.3,
                        height: screenSize.height * 0.065,
                        borderRadius: 20,
                        child: Text(
                          widget.status == DeliveryStatus.siapDiantar
                              ? 'Antar Pesanan'
                              : 'Selesai Diantar',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                                          widget.userId,
                                          'selesai',
                                          widget.userToken,
                                          widget.pesanan.id,
                                          widget.status,
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
                                        Fluttertoast.showToast(
                                            msg: e.toString());
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

  Widget _buildStatus(String status) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: getStatusColor(status)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(getIconByStatus(status),
                size: 16, color: getStatusColor(status)),
            Text(
              capitalizeFirstLetter(status.replaceAll('_', ' ')),
              style: GoogleFonts.poppins(
                color: getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostSection(Pesanan pesanan, int totalItemMenu, bool value) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.pesanan.multitenantId == null ||
              widget.lengthListPesanan == 1)
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
