import 'dart:async';
import 'dart:developer';
import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/step_model.dart';
import 'package:testgetdata/data/model/transaksi_detail_model.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/remote/driver_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/common/format_date.dart';
import 'package:testgetdata/presentation/views/pembeli/chat_page.dart';
import 'package:testgetdata/presentation/views/pembeli/checkout_qris.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_bluetooth_devices.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/pesanan_pembeli_tile.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/show_bottom_sheet_ping.dart';
import 'package:testgetdata/presentation/widgets/step_progress.dart';
import 'package:testgetdata/utils/has_internet_access.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:permission_handler/permission_handler.dart';

class DetailRiwayat extends StatefulWidget {
  final Pesanan pesanan;
  final VoidCallback refreshData;
  final bool? fromCartPage;
  final String token;
  final String label;

  const DetailRiwayat({
    this.fromCartPage,
    super.key,
    required this.refreshData,
    required this.token,
    required this.label,
    required this.pesanan,
  });

  @override
  State<DetailRiwayat> createState() => _DetailRiwayatState();
}

class _DetailRiwayatState extends State<DetailRiwayat> {
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  bool _isCooldown = false; // state untuk cooldown
  int _cooldownSeconds = 30; // lama cooldown (detik)
  Timer? _timer;
  final _flutterThermalPrinterPlugin = FlutterThermalPrinter.instance;
  // StreamSubscription<List<Printer>>? _devicesStreamSubscription;
  // StreamSubscription<bool>? _bluetoothConnection;
  bool isBleTurnedOn = false;
  bool isLoadingBluetooth = false;
  bool _isPrinting = false;

  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     startScan(Provider.of<PrinterProvider>(context, listen: false));
  //   }
  // }

  // void startScan(PrinterProvider printerProvider) async {
  //   setState(() {
  //     isLoadingBluetooth = true;
  //   });

  //   _devicesStreamSubscription?.cancel();
  //   _bluetoothConnection?.cancel();
  //   print('Mulai scan printer BLE...');

  //   // === Request Permission ===
  //   if (await Permission.bluetoothScan.request().isGranted &&
  //       await Permission.bluetoothConnect.request().isGranted &&
  //       await Permission.locationWhenInUse.request().isGranted) {
  //     // Dengarkan status BLE (nyala/mati)
  //     _bluetoothConnection = _flutterThermalPrinterPlugin.isBleTurnedOnStream
  //         .listen((event) async {
  //       print("isBleTurnedOnStream: $event");

  //       if (!mounted) return;
  //       setState(() {
  //         isBleTurnedOn = event;
  //       });

  //       if (event == true) {
  //         // ✅ Kalau Bluetooth udah nyala, baru mulai scan
  //         try {
  //           await _flutterThermalPrinterPlugin
  //               .getPrinters(connectionTypes: [ConnectionType.BLE]);

  //           _devicesStreamSubscription = _flutterThermalPrinterPlugin
  //               .devicesStream
  //               .listen((List<Printer> event) {
  //             print("Ditemukan ${event.length} perangkat:");
  //             for (var d in event) {
  //               print("- ${d.name} (${d.address})");
  //             }
  //             printerProvider.setPrinters(event);
  //           });
  //         } catch (e) {
  //           Fluttertoast.showToast(msg: e.toString());
  //         } finally {
  //           if (mounted) {
  //             setState(() {
  //               isLoadingBluetooth = false;
  //             });
  //           }
  //         }
  //       } else {
  //         // 🚫 Bluetooth belum nyala
  //         if (mounted) {
  //           Fluttertoast.showToast(
  //             msg: "Bluetooth belum aktif, mohon nyalakan dulu...",
  //           );
  //         }

  //         // Opsional: buka dialog atau auto aktifkan
  //         await _flutterThermalPrinterPlugin.turnOnBluetooth();
  //       }
  //     });
  //   } else {
  //     debugPrint('Bluetooth permission not granted');
  //     setState(() {
  //       isLoadingBluetooth = false;
  //     });
  //   }
  // }

  // /// 🛑 Hentikan scan
  // void stopScan() {
  //   _flutterThermalPrinterPlugin.stopScan();
  // }

