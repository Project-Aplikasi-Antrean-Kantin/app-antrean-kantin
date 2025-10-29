import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:flutter_thermal_printer/utils/printer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/provider/printer_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_kasir_page.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_list.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';

class PesananTenant extends StatefulWidget {
  const PesananTenant({Key? key}) : super(key: key);

  @override
  State<PesananTenant> createState() => _PesananTenantState();
}

class _PesananTenantState extends State<PesananTenant> {
  DateTime? _lastFetch;
  final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageTimeOutSubscription;
  StreamSubscription<List<Printer>>? _devicesStreamSubscription;
  int selectedActivity = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: selectedActivity);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      // final printerProvider =
      //     Provider.of<PrinterProvider>(context, listen: false);
      final user = authProvider.user;

      // startScan(printerProvider);

      Future.wait([
        for (var status in OrderStatus.values)
          orderProvider.fetchOrders(context, user.token, status),
      ]);

      // Listen for foreground notifications
      _onMessageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.data['title']?.toString().toLowerCase();
        if (title == 'pesanan masuk') {
          _handleNewOrderNotification(orderProvider, user);
        }
      });

      _onMessageTimeOutSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.data['title']?.toString().toLowerCase();
        if (title == 'pesanan dibatalkan otomatis') {
          _handleNewOrderNotification(orderProvider, user);
        }
      });
    });
  }

  void _handleNewOrderNotification(
      OrderProvider orderProvider, UserModel user) {
    // Debounce to prevent frequent fetches (e.g., within 5 seconds)
    if (_lastFetch == null ||
        DateTime.now().difference(_lastFetch!).inSeconds > 5) {
      if (mounted) {
        orderProvider.fetchOrders(
            context, user.token, OrderStatus.pesananMasuk);
        _lastFetch = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    // Cancel Firebase listeners to prevent accessing context after unmount
    _onMessageTimeOutSubscription?.cancel();
    _onMessageSubscription?.cancel();
    _devicesStreamSubscription?.cancel();
    printer.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;

    return DefaultTabController(
      initialIndex: 0, // Start at "Masuk" tab
      length: selectedActivity == 0 ? 3 : 1,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          automaticallyImplyLeading: false,
          scrolledUnderElevation: 0,
          toolbarHeight: 120,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  'Pesanan',
                  style: GoogleFonts.poppins(
                    color: AppColors.whiteColor,
                    fontSize: 18,
                    fontWeight: bold,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor600,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final tabController =
                                  DefaultTabController.of(context);
                              if (tabController != null) {
                                tabController.animateTo(0);
                              }
                            });
                            setState(() => selectedActivity = 0);
                            _pageController.animateToPage(
                              0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedActivity == 0
                                  ? AppColors.whiteColor
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                'Online',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedActivity == 0
                                      ? AppColors.primaryColor
                                      : AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              final tabController =
                                  DefaultTabController.of(context);
                              if (tabController != null) {
                                tabController.animateTo(0);
                              }
                            });

                            setState(() => selectedActivity = 1);
                            _pageController.animateToPage(
                              1,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: selectedActivity == 1
                                  ? AppColors.whiteColor
                                  : Colors.transparent,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: Center(
                              child: Text(
                                'Kasir',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: selectedActivity == 1
                                      ? AppColors.primaryColor
                                      : AppColors.whiteColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              color: AppColors.backgroundColor,
              child: TabBar(
                onTap: (index) {
                  final status = OrderStatus.values[index];
                  orderProvider.fetchOrders(context, user.token, status);
                },
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                indicatorColor: AppColors.primaryColor,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(
                    color: AppColors.primaryColor,
                    width: 2,
                  ),
                ),
                labelColor: AppColors.primaryColor,
                labelStyle: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: medium,
                ),
                tabs: selectedActivity == 0
                    ? OrderStatus.values
                        .map((status) => Tab(
                              child: Text(
                                status.label,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ))
                        .toList()
                    : [
                        Tab(
                          child: Text(
                            'Diproses',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        )
                      ],
              ),
            ),
          ),
        ),
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          onPageChanged: (index) {
            setState(() => selectedActivity = index);
          },
          children: [
            TabBarView(
              physics: const NeverScrollableScrollPhysics(),
              children: OrderStatus.values.map((status) {
                final pesanan = orderProvider.getPesananByStatus(status);
                if (orderProvider.isLoading) {
                  return Scaffold(
                    backgroundColor: AppColors.backgroundColor,
                    body: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 10),
                      itemCount: 2,
                      itemBuilder: (context, index) =>
                          ShimmerCard.buildPesananPageShimmer(status, printer),
                    ),
                  );
                }
                if (pesanan.isEmpty) {
                  return RefreshIndicator(
                    backgroundColor: AppColors.backgroundColor,
                    color: AppColors.primaryColor,
                    onRefresh: () {
                      orderProvider.clearError();
                      return orderProvider.fetchOrders(
                          context, user.token, status);
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height -
                            kToolbarHeight -
                            kBottomNavigationBarHeight -
                            80,
                        child: Center(
                            child: orderProvider.errorMessage != null
                                ? orderProvider.errorMessage!
                                            .contains('lookup') ||
                                        orderProvider.errorMessage!
                                            .contains('Connection')
                                    ? Column(
                                        spacing: 8,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                              image: const AssetImage(
                                                  'assets/images/No-connection.png')),
                                          Text(
                                            'Upss Koneksimu Hilang!',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.whiteColor900,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'Cek jaringan internet kamu dulu, ya.    Tenang, kami tetap nungguin kamu balik 😄',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF585858),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              orderProvider.clearError();
                                              try {
                                                await orderProvider.fetchOrders(
                                                    context,
                                                    user.token,
                                                    status);
                                              } catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: orderProvider
                                                        .errorMessage!);
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 16),
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  48,
                                              child: Center(
                                                  child: Text('Coba Lagi',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: AppColors
                                                            .whiteColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ))),
                                            ),
                                          )
                                        ],
                                      )
                                    : Column(
                                        spacing: 8,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image(
                                              image: const AssetImage(
                                                  'assets/images/No-connection.png')),
                                          Text(
                                            'Gagal memuat pesanan!',
                                            style: GoogleFonts.poppins(
                                              color: AppColors.whiteColor900,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          Text(
                                            'Memuat pesanan gagal, silahkan coba lagi',
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.poppins(
                                              color: const Color(0xFF585858),
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () async {
                                              orderProvider.clearError();
                                              try {
                                                await orderProvider.fetchOrders(
                                                    context,
                                                    user.token,
                                                    status);
                                              } catch (e) {
                                                Fluttertoast.showToast(
                                                    msg: orderProvider
                                                        .errorMessage!);
                                              }
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(top: 16),
                                              padding: EdgeInsets.all(16),
                                              decoration: BoxDecoration(
                                                color: AppColors.primaryColor,
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width -
                                                  48,
                                              child: Center(
                                                  child: Text('Coba Lagi',
                                                      style:
                                                          GoogleFonts.poppins(
                                                        color: AppColors
                                                            .whiteColor,
                                                        fontSize: 16,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ))),
                                            ),
                                          )
                                        ],
                                      )
                                : Center(
                                    child: Text(
                                      'Pesanan ${status.label} kosong',
                                      style: GoogleFonts.poppins(
                                        color: AppColors.textColorBlack,
                                        fontSize: 14,
                                      ),
                                    ),
                                  )),
                      ),
                    ),
                  );
                }
                return PesananList(
                  printer: printer,
                  status: status,
                  onRefresh: () =>
                      orderProvider.fetchOrders(context, user.token, status),
                );
              }).toList(),
            ),
            RiwayatKasirPage()
          ],
        ),
      ),
    );
  }
}
