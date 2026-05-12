import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_thermal_printer/flutter_thermal_printer.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_kasir.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_kasir_tab_bar.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_online_tab_bar.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_online_tab_view.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant/widgets/pesanan_tab_switcher.dart';

class PesananTenant extends StatefulWidget {
  final int? selectedActivity;
  const PesananTenant({Key? key, this.selectedActivity}) : super(key: key);

  @override
  State<PesananTenant> createState() => _PesananTenantState();
}

class _PesananTenantState extends State<PesananTenant>
    with TickerProviderStateMixin {
  final FlutterThermalPrinter printer = FlutterThermalPrinter.instance;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  late int selectedActivity;
  late PageController _pageController;
  late TabController _tabController;
  late TabController _tabControllerCashier;

  @override
  void initState() {
    super.initState();
    selectedActivity = widget.selectedActivity ?? 0;
    _pageController = PageController(initialPage: selectedActivity);
    _tabController =
        TabController(length: OrderStatus.values.length, vsync: this);
    _tabControllerCashier = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
      // _listenNotification();
    });
  }

  void _initData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    final user = auth.user;

    Future.wait([
      for (var status in OrderStatus.values)
        orderProvider.fetchOrders(context, user.token, status),
    ]);
    kasirProvider.getListCashierTransaction(user.token);
  }

  // void _listenNotification() {
  //   final auth = Provider.of<AuthProvider>(context, listen: false);
  //   final orderProvider = Provider.of<OrderProvider>(context, listen: false);
  //   final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
  //   final user = auth.user;

  //   _onMessageSubscription ??=
  //       FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
  //     final title = message.data['title']?.toString().toLowerCase();
  //     final body = message.data['body']?.toString().toLowerCase();

  //     if (title != null && title.contains('pesanan')) {
  //       await _handleNewOrderNotification(orderProvider, user);
  //     }

  //     if (title != null && title.contains('kasir') && body != null) {
  //       final cashierId = int.parse(
  //         body.split(' ')[1].trim().replaceAll(RegExp(r'[^0-9]'), ''),
  //       );
  //       final data = await kasirProvider.getCashierTransactionById(
  //         user.token,
  //         cashierId,
  //       );
  //       if (context.mounted) {
  //         showPaymentSuccessDialog(context, data.total);
  //       }
  //     }
  //   });
  // }

  // Future<void> _handleNewOrderNotification(
  //     OrderProvider orderProvider, UserModel user) async {
  //   if (_lastFetch == null ||
  //       DateTime.now().difference(_lastFetch!).inSeconds > 5) {
  //     if (!mounted) return;
  //     await orderProvider.fetchOrders(
  //         context, user.token, OrderStatus.pesananMasuk);
  //     await orderProvider.fetchOrders(
  //         context, user.token, OrderStatus.pesananDiproses);
  //     _lastFetch = DateTime.now();
  //   }
  // }

  @override
  void dispose() {
    _onMessageSubscription?.cancel();
    _tabController.dispose();
    _tabControllerCashier.dispose();
    printer.stopScan();
    super.dispose();
  }

  void _onSwitchActivity(int index) {
    setState(() => selectedActivity = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = auth.user;

    return Scaffold(
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
              padding: const EdgeInsets.only(top: 8, bottom: 8),
              child: Text(
                'Pesanan',
                style: GoogleFonts.poppins(
                  color: AppColors.whiteColor,
                  fontSize: 18,
                  fontWeight: bold,
                ),
              ),
            ),
            PesananTabSwitcher(
              selectedActivity: selectedActivity,
              onSwitch: _onSwitchActivity,
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: AppColors.backgroundColor,
            child: selectedActivity == 0
                ? PesananOnlineTabBar(
                    controller: _tabController,
                    onTap: (index) {
                      final status = OrderStatus.values[index];
                      orderProvider.fetchOrders(context, user.token, status);
                    },
                  )
                : PesananKasirTabBar(
                    controller: _tabControllerCashier,
                  ),
          ),
        ),
      ),
      body: _buildBody(orderProvider, user),
    );
  }

  Widget _buildBody(OrderProvider orderProvider, UserModel user) {
    return PageView(
      controller: _pageController,
      physics: const NeverScrollableScrollPhysics(),
      onPageChanged: (index) => setState(() => selectedActivity = index),
      children: [
        // ── Tab Online ──
        TabBarView(
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: OrderStatus.values.map((status) {
            return PesananOnlineTabView(
              status: status,
              printer: printer,
              orderProvider: orderProvider,
              onRetry: () => orderProvider.fetchOrders(
                context,
                Provider.of<AuthProvider>(context, listen: false).user.token,
                status,
              ),
            );
          }).toList(),
        ),

        // ── Tab Kasir ──
        Consumer<KasirProvider>(
          builder: (context, kasirProvider, _) {
            if (kasirProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            final listPending = kasirProvider.cashierTransactions
                .where((t) => t.status == 'pending')
                .toList();
            final listDiproses = kasirProvider.cashierTransactions
                .where((t) => t.status == 'pesanan_diproses')
                .toList();

            return TabBarView(
              controller: _tabControllerCashier,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                PesananKasir(data: listPending),
                PesananKasir(data: listDiproses),
              ],
            );
          },
        ),
      ],
    );
  }
}
