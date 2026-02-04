import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
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
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class DetailRiwayatKasirPage extends StatefulWidget {
  final CashierTransaction transaction;
  final FlutterThermalPrinter printer;
  const DetailRiwayatKasirPage(
      {super.key, required this.transaction, required this.printer});

  @override
  State<DetailRiwayatKasirPage> createState() => _DetailRiwayatKasirPageState();
}

class _DetailRiwayatKasirPageState extends State<DetailRiwayatKasirPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Consumer<KasirProvider>(
      builder: (context, provider, child) {
        final transaction = provider.cashierTransactions
            .firstWhere((element) => element.id == widget.transaction.id);
        return Scaffold(
          floatingActionButton: SizedBox(
            width: MediaQuery.of(context).size.width - 48, // ini dia kuncinya!
            child: FloatingActionButton.extended(
              onPressed: () async {
                final user =
                    Provider.of<AuthProvider>(context, listen: false).user;
                if (transaction.status == "selesai") {
                  final printerProvider =
                      Provider.of<PrinterProvider>(context, listen: false);

                  if (printerProvider.selectedPrinter == null) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      CustomPageBuilder(
                        page: NavbarHome(
                          pageIndex:
                              user.menu.indexWhere((m) => m.url == '/profile'),
                        ),
                      ),
                      (route) => false,
                    );
                    Fluttertoast.showToast(
                        msg:
                            'Silahkan Pilih Printer, tekan Mesin Cetak terlebih dahulu');
                    return;
                  }

                  setState(() => isLoading = true);
                  try {
                    await widget.printer
                        .connect(printerProvider.selectedPrinter!);
                    final data = await generateReceiptCashier(
                      transaction,
                      printerProvider.selectedPrinter!,
                      context,
                    );

                    await widget.printer.printData(
                      printerProvider.selectedPrinter!,
                      data,
                      longData: true,
                    );

                    Fluttertoast.showToast(
                      msg: 'Cetak Berhasil',
                      backgroundColor: AppColors.successColor,
                      textColor: AppColors.whiteColor,
                    );
                  } catch (e) {
                    Fluttertoast.showToast(msg: e.toString());
                  } finally {
                    if (mounted) setState(() => isLoading = false);
                  }
                  return;
                }
                if (transaction.status == "pending") {
                  Navigator.push(
                    context,
                    CustomPageBuilder(
                      page: CheckoutQris(
                        cashierTransaction: widget.transaction,
                      ),
                    ),
                  );
                  return;
                }

                setState(() => isLoading = true);
                try {
                  await provider.updateStatusCashierTransaction(
                    user.token,
                    "selesai",
                    transaction.id,
                  );
                  Fluttertoast.showToast(msg: "Selesai");
                } catch (e) {
                  Fluttertoast.showToast(msg: "Gagal");
                } finally {
                  if (mounted) setState(() => isLoading = false);
                }
              },
              backgroundColor: isLoading
                  ? AppColors.containerColorGrey
                  : transaction.status == "selesai"
                      ? AppColors.successColor
                      : AppColors.primaryColor,
              label: Center(
                child: isLoading
                    ? CircularProgressIndicator(
                        color: AppColors.whiteColor,
                      )
                    : transaction.status == "selesai"
                        ? Text("Cetak",
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ))
                        : Text(
                            transaction.status == 'pending'
                                ? 'Bayar'
                                : 'Selesai',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
              ),
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
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
              "Detail Pesanan Kasir",
              style: GoogleFonts.poppins(
                color: AppColors.whiteColor900,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              spacing: 8,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    spacing: 16,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: getStatusColor(transaction.status)),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              spacing: 2,
                              children: [
                                Icon(
                                  getIconByStatus(transaction.status),
                                  size: 18,
                                  color: getStatusColor(transaction.status),
                                ),
                                Text(
                                  getStatus(transaction.status),
                                  style: GoogleFonts.poppins(
                                    color: getStatusColor(transaction.status),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // GestureDetector(
                          //   onTap: () async {
                          //     final hasConnection = await hasInternetAccess();
                          //     final cartProvider = Provider.of<CartProvider>(
                          //         context,
                          //         listen: false);
                          //     final cartMenuList = transaction.toCartMenuList();
                          //     if (!hasConnection) {
                          //       Fluttertoast.showToast(
                          //           msg: 'Tidak ada koneksi internet');
                          //       showNoConnectionBottomSheet(
                          //           context: context, onRetry: () {});
                          //       return;
                          //     }

                          //     if (transaction.listTransaksiDetail.isEmpty ||
                          //         transaction.listTransaksiDetail[0].menus
                          //                 ?.tenants ==
                          //             null) {
                          //       return;
                          //     }

                          //     cartProvider.setCurrentTenant(
                          //       transaction
                          //           .listTransaksiDetail[0].menus!.tenants!,
                          //       cartMenuList,
                          //     );

                          //     Navigator.push(
                          //       context,
                          //       CustomPageBuilder(
                          //         page: MenuTenant(
                          //           url:
                          //               '${MasbroConstants.url}/tenants/${transaction.listTransaksiDetail[0].menus!.tenants!.id}',
                          //           cart: cartMenuList,
                          //           cashierTransactionId:
                          //               transaction.id.toString(),
                          //         ),
                          //       ),
                          //     );
                          //   },
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //         horizontal: 16, vertical: 8),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.infoColor,
                          //       borderRadius: BorderRadius.circular(16),
                          //     ),
                          //     child: Row(
                          //       children: [
                          //         const Icon(Iconsax.message_edit,
                          //             size: 16, color: Colors.white),
                          //         const SizedBox(width: 4),
                          //         Text(
                          //           'Edit',
                          //           style: GoogleFonts.poppins(
                          //             color: Colors.white,
                          //             fontSize: 12,
                          //             fontWeight: FontWeight.w600,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tanggal",
                                style: GoogleFonts.poppins(
                                    color: AppColors.blackColor,
                                    fontWeight: FontWeight.w600),
                              ),
                              Text("No. Pesanan Kasir")
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${FormatDate.formatDateTimeWithWIB(transaction.createdAt)}',
                                style: GoogleFonts.poppins(
                                  color: AppColors.blackColor,
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  "KASIR-${transaction.orderTenant < 10 ? "00${transaction.orderTenant}" : transaction.orderTenant < 100 ? "0${transaction.orderTenant}" : transaction.orderTenant}",
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
                      DashedDivider(
                        color: AppColors.whiteColor600,
                        dashWidth: 16,
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pembeli',
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                            ),
                          ),
                          Text(
                            "${transaction.namaPembeli}",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ],
                      ),
                      DashedDivider(
                        color: AppColors.whiteColor600,
                        dashWidth: 16,
                        height: 2,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                          Text(
                              "${transaction.listTransaksiDetail[0].menus!.tenants!.namaTenant}",
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w600,
                              )),
                          ...transaction.listTransaksiDetail.map(
                            (pesanan) => _buildPesananItem(context, pesanan),
                          )
                        ],
                      ),
                      DashedDivider(
                        color: AppColors.whiteColor600,
                        dashWidth: 16,
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Sub Total: ${transaction.listTransaksiDetail.length} Menu",
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          Text(
                            FormatCurrency.intToStringCurrency(
                                transaction.total),
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                DashedDivider(
                  color: AppColors.whiteColor600,
                  dashWidth: 16,
                  height: 2,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Total",
                        style: GoogleFonts.poppins(
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        FormatCurrency.intToStringCurrency(transaction.total),
                        style: GoogleFonts.poppins(
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          )),
        );
      },
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
                        Text(
                          '${pesanan.namaMenu}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppColors.blackColor),
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
