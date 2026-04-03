import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class CetakPesananButton extends StatefulWidget {
  final FlutterThermalPrinter printer;
  final Pesanan pesanan;
  const CetakPesananButton(
      {super.key, required this.printer, required this.pesanan});

  @override
  State<CetakPesananButton> createState() => _CetakPesananButtonState();
}

class _CetakPesananButtonState extends State<CetakPesananButton> {
  bool _isPrinting = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
        child: GestureDetector(
          onTap: () async {
            final user = Provider.of<AuthProvider>(context, listen: false).user;
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
              // showBottomSheetBluetoothDevices(context);
              Fluttertoast.showToast(
                  msg: 'Silahkan Pilih Printer, tekan Mesin Cetak');
              return;
            }
            setState(() {
              _isPrinting = true;
            });
            try {
              await widget.printer.connect(printerProvider.selectedPrinter!);
              final data = await generateReceipt(
                  widget.pesanan, printerProvider.selectedPrinter!, context);

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
          child: Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.successColor,
              border: Border.all(color: AppColors.successColor, width: 2),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: _isPrinting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.whiteColor,
                      strokeWidth: 2,
                    ),
                  )
                : Text('Cetak',
                    style: GoogleFonts.poppins(
                        color: AppColors.whiteColor,
                        fontSize: 16,
                        fontWeight: semibold)),
          ),
        ));
  }
}
