import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/delivery_provider.dart';
import 'package:testgetdata/presentation/views/pengantar/delivery_card.dart';
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
      print("title $title");
      print("title.contains('prioritas') ${title?.contains('prioritas')}");
      if (title == 'ada pesanan siap diantar') {
        _handleNewDeliveryNotification(deliveryProvider, user);
      }
      if (title != null && title.contains('prioritas')) {
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
              color: AppColors.primaryColor,
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
                          fontSize: 14,
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
        body: TabBarView(
          // physics: const NeverScrollableScrollPhysics(),
          controller: _tabController,
          children: DeliveryStatus.values.map((status) {
            final pesanan = deliveryProvider.getPesananByStatus(status);
            if (deliveryProvider.isLoading) {
              return Skeletonizer(
                  child: ListView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      itemCount: 3,
                      itemBuilder: (context, index) => DeliveryCard(
                          onSuccess: () {},
                          pesanan: Pesanan.getDummyPesanan(),
                          status: DeliveryStatus.siapDiantar,
                          userToken: "userToken")));
            }
            if (deliveryProvider.errorMessage != null) {
              return RefreshIndicator(
                onRefresh: () => deliveryProvider.fetchOrders(
                  user.token,
                  status,
                ),
                child: Center(
                  child: deliveryProvider.errorMessage!
                              .contains('Failed host lookup') ||
                          deliveryProvider.errorMessage!.contains('Connection')
                      ? Column(
                          spacing: 8,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                              onTap: () {
                                deliveryProvider.fetchOrders(
                                    user.token, status);
                              },
                              child: Container(
                                margin: EdgeInsets.only(top: 16),
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: MediaQuery.of(context).size.width - 48,
                                child: Center(
                                    child: Text('Coba Lagi',
                                        style: GoogleFonts.poppins(
                                          color: AppColors.whiteColor,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ))),
                              ),
                            )
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              deliveryProvider.errorMessage ?? '',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: regular,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                deliveryProvider.fetchOrders(
                                    user.token, status);
                              },
                              child: const Text("Coba Lagi"),
                            ),
                          ],
                        ),
                ),
              );
            }
            if (pesanan.isEmpty) {
              return RefreshIndicator(
                backgroundColor: AppColors.backgroundColor,
                color: AppColors.primaryColor,
                onRefresh: () async =>
                    await deliveryProvider.fetchOrders(user.token, status),
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
