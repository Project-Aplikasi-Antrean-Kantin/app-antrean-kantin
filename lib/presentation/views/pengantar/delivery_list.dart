import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card/delivery_card.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/delivery_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class DeliveryList extends StatefulWidget {
  final TabController? tabController;
  final DeliveryStatus status;
  final Future<void> Function() onRefresh;

  const DeliveryList({
    Key? key,
    required this.tabController,
    required this.status,
    required this.onRefresh,
  }) : super(key: key);

  @override
  State<DeliveryList> createState() => _DeliveryListState();
}

class _DeliveryListState extends State<DeliveryList> {
  String? deliveryImagePath;
  bool _isLoading = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final user = authProvider.user;
    final pesanan = deliveryProvider.getPesananByStatus(widget.status);

    // 🔹 Grup berdasarkan multitenantId
    final groupedPesanan = <int?, List<Pesanan>>{};
    for (final item in pesanan) {
      final key = item.multitenantId ?? -item.id; // buat unique key untuk null
      if (!groupedPesanan.containsKey(key)) {
        groupedPesanan[key] = [];
      }
      groupedPesanan[key]!.add(item);
    }

    // 🔹 Ubah ke list (biar bisa pakai ListView.builder)
    final groupedList = groupedPesanan.entries.toList();

    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: widget.onRefresh,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: groupedList.length,
        itemBuilder: (context, index) {
          final pesananList = groupedList[index].value;

          // 🔹 Kalau cuma 1 pesanan → tampilkan 1 card biasa
          if (pesananList.length == 1) {
            final pesananItem = pesananList.first;
            return DeliveryCard(
              key: ValueKey(
                  "order-${pesananItem.id}"), // ⬅ Paksa rebuild total saat data berubah
              showChatOnly: true,
              lengthListPesanan: pesananList.length,
              userId: user.id,
              index: 0,
              ongkir: pesananItem.ongkosKirim,
              onSuccess: () => widget.tabController?.animateTo(1),
              pesanan: pesananItem,
              status: widget.status,
              userToken: user.token,
            );
          }
          final ongkir = pesananList.fold<int>(
            0,
            (previousValue, element) => previousValue + element.ongkosKirim,
          );

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: AppColors.whiteColor100,
              border: Border.all(color: AppColors.blackColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              spacing: 8,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("No. Pesanan Multitenant",
                        style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        )),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blackColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text("MLT-${pesananList.first.multitenantId}",
                          style: GoogleFonts.poppins(
                            color: AppColors.whiteColor100,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                    )
                  ],
                ),
                DashedDivider(
                    height: 1.5, dashSpace: 12, color: AppColors.blackColor100),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Lokasi Pengantaran",
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          )),
                      Text("Tanggal",
                          style: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ))
                    ]),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                          child: Text(
                              '${pesananList.first.namaRuangan} ${pesananList.first.catatanLokasi != null && pesananList.first.catatanLokasi!.trim().isNotEmpty ? ' (${pesananList.first.catatanLokasi})' : ''}',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.blackColor))),
                      Expanded(
                          child: Text(
                              "${FormatDate.formatDateTimeWithWIB(pesananList.first.createdAt)}",
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: AppColors.blackColor))),
                    ]),
                DashedDivider(
                    height: 1.5, dashSpace: 12, color: AppColors.blackColor100),
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
                    Text('${pesananList.first.namaPembeli}',
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
                        'ORDER-${pesananList.first.id}',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor100,
                          fontSize: 10,
                          fontWeight: bold,
                        ),
                      ),
                    ),
                  ],
                ),
                ListView.builder(
                  itemCount: pesananList.length,
                  shrinkWrap: true, // biar muat di parent ListView utama
                  physics:
                      const NeverScrollableScrollPhysics(), // biar scroll-nya gak tabrakan
                  itemBuilder: (context, index) => DeliveryCard(
                    showChatOnly: DeliveryStatus.diantar == widget.status &&
                        pesananList.first.driverId != null,
                    lengthListPesanan: pesananList.length,
                    userId: user.id,
                    index: index + 1,
                    ongkir: ongkir,
                    onSuccess: () => widget.tabController?.animateTo(1),
                    pesanan: pesananList[index],
                    status: widget.status,
                    userToken: user.token,
                  ),
                ),
                Column(
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Biaya Pengantaran",
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                          Text(
                            FormatCurrency.intToStringCoin(ongkir),
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ]),
                    if (pesananList.first.isPriority != 1 &&
                        widget.status != DeliveryStatus.diantar)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          PrimaryButton(
                            onPressed: () async {
                              if (widget.status == DeliveryStatus.diantar) {
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
                                                  msg:
                                                      'Foto tidak boleh kosong');
                                              return;
                                            }

                                            setModalState(() {
                                              _isLoading = true;
                                            });
                                            try {
                                              final result =
                                                  await deliveryProvider
                                                      .updateOrder(
                                                user.id,
                                                'selesai',
                                                user.token,
                                                pesananList.first.id,
                                                widget.status,
                                                pesananList.first,
                                                buktiPath: deliveryImagePath,
                                              );

                                              if (result.success) {
                                                Fluttertoast.showToast(
                                                  msg: 'Pesanan selesai 🎉',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
                                                  gravity: ToastGravity.BOTTOM,
                                                  backgroundColor:
                                                      AppColors.successColor,
                                                  textColor: Colors.white,
                                                  fontSize: 16.0,
                                                );
                                              } else {
                                                Fluttertoast.showToast(
                                                  msg: result.error ??
                                                      'ORDER-${pesananList.first.id} telah diantar oleh driver lain',
                                                  toastLength:
                                                      Toast.LENGTH_SHORT,
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
                                return;
                              }
                              final result = await deliveryProvider.updateOrder(
                                user.id,
                                widget.status == DeliveryStatus.siapDiantar
                                    ? 'diantar'
                                    : 'selesai',
                                user.token,
                                pesananList.first.id,
                                widget.status,
                                pesananList.first,
                              );
                              if (pesananList.first.status == 'siap_diantar') {
                                Fluttertoast.showToast(
                                  msg: result.success
                                      ? widget.status ==
                                              DeliveryStatus.siapDiantar
                                          ? 'Segera antar pesanan!'
                                          : 'Pesanan selesai 🎉'
                                      : result.error ??
                                          'ORDER-${pesananList.first.id} telah diantar oleh driver lain',
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
                                          'ORDER-${pesananList.first.id} telah diantar oleh driver lain',
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.BOTTOM,
                                  backgroundColor:
                                      result.success ? Colors.grey : Colors.red,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }
                              // if (result.error != null) {
                              //   await deliveryProvider.fetchOrders(
                              //       user.token, widget.status);
                              // }

                              if (result.success &&
                                  pesananList.first.status == 'siap_diantar')
                                widget.tabController?.animateTo(1);
                            },
                            child: Text(
                                widget.status == DeliveryStatus.siapDiantar
                                    ? 'Antar Pesanan'
                                    : 'Selesai',
                                style: GoogleFonts.poppins(
                                  color: AppColors.whiteColor100,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                )),
                            width: 120,
                            borderRadius: 12,
                            height: 32,
                          ),
                        ],
                      )
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
