import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/penjual/detail_riwayat_kasir_page.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class HistoryTransactionCashierItem extends StatefulWidget {
  final CashierTransaction transaction;
  final FlutterThermalPrinter printer;

  const HistoryTransactionCashierItem({
    super.key,
    required this.transaction,
    required this.printer,
  });

  @override
  State<HistoryTransactionCashierItem> createState() =>
      _HistoryTransactionCashierItemState();
}

class _HistoryTransactionCashierItemState
    extends State<HistoryTransactionCashierItem> {
  bool isLoading = false;
  bool isPrinting = false;

  @override
  Widget build(BuildContext context) {
    final transaction = widget.transaction;
    final printer = widget.printer;
    final cartMenuList = transaction.toCartMenuList();
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CustomPageBuilder(
                page: DetailRiwayatKasirPage(
                    transaction: transaction, printer: printer)));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor100,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          spacing: 8,
          children: [
            // ---------- Header ----------
            Row(
              spacing: 8,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: ImageByUrl(
                    url: transaction.listTransaksiDetail.isNotEmpty
                        ? transaction.listTransaksiDetail[0].menus?.tenants
                                ?.gambar ??
                            ''
                        : '',
                    height: 76,
                    width: 76,
                    fit: BoxFit.cover,
                  ),
                ),
                Flexible(
                  child: Column(
                    spacing: 4,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
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
                                  size: 16,
                                  color: getStatusColor(transaction.status),
                                ),
                                Text(
                                  getStatus(transaction.status),
                                  style: GoogleFonts.poppins(
                                    color: getStatusColor(transaction.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      Row(
                        spacing: 8,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              transaction.listTransaksiDetail.isNotEmpty
                                  ? transaction.listTransaksiDetail[0].menus
                                          ?.tenants?.namaTenant ??
                                      '-'
                                  : '-',
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            FormatDate.dateTimeToStringDate(
                                transaction.createdAt),
                            style: GoogleFonts.poppins(
                              color: AppColors.primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: transaction.listTransaksiDetail
                            .asMap()
                            .entries
                            .map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          final isLast = index ==
                              transaction.listTransaksiDetail.length - 1;
                          return Text(
                            "${item.menus?.nama}${isLast ? '' : ', '}",
                            style: GoogleFonts.poppins(
                              color: AppColors.blackColor,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            DashedDivider(height: 1, color: AppColors.blackColor100),

            // ---------- Action Buttons ----------
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.transaction.status == "pending")
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: CheckoutQris(
                            cashierTransaction: widget.transaction,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.infoColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Iconsax.receipt,
                              size: 16, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            'Bayar',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Tombol selesai (kalau status pesanan_diproses)
                if (transaction.status == "pesanan_diproses")
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

                      setState(() => isLoading = true);
                      try {
                        await kasirProvider.updateStatusCashierTransaction(
                          authProvider.user.token,
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
                    borderRadius: 12,
                    child: Text(
                      "Selesai",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                    ),
                  ),

                if (transaction.status == "selesai")

                  // Tombol Cetak
                  PrimaryButton(
                    width: MediaQuery.of(context).size.width / 3,
                    isLoading: isPrinting,
                    isEnabled: !isPrinting,
                    onPressed: () async {
                      final user =
                          Provider.of<AuthProvider>(context, listen: false)
                              .user;
                      final printerProvider =
                          Provider.of<PrinterProvider>(context, listen: false);

                      if (printerProvider.selectedPrinter == null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          CustomPageBuilder(
                            page: NavbarHome(
                              pageIndex: user.menu
                                  .indexWhere((m) => m.url == '/profile'),
                            ),
                          ),
                          (route) => false,
                        );
                        Fluttertoast.showToast(
                            msg:
                                'Silahkan Pilih Printer, tekan Mesin Cetak terlebih dahulu');
                        return;
                      }

                      setState(() => isPrinting = true);
                      try {
                        await printer.connect(printerProvider.selectedPrinter!);
                        final data = await generateReceiptCashier(
                          transaction,
                          printerProvider.selectedPrinter!,
                          context,
                        );

                        await printer.printData(
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
                        if (mounted) setState(() => isPrinting = false);
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
                    ),
                  ),
              ],
            ),
          ],
        ),
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
