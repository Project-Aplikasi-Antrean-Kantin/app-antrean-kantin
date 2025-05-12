import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/order_provider.dart';
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
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageTimeOutSubscription;

  @override
  void initState() {
    super.initState();
    // Fetch orders for all statuses on initialization
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final user = authProvider.user;

    Future.wait([
      for (var status in OrderStatus.values)
        orderProvider.fetchOrders(context, user.token, status),
    ]);

    // Listen for foreground notifications
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification?.title == 'Pesanan Masuk') {
        _handleNewOrderNotification(orderProvider, user);
      }
    });
    _onMessageTimeOutSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification?.title == 'Pesanan Dibatalkan Otomatis') {
        _handleNewOrderNotification(orderProvider, user);
      }
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final user = authProvider.user;

    return DefaultTabController(
      initialIndex: 0, // Start at "Masuk" tab
      length: OrderStatus.values.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          title: Text(
            'Pesanan',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontWeight: semibold,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          bottom: TabBar(
            onTap: (index) {
              final status = OrderStatus.values[index];
              orderProvider.fetchOrders(context, user.token, status);
            },
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryColor,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: medium,
            ),
            tabs: OrderStatus.values
                .map((status) => Tab(
                      child: Text(
                        status.label,
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: OrderStatus.values.map((status) {
            final pesanan = orderProvider.getPesananByStatus(status);
            if (orderProvider.isLoading) {
              return Scaffold(
                backgroundColor: AppColors.backgroundColor,
                body: ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  itemCount: 2,
                  itemBuilder: (context, index) => ShimmerCard(
                    pageType: 'pesanan',
                  ),
                ),
              );
            }
            if (pesanan.isEmpty) {
              return _buildEmptyState(status);
            }
            return PesananList(
              status: status,
              onRefresh: () =>
                  orderProvider.fetchOrders(context, user.token, status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(OrderStatus status) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: () => orderProvider.fetchOrders(context, user.token, status),
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight,
            ),
            child: Center(
              child: Text(
                'Pesanan kosong',
                style: GoogleFonts.poppins(
                  color: AppColors.textColorBlack,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
