import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class CashierTransactionItemWidget extends StatefulWidget {
  final CashierTransaction transaksi;
  final FlutterThermalPrinter printer;
  final bool withPadding;
  final Function()? onTerima;
  final Function()? onTolak;

  const CashierTransactionItemWidget({
    required this.printer,
    Key? key,
    required this.transaksi,
    this.onTerima,
    this.onTolak,
    this.withPadding = true,
  }) : super(key: key);

  @override
  State<CashierTransactionItemWidget> createState() =>
      _CashierTransactionItemWidgetState();
}

class _CashierTransactionItemWidgetState
    extends State<CashierTransactionItemWidget> {
  bool isLoading = false;
  bool _isPrinting = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.blackColor),
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: getStatusColor(widget.transaksi.status)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    spacing: 4,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      HugeIcon(
                          icon: getIconByStatus(widget.transaksi.status),
                          size: 16,
                          color: getStatusColor(widget.transaksi.status)),
                      Text(getStatus(widget.transaksi.status),
                          style: GoogleFonts.poppins(
                            color: getStatusColor(widget.transaksi.status),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                )),
          ),
          // Header transaksi
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              spacing: 4,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tanggal',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Text(
                      "No. Pesanan Kasir",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.blackColor,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${FormatDate.formatDateTimeWithWIB(widget.transaksi.createdAt)}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.blackColor,
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "KASIR-${widget.transaksi.orderTenant < 10 ? "00${widget.transaksi.orderTenant}" : widget.transaksi.orderTenant < 100 ? "0${widget.transaksi.orderTenant}" : widget.transaksi.orderTenant}",
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          DashedDivider(
            height: 1,
            color: AppColors.blackColor100,
          ),

          // List detail pesanan
          ...widget.transaksi.listTransaksiDetail.map(
            (pesanan) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _buildPesananItem(context, pesanan),
            ),
          ),

          DashedDivider(
            height: 1,
            color: AppColors.blackColor100,
          ),

          // Aksi tombol (opsional)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                Text("Total",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    )),
                Text(
                  "${FormatCurrency.intToStringCoin(widget.transaksi.total)}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
                )
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              spacing: 8,
              children: [
                // if (widget.transaksi.status != "pending")
                //   GestureDetector(
                //     onTap: () async {
                //       final cartProvider =
                //           Provider.of<CartProvider>(context, listen: false);
                //       final cartMenuList = widget.transaksi.toCartMenuList();
                //       final connectivityResult = await hasInternetAccess();
                //       if (!connectivityResult) {
                //         Fluttertoast.showToast(
                //           msg: 'Tidak ada koneksi internet',
                //         );
                //         showNoConnectionBottomSheet(
                //             context: context, onRetry: () {});
                //         return;
                //       }
                //       if (widget.transaksi.listTransaksiDetail[0].menus
                //               ?.tenants ==
                //           null) return;
                //       cartProvider.setCurrentTenant(
                //           widget
                //               .transaksi.listTransaksiDetail[0].menus!.tenants!,
                //           cartMenuList);

                //       Navigator.push(
                //         context,
                //         CustomPageBuilder(
                //           page: MenuTenant(
                //             url:
                //                 '${MasbroConstants.url}/tenants/${widget.transaksi.listTransaksiDetail[0].menus!.tenants!.id.toString()}',
                //             cart: cartMenuList,
                //             cashierTransactionId:
                //                 widget.transaksi.id.toString(),
                //           ),
                //         ),
                //       );
                //     },
                //     child: Container(
                //       padding:
                //           EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                //       decoration: BoxDecoration(
                //           borderRadius: BorderRadius.circular(16),
                //           color: AppColors.infoColor),
                //       child: Row(
                //         spacing: 8,
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(Iconsax.message_edit,
                //               size: 16, color: AppColors.whiteColor),
                //           Text("Edit",
                //               style: GoogleFonts.poppins(
                //                 fontSize: 12,
                //                 color: AppColors.whiteColor,
                //               )),
                //         ],
                //       ),
                //     ),
                //   ),
                if (widget.transaksi.status == "pending")
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: CheckoutQris(
                            cashierTransaction: widget.transaksi,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: AppColors.infoColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 8,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Iconsax.receipt,
                              size: 20, color: AppColors.whiteColor),
                          Text("Bayar",
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: AppColors.whiteColor,
                              )),
                        ],
                      ),
                    ),
                  ),
                if (widget.transaksi.status != "pending")
                  PrimaryButton(
                      width: MediaQuery.of(context).size.width / 3,
                      paddingVertical: 8,
                      isEnabled: !isLoading,
                      isLoading: isLoading,
                      onPressed: () async {
                        final kasirProvider =
                            Provider.of<KasirProvider>(context, listen: false);
                        final authProvider =
                            Provider.of<AuthProvider>(context, listen: false);
                        setState(() {
                          isLoading = true;
                        });
                        try {
                          await kasirProvider.updateStatusCashierTransaction(
                              authProvider.user.token,
                              "selesai",
                              widget.transaksi.id);
                          Fluttertoast.showToast(msg: "Selesai");
                        } catch (e) {
                          Fluttertoast.showToast(msg: "${e.toString()}");
                        } finally {
                          setState(() {
                            isLoading = false;
                          });
                        }
                      },
                      borderRadius: 12,
                      child: Text(
                        "Selesai",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          color: AppColors.whiteColor,
                        ),
                      ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
            child: PrimaryButton(
                isLoading: _isPrinting,
                isEnabled: !_isPrinting,
                onPressed: () async {
                  final user =
                      Provider.of<AuthProvider>(context, listen: false).user;
                  final printerProvider =
                      Provider.of<PrinterProvider>(context, listen: false);
                  if (printerProvider.selectedPrinter == null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CustomPageBuilder(
                        page: NavbarHome(
                          pageIndex: user.menu.indexWhere(
                              (element) => element.url == '/profile'),
                        ),
                      ),
                      (route) => false,
                    );
                    // showBottomSheetBluetoothDevices(context);
                    Fluttertoast.showToast(
                        msg: 'Silahkan Pilih Printer, tekan Mesin Cetak');
                    return;
                  }
                  setState(() {
                    _isPrinting = true;
                  });
                  try {
                    await widget.printer
                        .connect(printerProvider.selectedPrinter!);
                    final data = await generateReceiptCashier(widget.transaksi,
                        printerProvider.selectedPrinter!, context);

                    await widget.printer.printData(
                      printerProvider.selectedPrinter!,
                      data,
                      longData: true,
                    );
                    Fluttertoast.showToast(
                        msg: 'Cetak Berhasil',
                        backgroundColor: AppColors.successColor,
                        textColor: AppColors.whiteColor);
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                    print(e);
                  } finally {
                    setState(() {
                      _isPrinting = false;
                    });
                  }
                },
                color: AppColors.successColor,
                borderRadius: 16,
                child: Text(
                  "Cetak",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.whiteColor,
                  ),
                )),
          )
        ],
      ),
    );
  }

  Widget _buildPesananItem(BuildContext context, ListTransaksiDetail pesanan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ImageByUrl(
            key: Key('${pesanan.id}-${pesanan.namaMenu}'),
            url: pesanan.menus?.gambar ?? '',
            width: 64,
            height: 64,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              Text(
                capitalizeFirstLetter(pesanan.namaMenu),
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: AppColors.blackColor,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              Text(
                pesanan.catatan != null && pesanan.catatan!.isNotEmpty
                    ? pesanan.catatan!
                    : 'Catatan Kosong',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.blackColor200,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              GestureDetector(
                onTap: () => _showDetailPesanan(context, pesanan),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.warningColor,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.note_2,
                          size: 16, color: AppColors.whiteColor),
                      Text("Detail",
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.whiteColor,
                          ))
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4,
          children: [
            Text(
              FormatCurrency.intToStringCurrency(pesanan.harga),
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor,
              ),
              alignment: Alignment.center,
              child: Text(
                '${pesanan.jumlah}',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showDetailPesanan(
    BuildContext context,
    ListTransaksiDetail pesanan,
  ) {
    return showModalBottomSheet(
        backgroundColor: AppColors.whiteColor100,
        enableDrag: false,
        context: context,
        builder: (context) {
          return SafeArea(
            child: Stack(children: [
              Container(
                padding: EdgeInsets.all(24),
                height: MediaQuery.of(context).size.height / 2,
                child: Column(
                  spacing: 16,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            '${pesanan.namaMenu}',
                            softWrap: true,
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.blackColor),
                          ),
                        ),
                        Text(FormatCurrency.intToStringCurrency(pesanan.harga),
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: AppColors.blackColor))
                      ],
                    ),
                    DashedDivider(
                      height: 2,
                      color: AppColors.blackColor100,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 8,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: ImageByUrl(
                                    key: Key(
                                        '${pesanan.id}-${pesanan.menus!.gambar}-${pesanan.catatan}'),
                                    url: pesanan.menus!.gambar,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        capitalizeFirstLetter(
                                            pesanan.menus!.nama),
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      pesanan.catatan != '' &&
                                              pesanan.catatan != null
                                          ? Text(
                                              '${pesanan.catatan}',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColor200,
                                                  fontSize: 12),
                                            )
                                          : Text(
                                              'Catatan Kosong',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.blackColor200,
                                                  fontSize: 12),
                                            ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    child: Column(
                                  spacing: 8,
                                  children: [
                                    Text(
                                      FormatCurrency.intToStringCurrency(
                                          pesanan.harga),
                                      style: GoogleFonts.poppins(
                                        color: AppColors.blackColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      height: 36,
                                      width: 36,
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        color: AppColors.primaryColor,
                                      ),
                                      alignment: Alignment
                                          .center, // ini alternatif dari Center()
                                      child: Text(
                                        '${pesanan.jumlah}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ))
                              ],
                            ),
                            SizedBox(height: 60)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 12,
                left: 24,
                right: 24,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.warningColor,
                      borderRadius: BorderRadius.circular(100),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        )
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Keluar',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ]),
          );
        });
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
