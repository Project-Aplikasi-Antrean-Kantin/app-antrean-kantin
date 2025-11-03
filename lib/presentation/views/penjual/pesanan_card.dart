import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class PesananCard extends StatefulWidget {
  final Pesanan pesanan;
  final OrderStatus status;
  final String token;
  final List<Pesanan> listPesanan;
  final FlutterThermalPrinter printer;

  const PesananCard({
    Key? key,
    required this.pesanan,
    required this.status,
    required this.token,
    required this.listPesanan,
    required this.printer,
  }) : super(key: key);

  @override
  PesananCardState createState() => PesananCardState();
}

class PesananCardState extends State<PesananCard> {
  bool _isLoading = false;
  bool _isPrinting = false;
  final textEditingController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: AppColors.blackColor300,
        ),
      ),
      child: Column(
        spacing: 16,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: widget.pesanan.isPriority == 1
                              ? AppColors.primaryColor
                              : Colors.grey),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 4,
                      children: [
                        if (widget.pesanan.isPriority == 1)
                          Icon(Iconsax.flash_1,
                              size: 16, color: AppColors.primaryColor),
                        Text(
                          widget.pesanan.isPriority == 1
                              ? "Express"
                              : "Reguler",
                          style: GoogleFonts.poppins(
                            color: widget.pesanan.isPriority == 1
                                ? AppColors.primaryColor
                                : AppColors.whiteColor800,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _buildStatus(
                  widget.pesanan.status,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Text('Kode Pemesanan',
                        style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: semibold,
                            color: AppColors.blackColor))),
                Expanded(
                    child: Text(
                  '${widget.pesanan.kodePemesanan}',
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: semibold,
                    color: AppColors.primaryColor,
                  ),
                ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: _buildHeader(),
          ),

          DashedDivider(height: 2, color: AppColors.blackColor100),

          // Rincian Pesanan Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Detail Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: semibold,
              ),
            ),
          ),

          // List Menu Items
          ...widget.pesanan.listTransaksiDetail.map((item) {
            return PesananItemWidget(
              pesanan: item,
              tolakPesanan: () {},
              terimaPesanan: () {},
            );
          }).toList(),
          DashedDivider(color: AppColors.blackColor100, height: 2),

          // Summary Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _buildSummary(),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.only(
                bottom: widget.pesanan.status != 'pesanan_masuk' ? 0 : 16,
                left: 16,
                right: 16),
            child: _buildActionButton(context, widget.pesanan),
          ),
          if (widget.pesanan.status != 'pesanan_masuk')
            Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: GestureDetector(
                  onTap: () async {
                    final user =
                        Provider.of<AuthProvider>(context, listen: false).user;
                    final printerProvider =
                        Provider.of<PrinterProvider>(context, listen: false);
                    if (printerProvider.selectedPrinter == null) {
                      print(user.menu.map((element) => element.url).toList());
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
                      final data = await generateReceipt(widget.pesanan,
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
                  child: Container(
                    alignment: Alignment.center,
                    width: double.infinity,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.successColor,
                      border:
                          Border.all(color: AppColors.successColor, width: 2),
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
                )),
        ],
      ),
    );
  }

  Widget _buildStatus(String status) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: getStatusColor(status)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 4,
          children: [
            Icon(getIconByStatus(status),
                size: 16, color: getStatusColor(status)),
            Text(
              capitalizeFirstLetter(status.replaceAll('_', ' ')),
              style: GoogleFonts.poppins(
                color: getStatusColor(status),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Text(
              '${widget.pesanan.namaPembeli}',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'ORDER-${widget.pesanan.id}',
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor100,
                  fontSize: 10,
                  fontWeight: bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummary() {
    final totalItemMenu = widget.pesanan.listTransaksiDetail
        .map((item) => item.jumlah)
        .fold(0, (prev, jumlah) => prev + jumlah);
    return Column(
      spacing: 10,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(
                  widget.pesanan.total - widget.pesanan.ongkosKirim),
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future bottomSheetCatatan(BuildContext context, Pesanan pesanan) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return showModalBottomSheet(
      backgroundColor: AppColors.backgroundColor,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(15),
        ),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              // padding: const EdgeInsets.all(20),
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 18,
                left: 18,
                right: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    height: 5,
                    margin: const EdgeInsets.only(
                      bottom: 20,
                      left: 150,
                      right: 150,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Center(
                    child: Text(
                      'Tolak Pesanan',
                      style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.errorColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border:
                          Border.all(color: AppColors.blackColor100, width: 2),
                    ),
                    height: 124,
                    child: TextField(
                      controller: textEditingController,
                      decoration: const InputDecoration(
                        hintText: 'Masukkan catatan...',
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 3,
                          vertical: 8,
                        ),
                        border: InputBorder.none,
                      ),
                      expands: true,
                      maxLines: null,
                      minLines: null,
                      maxLength: 200,
                    ),
                  ),
                  SizedBox(height: 40),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     // Lakukan sesuatu dengan catatan yang dimasukkan
                  //     String catatan = _textEditingController.text;
                  //     print('Catatan: $catatan');
                  //     // Tutup BottomSheet
                  //     Navigator.pop(context, catatan);
                  //   },
                  //   child: Text(
                  //     'Konfirmasi',
                  //     style: TextStyle(
                  //       fontSize: 14,
                  //       fontWeight: semibold,
                  //       color: AppColors.textColorBlack,
                  //     ),
                  //   ),
                  // ),
                  PrimaryButton(
                      isLoading: _isLoading,
                      borderRadius: 16,
                      height: 48,
                      color: AppColors.errorColor,
                      child: Text(
                        'Kirim',
                        style: GoogleFonts.poppins(
                            color: AppColors.whiteColor100,
                            fontWeight: FontWeight.w500,
                            fontSize: 16),
                      ),
                      onPressed: () async {
                        if (textEditingController.text.isEmpty) {
                          Fluttertoast.showToast(
                              msg: 'Catatan tidak boleh kosong');
                          return;
                        }
                        setState(() {
                          _isLoading = true;
                        });
                        final success = await orderProvider.cancelOrder(
                            widget.token,
                            pesanan.id,
                            pesanan,
                            textEditingController.text);

                        if (success) {
                          widget.listPesanan.remove(pesanan);
                          Navigator.pop(context);
                          Fluttertoast.showToast(
                            msg: "Pesanan telah ditolak",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          await orderProvider.fetchOrders(
                              context, widget.token, widget.status);
                          Fluttertoast.showToast(
                            msg:
                                "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        if (mounted) {
                          // Check if the widget is still mounted
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      })
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context, Pesanan pesanan) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final screenSize = MediaQuery.of(context).size;
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    final isThereNewChat =
        historyProvider.unreadMessagesList.contains(pesanan.id);

    switch (widget.status) {
      case OrderStatus.pesananMasuk:
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: PrimaryButton(
                isEnabled: !_isLoading,
                elevation: 0,
                color: AppColors.errorColor100,
                borderRadius: 12,
                child: Text(
                  'Tolak',
                  style: GoogleFonts.poppins(
                    color: !_isLoading
                        ? AppColors.errorColor
                        : AppColors.containerColorGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  bottomSheetCatatan(context, pesanan);
                },
              ),
            ),
            SizedBox(width: screenSize.width * 0.03),
            Expanded(
              child: PrimaryButton(
                isLoading: _isLoading,
                elevation: 0,
                borderRadius: 12,
                child: Text(
                  'Terima',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final success = await orderProvider.updateOrder(
                      'pesanan_diproses', widget.token, pesanan.id, pesanan);

                  if (success) {
                    Fluttertoast.showToast(
                      msg: "Segera proses pesanan!",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    await orderProvider.fetchOrders(
                        context, widget.token, widget.status);
                    Fluttertoast.showToast(
                      msg:
                          "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  if (mounted) {
                    // Check if the widget is still mounted
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
          ],
        );
      case OrderStatus.pesananDiproses:
        return Row(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
                child: Row(
              spacing: 8,
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.errorColor100,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  onPressed: () => bottomSheetCatatan(context, pesanan),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.errorColor,
                  ),
                ),
                if (pesanan.driverId == null)
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        style: OutlinedButton.styleFrom(
                          shape:
                              const CircleBorder(), // ✅ ini yang bikin benar-benar bundar
                          backgroundColor: AppColors.primaryColor100,
                          padding: const EdgeInsets.all(
                              12), // jarak icon dengan border
                        ),
                        onPressed: () async {
                          final connectivityResult = await hasInternetAccess();
                          if (!connectivityResult) {
                            Fluttertoast.showToast(
                                msg: 'Tidak ada koneksi internet');
                            showNoConnectionBottomSheet(
                                context: context, onRetry: () {});
                            return;
                          }
                          historyProvider
                              .removeUnreadMessages(widget.pesanan.id);

                          Navigator.push(
                            context,
                            CustomPageBuilder(
                              page: ChatPage(
                                pesanan: widget.pesanan,
                                chatType: "tenant",
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Iconsax.message,
                          size: 24,
                          color: AppColors.primaryColor,
                        ),
                      ),

                      // bulatan indikator
                      if (isThereNewChat)
                        Positioned(
                          right: 8,
                          top: 4,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            )),
            Expanded(
              child: PrimaryButton(
                isLoading: _isLoading,
                elevation: 0,
                borderRadius: 12,
                color: AppColors.primaryColor,
                child: Text(
                  'Pesanan Siap',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () async {
                  setState(() {
                    _isLoading = true;
                  });
                  final status =
                      pesanan.isAntar == 1 ? 'siap_diantar' : 'siap_diambil';
                  final success = await orderProvider.updateOrder(
                      status, widget.token, pesanan.id, pesanan);

                  if (success) {
                    widget.listPesanan.remove(pesanan);
                    Fluttertoast.showToast(
                      msg: "Pesanan Siap",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.grey,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  } else {
                    await orderProvider.fetchOrders(
                        context, widget.token, widget.status);
                    Fluttertoast.showToast(
                      msg:
                          "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                  if (mounted) {
                    // Check if the widget is still mounted
                    setState(() {
                      _isLoading = false;
                    });
                  }
                },
              ),
            ),
          ],
        );

      case OrderStatus.pesananSiapDiambil:
        return pesanan.isAntar != 1
            ? Row(
                spacing: 8,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        PrimaryButton(
                          borderRadius: 12,
                          elevation: 0,
                          color: AppColors.primaryColor100,
                          onPressed: () async {
                            final connectivityResult =
                                await hasInternetAccess();
                            if (!connectivityResult) {
                              Fluttertoast.showToast(
                                msg: 'Tidak ada koneksi internet',
                              );
                              showNoConnectionBottomSheet(
                                  context: context, onRetry: () {});
                              return;
                            }
                            historyProvider
                                .removeUnreadMessages(widget.pesanan.id);

                            Navigator.push(
                              context,
                              CustomPageBuilder(
                                page: ChatPage(
                                  pesanan: widget.pesanan,
                                  chatType: "tenant",
                                ),
                              ),
                            );
                          },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            spacing: 4,
                            children: [
                              Text(
                                'Chat Pembeli',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                  fontWeight: semibold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // bulatan indikator
                        if (isThereNewChat)
                          Positioned(
                            right: 4,
                            top: -2,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PrimaryButton(
                      isLoading: _isLoading,
                      elevation: 0,
                      borderRadius: 12,
                      color: AppColors.primaryColor,
                      child: Text(
                        'Selesai',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      onPressed: () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final status = 'selesai';
                        final success = await orderProvider.updateOrder(
                            status, widget.token, pesanan.id, pesanan);
                        historyProvider.removeUnreadMessages(pesanan.id);

                        if (success) {
                          widget.listPesanan.remove(pesanan);

                          Fluttertoast.showToast(
                            msg: "Pesanan Selesai",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.grey,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        } else {
                          await orderProvider.fetchOrders(
                              context, widget.token, widget.status);
                          Fluttertoast.showToast(
                            msg:
                                "Gagal memperbarui pesanan, ${orderProvider.errorUpdate ?? 'terjadi kesalahan'}",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.TOP,
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            fontSize: 16.0,
                          );
                        }
                        if (mounted) {
                          // Check if the widget is still mounted
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                ],
              )
            : pesanan.status == 'siap_diantar' && pesanan.driverId == null
                ? Stack(
                    clipBehavior: Clip.none,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: Size(screenSize.width * 0.385,
                              screenSize.height * 0.075),
                          side: BorderSide(
                              color: AppColors.primaryColor), // border warna
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        onPressed: () async {
                          final connectivityResult = await hasInternetAccess();
                          if (!connectivityResult) {
                            Fluttertoast.showToast(
                              msg: 'Tidak ada koneksi internet',
                            );
                            showNoConnectionBottomSheet(
                                context: context, onRetry: () {});
                            return;
                          }
                          historyProvider
                              .removeUnreadMessages(widget.pesanan.id);

                          Navigator.push(
                            context,
                            CustomPageBuilder(
                              page: ChatPage(
                                pesanan: widget.pesanan,
                                chatType: "tenant",
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Chat Pembeli',
                          style: GoogleFonts.poppins(
                            color: AppColors.primaryColor,
                            fontSize: 14,
                            fontWeight: semibold,
                          ),
                        ),
                      ),

                      // bulatan indikator
                      if (isThereNewChat)
                        Positioned(
                          right: 4,
                          top: -2,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  )
                : SizedBox.shrink();
    }
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
