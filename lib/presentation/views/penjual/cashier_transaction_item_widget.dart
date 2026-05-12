import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
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
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/presentation/widgets/molecules/status_pesanan.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class CashierTransactionItemWidget extends StatefulWidget {
  final CashierTransaction transaksi;
  final FlutterThermalPrinter printer;
  final bool withPadding;

  const CashierTransactionItemWidget({
    required this.printer,
    Key? key,
    required this.transaksi,
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
                  child: StatusPesanan(status: widget.transaksi.status),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pembeli',
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                  ),
                ),
                Text(
                  "${widget.transaksi.namaPembeli}",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: AppColors.blackColor,
                  ),
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
              child: PesananItemWidget(isTenant: true, pesanan: pesanan),
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
}
