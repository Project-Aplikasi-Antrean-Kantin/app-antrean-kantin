import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_list.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class PerluPengantaran extends StatefulWidget {
  const PerluPengantaran({Key? key}) : super(key: key);

  @override
  State<PerluPengantaran> createState() => _PerluPengantaranState();
}

class _PerluPengantaranState extends State<PerluPengantaran>
    with SingleTickerProviderStateMixin {
  DateTime? _lastFetch;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController =
        TabController(length: DeliveryStatus.values.length, vsync: this);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deliveryProvider =
        Provider.of<DeliveryProvider>(context, listen: false);
    final user = authProvider.user;

    Future.wait([
      for (var status in DeliveryStatus.values)
        deliveryProvider.fetchOrders(user.token, status),
    ]);

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'ada pesanan siap diantar') {
        _handleNewDeliveryNotification(deliveryProvider, user);
      }
    });
  }

  void _handleNewDeliveryNotification(
      DeliveryProvider deliveryProvider, UserModel user) {
    // Debounce to prevent frequent fetches (e.g., within 5 seconds)
    if (mounted) {
      deliveryProvider.fetchOrders(user.token, DeliveryStatus.siapDiantar);
      _lastFetch = DateTime.now();
    }
  }

  @override
  void dispose() {
    // Cancel Firebase listeners to prevent accessing context after unmount
    _onMessageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final deliveryProvider = Provider.of<DeliveryProvider>(context);
    final user = authProvider.user;

    return DefaultTabController(
      initialIndex: 0,
      length: DeliveryStatus.values.length,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          title: Text(
            'Pengantaran',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontWeight: semibold,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            onTap: (index) {
              final status = DeliveryStatus.values[index];
              deliveryProvider.fetchOrders(user.token, status);
            },
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            indicatorColor: AppColors.primaryColor,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primaryColor,
            labelStyle: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: medium,
            ),
            tabs: DeliveryStatus.values
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
          controller: _tabController,
          physics: const NeverScrollableScrollPhysics(),
          children: DeliveryStatus.values.map((status) {
            final pesanan = deliveryProvider.getPesananByStatus(status);
            if (deliveryProvider.isLoading) {
              return ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                itemCount: 2,
                itemBuilder: (context, index) => ShimmerCard(
                  pageType: 'pesanan',
                ),
              );
            }
            if (pesanan.isEmpty) {
              return RefreshIndicator(
                backgroundColor: AppColors.backgroundColor,
                color: AppColors.primaryColor,
                onRefresh: () =>
                    deliveryProvider.fetchOrders(user.token, status),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        kBottomNavigationBarHeight -
                        80,
                    child: Center(
                      child: Text(
                        'Pengantaran kosong',
                        style: GoogleFonts.poppins(
                          color: AppColors.textColorBlack,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return DeliveryList(
              tabController: _tabController,
              status: status,
              onRefresh: () => deliveryProvider.fetchOrders(user.token, status),
            );
          }).toList(),
        ),
      ),
    );
  }
}
