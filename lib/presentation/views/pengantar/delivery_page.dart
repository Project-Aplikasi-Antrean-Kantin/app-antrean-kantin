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

class _PerluPengantaranState extends State<PerluPengantaran> {
  DateTime? _lastFetch;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final deliveryProvider =
        Provider.of<DeliveryProvider>(context, listen: false);
    final user = authProvider.user;

    Future.wait([
      for (var status in DeliveryStatus.values)
        deliveryProvider.fetchOrders(context, user.token, status),
    ]);

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification?.title == 'Ada Pesanan Siap Diantar') {
        _handleNewDeliveryNotification(deliveryProvider, user);
      }
    });
  }

  void _handleNewDeliveryNotification(
      DeliveryProvider deliveryProvider, UserModel user) {
    // Debounce to prevent frequent fetches (e.g., within 5 seconds)
    if (_lastFetch == null ||
        DateTime.now().difference(_lastFetch!).inSeconds > 5) {
      if (mounted) {
        deliveryProvider.fetchOrders(
            context, user.token, DeliveryStatus.siapDiantar);
        _lastFetch = DateTime.now();
      }
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
            onTap: (index) {
              final status = DeliveryStatus.values[index];
              deliveryProvider.fetchOrders(context, user.token, status);
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
          physics: const NeverScrollableScrollPhysics(),
          children: DeliveryStatus.values.map((status) {
            final pesanan = deliveryProvider.getPesananByStatus(status);
            if (deliveryProvider.isLoading) {
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
              return _buildEmptyState(status, user, deliveryProvider);
            }
            return DeliveryList(
              status: status,
              onRefresh: () =>
                  deliveryProvider.fetchOrders(context, user.token, status),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildEmptyState(DeliveryStatus status, UserModel user,
      DeliveryProvider deliveryProvider) {
    return RefreshIndicator(
      backgroundColor: AppColors.backgroundColor,
      color: AppColors.primaryColor,
      onRefresh: () =>
          deliveryProvider.fetchOrders(context, user.token, status),
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
                'Pengantaran kosong',
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
