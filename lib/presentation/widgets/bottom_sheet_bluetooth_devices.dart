import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';

Future<void> showBottomSheetBluetoothDevices(
  BuildContext context,
  FlutterThermalPrinter _flutterThermalPrinterPlugin,
  Pesanan pesanan,
) async {
  await showModalBottomSheet<void>(
    backgroundColor: AppColors.backgroundColor,
    enableDrag: true,
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return StatefulBuilder(
        builder: (context, setState) {
          // ambil provider
          final printerProvider = Provider.of<PrinterProvider>(context);

          // local state untuk tampilkan selected radio
          var localSelectedPrinter = printerProvider.selectedPrinter;

          // void onSelectPrinter(Printer printer) {
          //   setState(() {
          //     localSelectedPrinter = printer;
          //   });
          //   printerProvider.selectPrinter(printer);
          // }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Pilih Perangkat',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List Printer
                    Expanded(
                      child: ListView.builder(
                        itemCount: printerProvider.printer.length,
                        itemBuilder: (context, index) {
                          final printer = printerProvider.printer[index];
                          return Row(
                            children: [
                              Radio<String>(
                                activeColor: AppColors.primaryColor,
                                value: printer.name!, // atau printer.address!
                                groupValue:
                                    printerProvider.selectedPrinter?.name,
                                onChanged: (value) {
                                  final selected = printerProvider.printer
                                      .firstWhere((p) => p.name == value);
                                  printerProvider.selectPrinter(selected);
                                  // setState(() {}); // supaya update UI
                                },
                              ),
                              Text(printer.name!),
                            ],
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Tombol Cetak
                    ElevatedButton(
                      onPressed: localSelectedPrinter == null
                          ? null
                          : () async {
                              printerProvider.setPrinting(true);
                              try {
                                await _flutterThermalPrinterPlugin
                                    .connect(localSelectedPrinter);
                                final data = await _generateReceipt(pesanan);

                                await _flutterThermalPrinterPlugin.printData(
                                  localSelectedPrinter,
                                  data,
                                  longData: true,
                                );
                              } catch (e) {
                                Fluttertoast.showToast(msg: e.toString());
                              } finally {
                                printerProvider.setPrinting(false);
                              }
                              Navigator.pop(context);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: printerProvider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Cetak',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}

Future<List<int>> _generateReceipt(Pesanan pesanan) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);
  List<int> bytes = [];

  bytes += generator.text(
    '${pesanan.listTransaksiDetail[0].menus!.tenants!.namaTenant}',
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size2,
      width: PosTextSize.size2,
    ),
  );
  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(text: 'Tanggal', width: 3, styles: const PosStyles(bold: true)),
    PosColumn(
        text: '${FormatDate.formatDateTimeWithWIB(pesanan.createdAt)}',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'No. Pesanan', width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
        text: 'ORDER-${pesanan.id}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Kode Pemesanan', width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
        text: '${pesanan.kodePemesanan}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.row([
    PosColumn(text: 'Pembeli', width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
        text: '${pesanan.namaPembeli}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.row([
    PosColumn(
        text: 'Pengambilan', width: 6, styles: const PosStyles(bold: true)),
    PosColumn(
        text: '${pesanan.isAntar == 1 ? 'Diantar' : 'Ambil Sendiri'}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);

  bytes += generator.hr();
  for (var i = 0; i < pesanan.listTransaksiDetail.length; i++) {
    final menu = pesanan.listTransaksiDetail[i].menus!;
    final catatan = pesanan.listTransaksiDetail[i].catatan ?? '';

    // Baris utama: nama + harga
    bytes += generator.row([
      PosColumn(text: menu.nama, width: 9),
      PosColumn(
        text: '${pesanan.listTransaksiDetail[i].harga}',
        width: 3,
        styles: const PosStyles(align: PosAlign.right),
      ),
    ]);

    // Baris tambahan: catatan (jika ada)
    if (catatan.isNotEmpty) {
      bytes += generator.text(
        'Catatan: $catatan',
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }
  }

  bytes += generator.hr();
  bytes += generator.row([
    PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true)),
    PosColumn(
        text: '${pesanan.subTotal}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true)),
  ]);
  bytes += generator.feed(1);
  bytes += generator.text(
    'Thank you!',
    styles: const PosStyles(align: PosAlign.center),
  );
  bytes += generator.cut();
  return bytes;
}
