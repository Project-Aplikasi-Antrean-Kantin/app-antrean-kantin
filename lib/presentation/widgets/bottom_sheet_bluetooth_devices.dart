import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/services.dart' show rootBundle;

import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';

Future<void> showBottomSheetBluetoothDevices(
  BuildContext context,
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
                                  Fluttertoast.showToast(
                                      msg: '${selected.name} terpilih',
                                      textColor: AppColors.whiteColor,
                                      backgroundColor: AppColors.successColor);
                                  Navigator.pop(context);
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
                    // ElevatedButton(
                    //   onPressed: localSelectedPrinter == null
                    //       ? null
                    //       : () async {
                    //           printerProvider.setPrinting(true);
                    //           try {
                    //             await _flutterThermalPrinterPlugin
                    //                 .connect(localSelectedPrinter);
                    //             final data = await _generateReceipt(pesanan);

                    //             await _flutterThermalPrinterPlugin.printData(
                    //               localSelectedPrinter,
                    //               data,
                    //               longData: true,
                    //             );
                    //           } catch (e) {
                    //             Fluttertoast.showToast(msg: e.toString());
                    //           } finally {
                    //             printerProvider.setPrinting(false);
                    //           }
                    //           Navigator.pop(context);
                    //         },
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: AppColors.primaryColor,
                    //     padding: const EdgeInsets.symmetric(vertical: 14),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(8),
                    //     ),
                    //   ),
                    //   child: printerProvider.isLoading
                    //       ? const SizedBox(
                    //           height: 20,
                    //           width: 20,
                    //           child: CircularProgressIndicator(
                    //             color: Colors.white,
                    //             strokeWidth: 2,
                    //           ),
                    //         )
                    //       : const Text(
                    //           'Cetak',
                    //           style:
                    //               TextStyle(fontSize: 16, color: Colors.white),
                    //         ),
                    // ),
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

Future<Uint8List> loadLogo() async {
  final ByteData data = await rootBundle.load('assets/images/Logo Header.png');
  final Uint8List bytesImage = data.buffer.asUint8List();
  final img.Image image = img.decodeImage(bytesImage)!;
  final img.Image resized = img.copyResize(image, width: 384);
  return Uint8List.fromList(img.encodePng(resized));
}

Future<List<int>> generateReceipt(
    Pesanan pesanan, Printer selectedPrinter, BuildContext context) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);

  List<int> bytes = [];

  // ==== 1. Cetak logo ====
  try {
    ByteData imageByteData =
        await rootBundle.load("assets/images/logo_print.png");
    Uint8List imageBytesUint8List = imageByteData.buffer.asUint8List();
    img.Image image = img.decodeImage(imageBytesUint8List)!;
    bytes += generator.image(image);

// With hide
  } catch (e) {
    print('Gagal memuat logo: $e');
  }

  // ==== 2. Header ====
  bytes = [
    ...bytes,
    ...generator.text(
      pesanan.kodePemesanan ?? '',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
    ),
    ...generator.text(
      pesanan.namaPembeli!.substring(
              0,
              pesanan.namaPembeli!.length > 30
                  ? 30
                  : pesanan.namaPembeli!.length) ??
          '',
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true, height: PosTextSize.size2, // tinggi 2x
        width: PosTextSize.size1, // lebar normal
      ),
    ),
    ...generator.hr(),
  ];

  // ==== 3. Info Umum ====
  bytes = [
    ...bytes,
    ...generator.row([
      PosColumn(
          text: 'Tanggal', width: 3, styles: const PosStyles(bold: false)),
      PosColumn(
        text: FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
        width: 9,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.row([
      PosColumn(text: 'Tenant', width: 3, styles: const PosStyles(bold: false)),
      PosColumn(
        text: '${pesanan.listTransaksiDetail.first.menus!.tenants!.namaTenant}',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.row([
      PosColumn(
          text: 'No. Pesanan', width: 6, styles: const PosStyles(bold: false)),
      PosColumn(
        text: 'ORDER-${pesanan.id}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.row([
      PosColumn(
          text: 'Pengambilan', width: 6, styles: const PosStyles(bold: false)),
      PosColumn(
        text: pesanan.isAntar == 1 ? 'Diantar' : 'Ambil Sendiri',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.hr(),
  ];

  bytes += generator.text(
    'Pesanan',
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ),
  );

  // ==== 4. Detail Pesanan ====
  for (var i = 0; i < pesanan.listTransaksiDetail.length; i++) {
    final detail = pesanan.listTransaksiDetail[i];
    final menu = detail.menus!;
    final catatan = detail.catatan ?? '-';

    bytes = [
      ...bytes,
      ...generator.row([
        PosColumn(text: '${detail.jumlah}x ${menu.nama}', width: 9),
        PosColumn(
          text: '${detail.harga}',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    ];

    if (catatan.isNotEmpty) {
      bytes = [
        ...bytes,
        ...generator.row([
          PosColumn(text: 'Catatan:', width: 4),
          PosColumn(
            text: '${catatan}',
            width: 8,
            styles: const PosStyles(align: PosAlign.right),
          )
        ]),
      ];
    }
  }

  // ==== 5. Total ====
  bytes = [
    ...bytes,
    ...generator.hr(),
    ...generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: '${pesanan.subTotal}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]),
    if (pesanan.cashbackAmount != null && pesanan.cashbackAmount! > 0)
      ...generator.row([
        PosColumn(
          text: 'Cashback',
          width: 6,
          styles: const PosStyles(align: PosAlign.left, bold: true),
        ),
        PosColumn(
          text: '${pesanan.cashbackAmount}',
          width: 6,
          styles: const PosStyles(align: PosAlign.right, bold: true),
        ),
      ]),
    ...generator.feed(1),
    ...generator.text(
      'Selamat Menikmati',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ),
    ...generator.text(
      'Terima kasih!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ),
    ...generator.cut(),
  ];

  return bytes;
}

Future<List<int>> generateReceiptCashier(CashierTransaction transaksi,
    Printer selectedPrinter, BuildContext context) async {
  final profile = await CapabilityProfile.load();
  final generator = Generator(PaperSize.mm58, profile);

  List<int> bytes = [];

  // ==== 1. Cetak logo ====
  try {
    ByteData imageByteData =
        await rootBundle.load("assets/images/logo_print.png");
    Uint8List imageBytesUint8List = imageByteData.buffer.asUint8List();
    img.Image image = img.decodeImage(imageBytesUint8List)!;
    bytes += generator.image(image);

// With hide
  } catch (e) {
    print('Gagal memuat logo: $e');
  }

  // ==== 2. Header ====
  bytes = [
    ...bytes,
    ...generator.text(
      transaksi.kodePemesanan,
      styles: const PosStyles(
        align: PosAlign.center,
        bold: true,
        height: PosTextSize.size3,
        width: PosTextSize.size3,
      ),
    ),
    ...generator.hr(),
  ];

  // ==== 3. Info Umum ====
  bytes = [
    ...bytes,
    ...generator.row([
      PosColumn(
          text: 'Tanggal', width: 3, styles: const PosStyles(bold: false)),
      PosColumn(
        text: FormatDate.formatDateTimeWithWIB(transaksi.createdAt),
        width: 9,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.row([
      PosColumn(text: 'Tenant', width: 3, styles: const PosStyles(bold: false)),
      PosColumn(
        text:
            '${transaksi.listTransaksiDetail.first.menus!.tenants!.namaTenant}',
        width: 9,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.row([
      PosColumn(
          text: 'No. Pesanan', width: 6, styles: const PosStyles(bold: false)),
      PosColumn(
        text: 'KASIR-${transaksi.orderTenant}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: false),
      ),
    ]),
    ...generator.hr(),
  ];

  bytes += generator.text(
    'Pesanan',
    styles: const PosStyles(
      align: PosAlign.center,
      bold: true,
      height: PosTextSize.size1,
      width: PosTextSize.size1,
    ),
  );

  // ==== 4. Detail Pesanan ====
  for (var i = 0; i < transaksi.listTransaksiDetail.length; i++) {
    final detail = transaksi.listTransaksiDetail[i];
    final menu = detail.menus!;
    final catatan = detail.catatan ?? '-';

    bytes = [
      ...bytes,
      ...generator.row([
        PosColumn(text: '${detail.jumlah}x ${menu.nama}', width: 9),
        PosColumn(
          text: '${detail.harga}',
          width: 3,
          styles: const PosStyles(align: PosAlign.right),
        ),
      ]),
    ];

    if (catatan.isNotEmpty) {
      bytes = [
        ...bytes,
        ...generator.row([
          PosColumn(text: 'Catatan:', width: 4),
          PosColumn(
            text: '${catatan}',
            width: 8,
            styles: const PosStyles(align: PosAlign.right),
          )
        ]),
      ];
    }
  }

  // ==== 5. Total ====
  bytes = [
    ...bytes,
    ...generator.hr(),
    ...generator.row([
      PosColumn(
        text: 'Total',
        width: 6,
        styles: const PosStyles(align: PosAlign.left, bold: true),
      ),
      PosColumn(
        text: '${transaksi.total}',
        width: 6,
        styles: const PosStyles(align: PosAlign.right, bold: true),
      ),
    ]),
    ...generator.feed(1),
    ...generator.text(
      'Selamat Menikmati',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ),
    ...generator.text(
      'Terima kasih!',
      styles: const PosStyles(align: PosAlign.center, bold: true),
    ),
    ...generator.cut(),
  ];

  return bytes;
}
