import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/molecules/custom_snackbar.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';

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
                    CustomSnackbar.info(
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

                    CustomSnackbar.success(
                      'Cetak Berhasil',
                    );
                  } catch (e) {
                    CustomSnackbar.error(e.toString());
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
                  CustomSnackbar.success("Selesai");
                } catch (e) {
                  CustomSnackbar.error("Gagal");
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
                          StatusPesanan(status: transaction.status),
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
                            (pesanan) => PesananItemWidget(
                                withPadding: false,
                                isTenant: true,
                                pesanan: pesanan),
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
}
