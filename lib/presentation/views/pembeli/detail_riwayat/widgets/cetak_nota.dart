import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class CetakNota extends StatefulWidget {
  final Pesanan pesanan;
  final FlutterThermalPrinter flutterThermalPrinter;
  const CetakNota(
      {super.key, required this.pesanan, required this.flutterThermalPrinter});

  @override
  State<CetakNota> createState() => _CetakNotaState();
}

class _CetakNotaState extends State<CetakNota> {
  bool _isPrinting = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Cetak Nota Pesanan"),
          GestureDetector(
            onTap: () async {
              final user =
                  Provider.of<AuthProvider>(context, listen: false).user;
              final printerProvider =
                  Provider.of<PrinterProvider>(context, listen: false);
              if (printerProvider.selectedPrinter == null) {
                Navigator.pushAndRemoveUntil(
                  context,
                  CustomPageBuilder(
                    page: NavbarHome(
                      pageIndex: user.menu
                          .indexWhere((element) => element.url == '/profile'),
                    ),
                  ),
                  (route) => false,
                );

                Fluttertoast.showToast(
                    msg: 'Silahkan Pilih Printer, tekan Mesin Cetak');
                return;
              }
              setState(() {
                _isPrinting = true;
              });

              try {
                await widget.flutterThermalPrinter
                    .connect(printerProvider.selectedPrinter!);
                final data = await generateReceipt(
                    widget.pesanan, printerProvider.selectedPrinter!, context);

                await widget.flutterThermalPrinter.printData(
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
              } finally {
                setState(() {
                  _isPrinting = false;
                });
              }
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.successColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: _isPrinting
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Row(
                      spacing: 8,
                      children: [
                        HugeIcon(
                            icon: HugeIcons.strokeRoundedInvoice04,
                            size: 16,
                            color: AppColors.whiteColor100),
                        Text("Cetak",
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                                color: AppColors.whiteColor100,
                                fontSize: 12))
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