  /// 🧾 Fungsi untuk generate data struk (ESC/POS)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // final printerProvider =
      //     Provider.of<PrinterProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      // _bluetoothConnection = _flutterThermalPrinterPlugin.isBleTurnedOnStream
      //     .listen((event) async {
      //   print("isBleTurnedOnStream: $event");

      //   if (!mounted) return;
      //   setState(() {
      //     isBleTurnedOn = event;
      //   });
      // });
      print(
          'widget.label: ${widget.label} authProvider.user.role: ${authProvider.user.role}');
      if (widget.label.toLowerCase() == 'jual' &&
          authProvider.user.role.contains('tenant')) {
        // startScan(printerProvider);
      }

      if (widget.pesanan.status == 'pending' && widget.fromCartPage == true) {
        Navigator.push(context,
            CustomPageBuilder(page: CheckoutQris(pesanan: widget.pesanan)));
      }
    });
    if (_onMessageSubscription == null) {
      _onMessageSubscription = FirebaseMessaging.onMessage.listen((
        RemoteMessage message,
      ) {
        final title = message.data['title']?.toString().toLowerCase();
        if (title != null &&
            title.contains('pesanan') &&
            !title.contains('diantar')) {
          _refreshData();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _onMessageSubscription?.cancel();
    // _devicesStreamSubscription?.cancel();
    _flutterThermalPrinterPlugin.stopScan();
    // _bluetoothConnection?.cancel();

    super.dispose();
  }

  void _startCooldown() {
    setState(() {
      _isCooldown = true;
    });

    _timer = Timer(Duration(seconds: _cooldownSeconds), () {
      if (mounted) {
        setState(() {
          _isCooldown = false;
        });
      }
    });
  }

  Future<void> _handlePress() async {
    final connectivityResult = await hasInternetAccess();
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (!connectivityResult) {
      Fluttertoast.showToast(msg: 'Tidak ada koneksi internet');
      showNoConnectionBottomSheet(context: context, onRetry: () {});
      return;
    }
    try {
      final success = await DriverDataSource().pingCustomer(
        user.token,
        widget.pesanan.id.toString(),
      );

      if (success.success) {
        Fluttertoast.showToast(msg: 'Ping terkirim');
        _startCooldown(); // mulai cooldown kalau sukses
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(
            msg: '${success.error ?? 'Ping gagal terkirim'}');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    }
  }

  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    widget.refreshData();
  }

  @override
  Widget build(BuildContext context) {
    final List<ListTransaksiDetail> pesananPembeli =
        widget.pesanan.listTransaksiDetail;

    int totalItem = 0;

    for (var item in pesananPembeli) {
      // subtotal dari BE masih bermasalah, sementara pakai ini
      totalItem += item.jumlah;
    }

    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        final isThereNewChat = historyProvider.unreadMessagesList.contains(
          widget.pesanan.id,
        );
        final List<StepModel> steps =
            historyProvider.selectedPesanan!.isAntar == 1
                ? historyProvider.selectedPesanan!.status == 'refund_selesai'
                    ? [
                        StepModel(
                          padding: EdgeInsets.only(left: 0),
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Ditolak',
                          icon: HugeIcons.strokeRoundedCancel02,
                        ),
                        StepModel(
                          textAlign: TextAlign.center,
                          title: 'Siap Diantar',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.center,
                          title: 'Diantar',
                          icon: HugeIcons.strokeRoundedUserRoadside,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                    : [
                        StepModel(
                          padding: EdgeInsets.only(left: 0),
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Diproses',
                          icon: HugeIcons.strokeRoundedPan03,
                        ),
                        StepModel(
                          textAlign: TextAlign.center,
                          title: 'Siap Diantar',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.center,
                          title: 'Diantar',
                          icon: HugeIcons.strokeRoundedUserRoadside,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                : historyProvider.selectedPesanan!.status == 'refund_selesai'
                    ? [
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.start,
                          title: 'Ditolak',
                          icon: HugeIcons.strokeRoundedCancel02,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 8),
                          textAlign: TextAlign.center,
                          title: 'Siap Diambil',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ]
                    : [
                        StepModel(
                          textAlign: TextAlign.start,
                          title: 'Masuk',
                          icon: HugeIcons.strokeRoundedNoteDone,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 12),
                          textAlign: TextAlign.start,
                          title: 'Diproses',
                          icon: HugeIcons.strokeRoundedPan03,
                        ),
                        StepModel(
                          padding: EdgeInsets.only(left: 8),
                          textAlign: TextAlign.center,
                          title: 'Siap Diambil',
                          icon: HugeIcons.strokeRoundedMilkCarton,
                        ),
                        StepModel(
                          textAlign: TextAlign.end,
                          title: 'Selesai',
                          icon: HugeIcons.strokeRoundedCheckmarkBadge02,
                        ),
                      ];
        return Scaffold(
          backgroundColor: AppColors.backgroundColor,
          floatingActionButton: Consumer2<CartProvider, AuthProvider>(
            builder: (context, cartProvider, authProvider, child) {
              final screenWidth = MediaQuery.of(context).size.width;
              final chatType = getChatType(
                  historyProvider.selectedPesanan!, authProvider.user.nama);
              final isValidStatus = historyProvider.selectedPesanan!.status !=
                      'selesai' &&
                  historyProvider.selectedPesanan!.status !=
                      'pesanan_ditolak' &&
                  historyProvider.selectedPesanan!.status != 'refund_selesai' &&
                  historyProvider.selectedPesanan!.status != 'gagal_bayar';
              print(
                historyProvider.unreadMessagesList.contains(
                  historyProvider.selectedPesanan!.id,
                ),
              );
              final canChatTenant = (historyProvider.availableChatList.contains(
                        historyProvider.selectedPesanan!.id,
                      ) &&
                      chatType == 'tenant') ||
                  widget.label == 'Jual';

              if (historyProvider.selectedPesanan!.status == 'pending' &&
                  widget.label == 'Beli')
                return SizedBox(
                  width: screenWidth - 48, // ini dia kuncinya!
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: CheckoutQris(
                            pesanan: historyProvider.selectedPesanan!,
                          ),
                        ),
                      );
                    },
                    backgroundColor: AppColors.primaryColor,
                    label: Center(
                      child: Text(
                        'Bayar',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                );

              // if (widget.label == 'Antar') return Container();
              if (historyProvider.selectedPesanan!.status == 'diantar' &&
                  widget.label == 'Jual') return Container();

              if (widget.label == 'Beli') if (isValidStatus) {
                return SizedBox(
                  width: screenWidth - 48, // ini dia kuncinya!
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      print("cek");
                      final connectivityResult = await hasInternetAccess();
                      print("yahaha");
                      if (!connectivityResult) {
                        Fluttertoast.showToast(
                          msg: "Tidak ada koneksi internet",
                          backgroundColor: AppColors.errorColor,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      if (chatType == 'tenant' && widget.label == 'Beli') {
                        if (!canChatTenant) {
                          Fluttertoast.showToast(
                            msg:
                                "Harus tenant yang melakukan chat terlebih dahulu",
                          );
                          return;
                        }
                      }
                      await historyProvider.removeUnreadMessages(
                        historyProvider.selectedPesanan!.id,
                      );
                      Navigator.push(
                        context,
                        CustomPageBuilder(
                          page: ChatPage(
                            pesanan: historyProvider.selectedPesanan!,
                            chatType: chatType,
                          ),
                        ),
                      );
                    },
                    backgroundColor: chatType == 'tenant'
                        ? canChatTenant
                            ? AppColors.primaryColor
                            : Colors.grey
                        : AppColors.primaryColor,
                    label: Center(
                      child: Text(
                        'Chat ${chatType == 'driver' ? widget.label == 'Antar' ? 'Pembeli' : 'Driver' : widget.label == 'Beli' ? 'Penjual' : 'Pembeli'}',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                );
              } else {
                return SizedBox(
                  width: screenWidth - 48, // ini dia kuncinya!
                  child: FloatingActionButton.extended(
                    onPressed: () async {
                      final connectivityResult = await hasInternetAccess();
                      if (!connectivityResult) {
                        Fluttertoast.showToast(
                          msg: "Tidak ada koneksi internet",
                          backgroundColor: AppColors.errorColor,
                          textColor: Colors.white,
                        );
                        return;
                      }
                      if (historyProvider.selectedPesanan!
                              .listTransaksiDetail[0].menus?.tenants ==
                          null) return;
                      final cartMenu =
                          historyProvider.selectedPesanan!.toCartMenuList();

                      cartProvider.setCurrentTenant(
                        historyProvider.selectedPesanan!.listTransaksiDetail[0]
                            .menus!.tenants!,
                        cartMenu,
                      );

                      Future.delayed(const Duration(milliseconds: 300), () {
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: MenuTenant(
                              url:
                                  '${MasbroConstants.url}/tenants/${historyProvider.selectedPesanan!.listTransaksiDetail[0].menus!.tenants!.id}',
                              cart: cartMenu,
                            ),
                          ),
                        );
                      });
                    },
                    backgroundColor: AppColors.primaryColor,
                    label: Center(
                      child: Text(
                        'Pesan Lagi',
                        style: GoogleFonts.poppins(
                          color: AppColors.whiteColor,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                  ),
                );
              }
              else {
                if (isValidStatus) {
                  return SizedBox(
                    width: screenWidth - 48, // ini dia kuncinya!
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        print("cek");
                        final connectivityResult = await hasInternetAccess();
                        print("yahaha");
                        if (!connectivityResult) {
                          Fluttertoast.showToast(
                            msg: "Tidak ada koneksi internet",
                            backgroundColor: AppColors.errorColor,
                            textColor: Colors.white,
                          );
                          return;
                        }

                        await historyProvider.removeUnreadMessages(
                          historyProvider.selectedPesanan!.id,
                        );
                        Navigator.push(
                          context,
                          CustomPageBuilder(
                            page: ChatPage(
                              pesanan: historyProvider.selectedPesanan!,
                              chatType: chatType,
                            ),
                          ),
                        );
                      },
                      backgroundColor: chatType == 'tenant'
                          ? canChatTenant
                              ? AppColors.primaryColor
                              : Colors.grey
                          : AppColors.primaryColor,
                      label: Center(
                        child: Text(
                          'Chat ${chatType == 'driver' ? widget.label == 'Antar' ? 'Pembeli' : 'Driver' : widget.label == 'Beli' ? 'Penjual' : 'Pembeli'}',
                          style: GoogleFonts.poppins(
                            color: AppColors.whiteColor,
                            fontSize: 14,
                            fontWeight: semibold,
                          ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Container();
                }
              }
            },
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          body: SafeArea(
            child: RefreshIndicator(
              backgroundColor: AppColors.backgroundColor,
              color: AppColors.primaryColor,
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12, right: 12),
                      child: SizedBox(
                        height: 56,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedArrowLeft02,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Rincian Pesanan',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.blackColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color:
                                  historyProvider.selectedPesanan!.isPriority ==
                                          1
                                      ? AppColors.primaryColor
                                      : Colors.grey),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          spacing: 4,
                          children: [
                            if (historyProvider.selectedPesanan!.isPriority ==
                                1)
                              Icon(Iconsax.flash_1,
                                  size: 24, color: AppColors.primaryColor),
                            Text(
                              historyProvider.selectedPesanan!.isPriority == 1
                                  ? "Express"
                                  : "Reguler",
                              style: GoogleFonts.poppins(
                                color: historyProvider
                                            .selectedPesanan!.isPriority ==
                                        1
                                    ? AppColors.primaryColor
                                    : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _buildStatus(
                      historyProvider.selectedPesanan?.status ?? 'selesai',
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildAlamatPengantaran(
                        historyProvider.selectedPesanan!,
                      ),
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildHeaderPesanan(
                        historyProvider.selectedPesanan!,
                        context,
                        steps,
                      ),
                    ),
                    if (historyProvider.selectedPesanan!.status != 'pending' &&
                        historyProvider.selectedPesanan!.status !=
                            'gagal_bayar')
                      DashedDivider(height: 2, color: AppColors.blackColor100),
                    if (historyProvider.selectedPesanan!.status != 'pending' &&
                        historyProvider.selectedPesanan!.status !=
                            'gagal_bayar')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          spacing: 16,
                          children: [
                            StepProgress(
                              isRefund:
                                  historyProvider.selectedPesanan!.status ==
                                      'refund_selesai',
                              currentStep: getCurrentStep(
                                historyProvider.selectedPesanan!.status,
                                historyProvider.selectedPesanan!.isAntar,
                              ),
                              steps: steps,
                            ),
                            if (historyProvider.selectedPesanan!.isAntar == 1 &&
                                (historyProvider.selectedPesanan!.status ==
                                        'diantar' ||
                                    historyProvider.selectedPesanan!.status ==
                                        'selesai'))
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 8,
                                    children: [
                                      ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(999),
                                        child: historyProvider.selectedPesanan!
                                                    .fotoDriver !=
                                                null
                                            ? ImageByUrl(
                                                url: historyProvider
                                                        .selectedPesanan!
                                                        .fotoDriver ??
                                                    '',
                                                height: 48,
                                                width: 48,
                                              )
                                            : Center(
                                                child: Icon(
                                                  Icons.person,
                                                  size: 48,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                      ),
                                      Text(
                                        historyProvider
                                            .selectedPesanan!.namaDriver!,
                                        style: GoogleFonts.poppins(
                                          color: AppColors.blackColor,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "Driver",
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primaryColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '${historyProvider.selectedPesanan!.listTransaksiDetail[0].menus?.tenants?.namaTenant}',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 14,
                          fontWeight: semibold,
                        ),
                      ),
                    ),
                    ...pesananPembeli.map(
                      (item) => PesananItemWidget(
                        pesanan: item,
                        tolakPesanan: () {},
                        terimaPesanan: () {},
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildSubtotalSection(
                        historyProvider.selectedPesanan!,
                        totalItem,
                      ),
                    ),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildBiayaLainSection(
                        historyProvider.selectedPesanan!,
                      ),
                    ),
                    if (historyProvider.selectedPesanan!.catatanPenolakan !=
                        null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              'Catatan Penolakan',
                              style: GoogleFonts.poppins(
                                color: AppColors.errorColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => showBottomSheetPenolakan(
                                context,
                                historyProvider.selectedPesanan!,
                              ),
                              child: Text(
                                'Detail',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (historyProvider.selectedPesanan!.buktiPengantaran !=
                        null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          spacing: 8,
                          children: [
                            Text(
                              'Bukti Pengantaran',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                                fontSize: 14,
                                fontWeight: semibold,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    backgroundColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ImageByUrl(
                                        height:
                                            MediaQuery.of(context).size.height /
                                                2,
                                        width:
                                            MediaQuery.of(context).size.width -
                                                48,
                                        url:
                                            '/storage/${historyProvider.selectedPesanan!.buktiPengantaran!}', // ganti dengan path/URL gambarnya
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Text(
                                'Lihat Foto',
                                style: GoogleFonts.poppins(
                                  color: AppColors.primaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.label == 'Antar' &&
                        widget.pesanan.status == 'diantar')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hubungi Pembeli',
                              style: GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontSize: 16,
                                fontWeight: semibold,
                              ),
                            ),
                            Row(
                              spacing: 8,
                              mainAxisAlignment:
                                  widget.pesanan.status == 'diantar'
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.center,
                              children: [
                                if (widget.pesanan.status == 'diantar')
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          OutlinedButton(
                                            style: OutlinedButton.styleFrom(
                                              shape:
                                                  const CircleBorder(), // ✅ ini yang bikin benar-benar bundar
                                              side: BorderSide(
                                                color:
                                                    AppColors.primaryColor300,
                                                width: 2,
                                              ),
                                              padding: const EdgeInsets.all(
                                                12,
                                              ), // jarak icon dengan border
                                            ),
                                            onPressed: () async {
                                              final connectivityResult =
                                                  await hasInternetAccess();
                                              if (!connectivityResult) {
                                                Fluttertoast.showToast(
                                                  msg:
                                                      'Tidak ada koneksi internet',
                                                );
                                                showNoConnectionBottomSheet(
                                                  context: context,
                                                  onRetry: () {},
                                                );
                                                return;
                                              }
                                              historyProvider
                                                  .removeUnreadMessages(
                                                widget.pesanan.id,
                                              );

                                              Navigator.push(
                                                context,
                                                CustomPageBuilder(
                                                  page: ChatPage(
                                                    pesanan: widget.pesanan,
                                                    chatType: "driver",
                                                  ),
                                                ),
                                              );
                                            },
                                            child: const Icon(
                                              Iconsax.message_text_copy,
                                              size: 24,
                                              color: AppColors.primaryColor300,
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
                                      OutlinedButton(
                                        style: OutlinedButton.styleFrom(
                                          shape: const CircleBorder(),
                                          side: BorderSide(
                                            color: _isCooldown
                                                ? Colors
                                                    .grey // abu kalau cooldown
                                                : AppColors.primaryColor300,
                                            width: 2,
                                          ),
                                          padding: const EdgeInsets.all(12),
                                        ),
                                        onPressed: _isCooldown
                                            ? null
                                            : () => showBottomSheetPing(
                                                  context: context,
                                                  onFinish: _handlePress,
                                                  canSend: !_isCooldown,
                                                ), // disable pas cooldown
                                        child: HugeIcon(
                                          icon: HugeIcons
                                              .strokeRoundedMegaphone02,
                                          color: _isCooldown
                                              ? Colors.grey
                                              : AppColors.primaryColor300,
                                        ),
                                      ),
                                    ],
                                  ),

                                // _buildDivider(),
                                // _buildRincianPesanan(pesanan),
                                // _buildButton(pesanan.status, context),
                              ],
                            ),
                          ],
                        ),
                      ),
                    if (widget.pesanan.status != 'pending' &&
                        widget.pesanan.status != 'refund_selesai' &&
                        widget.pesanan.status != 'pesanan_masuk' &&
                        widget.pesanan.status != 'gagal_bayar' &&
                        widget.pesanan.cashbackAmount != null &&
                        widget.pesanan.cashbackAmount! > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              "Cashback",
                              style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: AppColors.successColor),
                            ),
                            const Spacer(),
                            Text(
                              FormatCurrency.intToStringCurrency(
                                  widget.pesanan.cashbackAmount ?? 0),
                              style: GoogleFonts.poppins(
                                  fontWeight: semibold,
                                  color: AppColors.successColor),
                            ),
                          ],
                        ),
                      ),
                    if (widget.label.toLowerCase() == 'jual')
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cetak Nota Pesanan"),
                            GestureDetector(
                              onTap: () async {
                                final user = Provider.of<AuthProvider>(context,
                                        listen: false)
                                    .user;
                                final printerProvider =
                                    Provider.of<PrinterProvider>(context,
                                        listen: false);
                                if (printerProvider.selectedPrinter == null) {
                                  print(user.menu
                                      .map((element) => element.url)
                                      .toList());
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    CustomPageBuilder(
                                      page: NavbarHome(
                                        pageIndex: user.menu.indexWhere(
                                            (element) =>
                                                element.url == '/profile'),
                                      ),
                                    ),
                                    (route) => false,
                                  );
                                  // if (isBleTurnedOn) {
                                  //   showBottomSheetBluetoothDevices(context);
                                  // }
                                  Fluttertoast.showToast(
                                      msg:
                                          'Silahkan Pilih Printer, tekan Mesin Cetak');
                                  return;
                                }
                                setState(() {
                                  _isPrinting = true;
                                });
                                // if (isLoadingBluetooth) {
                                //   Fluttertoast.showToast(
                                //       msg: "Memindai Perangkat Bluetooth...");
                                //   return;
                                // }
                                // if (!isBleTurnedOn) {
                                //   Fluttertoast.showToast(
                                //       msg:
                                //           "Bluetooth belum diaktifkan, membuka pengaturan...");

                                //   AppSettings.openAppSettings(
                                //       type: AppSettingsType.bluetooth);
                                //   return;
                                // }
                                // showBottomSheetBluetoothDevices(context);

                                try {
                                  await _flutterThermalPrinterPlugin.connect(
                                      printerProvider.selectedPrinter!);
                                  final data = await generateReceipt(
                                      widget.pesanan,
                                      printerProvider.selectedPrinter!,
                                      context);

                                  await _flutterThermalPrinterPlugin.printData(
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
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
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
                                              icon: HugeIcons
                                                  .strokeRoundedInvoice04,
                                              size: 16,
                                              color: AppColors.whiteColor100),
                                          Text("Cetak",
                                              style: GoogleFonts.poppins(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      AppColors.whiteColor100,
                                                  fontSize: 12))
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future showBottomSheetPenolakan(BuildContext context, Pesanan pesanan) async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      builder: (context) => SafeArea(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.only(
                top: 8,
                bottom: 18,
                left: 18,
                right: 18,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Text(
                      'Catatan Penolakan',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.blackColor100,
                        width: 2,
                      ),
                    ),
                    height: 124,
                    child: TextField(
                      controller: TextEditingController(
                        text: pesanan.catatanPenolakan,
                      ),
                      readOnly: true,
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
                    ),
                  ),
                  SizedBox(height: 40),
                  PrimaryButton(
                    borderRadius: 16,
                    height: 48,
                    color: AppColors.primaryColor,
                    child: Text(
                      'Tutup',
                      style: GoogleFonts.poppins(
                        color: AppColors.whiteColor100,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
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
                size: 24, color: getStatusColor(status)),
            Text(
              capitalizeFirstLetter(status.replaceAll('_', ' ')),
              style: GoogleFonts.poppins(
                color: getStatusColor(status),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
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

  String getChatType(Pesanan pesanan, String namaUser) {
    switch (pesanan.status) {
      case 'pesanan_masuk':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'pesanan_diproses':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diambil':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'siap_diantar':
        return ((pesanan.driverId != null && widget.label == 'Beli') ||
                (pesanan.namaDriver != null && pesanan.namaDriver == namaUser))
            ? 'driver'
            : 'tenant';
      case 'diantar':
        return 'driver';
      default:
        return 'proses';
    }
  }

  int getCurrentStep(String status, int isAntar) {
    if (isAntar == 1) {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diantar':
          return 3;
        case 'diantar':
          return 4;
        case 'selesai':
          return 5;
        case 'refund_selesai':
          return 2;
        case 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
    } else {
      switch (status) {
        case 'pesanan_masuk':
          return 1;
        case 'pesanan_diproses':
          return 2;
        case 'siap_diambil':
          return 3;
        case 'selesai':
          return 4;
        case 'refund_selesai' || 'pesanan_ditolak':
          return 2;
        default:
          return 1;
      }
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

  Widget _buildAlamatPengantaran(Pesanan pesanan) {
    return Container(
      width: double.infinity,
      child: Column(
        spacing: 4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Lokasi Pengantaran",
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tanggal',
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                  fontWeight: semibold,
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  pesanan.isAntar == 1
                      ? '${pesanan.namaRuangan}${pesanan.catatanLokasi != null && pesanan.catatanLokasi!.trim().isNotEmpty ? ' (${pesanan.catatanLokasi})' : ''}'
                      : capitalizeFirstLetter(
                          'Tidak Diantar, Ambil Pesanan ke ${pesanan.listTransaksiDetail[0].menus?.tenants?.namaTenant ?? "-"}',
                        ),
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                FormatDate.formatDateTimeWithWIB(pesanan.createdAt),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPesanan(
    Pesanan pesanan,
    BuildContext context,
    List<StepModel> steps,
  ) {
    return Column(
      spacing: 4,
      children: [
        Row(
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2,
              child: Text(
                'Kode Pemesanan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: semibold,
                  color: AppColors.blackColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                '${pesanan.kodePemesanan}',
                textAlign: TextAlign.end,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: semibold,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pembeli',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
            Text(
              'No. Pesanan',
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${pesanan.namaPembeli}',
                softWrap: true,
                style: GoogleFonts.poppins(
                  color: AppColors.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'ORDER-${pesanan.id}',
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

  Widget _buildSubtotalSection(Pesanan pesanan, int totalItem) {
    return Column(
      spacing: 8,
      children: [
        DashedDivider(height: 2, color: AppColors.blackColor100),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Sub total : ${totalItem} Menu",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(
                pesanan.total - pesanan.ongkosKirim,
              ),
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBiayaLainSection(Pesanan pesanan) {
    return Column(
      children: [
        _buildRowText("Biaya layanan", pesanan.biayaLayanan),
        if (pesanan.isAntar == 1) const SizedBox(height: 10),
        if (pesanan.isAntar == 1)
          _buildRowText("Biaya Pengantaran", pesanan.ongkosKirim),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Total",
              style: GoogleFonts.poppins(
                color: AppColors.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              FormatCurrency.intToStringCurrency(pesanan.total),
              style: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRowText(String label, int value, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          FormatCurrency.intToStringCurrency(value),
          style: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
