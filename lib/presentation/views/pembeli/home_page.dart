import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/widgets/list_tenant.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TenantModel>> futureTenant;
  final String url = "${MasbroConstants.url}/tenants";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];
  bool isFirstLoad = true;
  DateTime? _lastFetch;
  Timer? _debounce;
  bool isSearching = false;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageTopupSuccessSubscription;

  // Tambahkan variabel untuk overlay
  // final _scrollController = ScrollController();
  // final _containerHeight = 60.0;

  void filterTenantsDebounced(String value) {
    setState(() {
      isSearching = true;
    });

    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      filterTenants(value); // lakukan filter
      setState(() {
        isSearching = false;
      });
    });
  }

  void filterTenants(String value) {
    setState(() {
      if (value.isEmpty) {
        foundTenant = fullTenant;
      } else {
        final lowerKeyword = value.toLowerCase();

        foundTenant = fullTenant.where((tenant) {
          final tenantText = (tenant.namaTenant +
                  tenant.namaKavling +
                  tenant.tenantFoods!.map((food) => food.nama).join(' '))
              .toLowerCase();

          return tenantText.contains(lowerKeyword);
        }).map((tenant) {
          // Buat salinan tenant dengan makanan yang sudah difilter
          final filteredFoods = tenant.tenantFoods!
              .where((food) => food.nama.toLowerCase().contains(lowerKeyword))
              .toList();

          return tenant.copyWith(tenantFoods: filteredFoods);
        }).toList();
      }
    });
  }

  Route topUpPgae(coin, email) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => TopupPage(
        email: email,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset(0.0, 0.0);
        const curve = Curves.easeInOut;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final user = authProvider.user;
    authProvider.fetchUserData(authProvider.user.token);
    futureTenant = PublicRemoteDataSource().getTenant(context, url, user.token);
    coinProvider.getCoinAmount(authProvider.user.token);

    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'refund berhasil') {
        _handleCoinByNotification(coinProvider, user);
      }
    });

    _onMessageTopupSuccessSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'top-up berhasil') {
        _handleCoinByNotification(coinProvider, user);
      }
    });
  }

  void _handleCoinByNotification(CoinProvider coinProvider, UserModel user) {
    // Debounce to prevent frequent fetches (e.g., within 5 seconds)
    if (_lastFetch == null ||
        DateTime.now().difference(_lastFetch!).inSeconds > 5) {
      if (mounted) {
        coinProvider.getCoinAmount(user.token);
        _lastFetch = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    // Cancel Firebase listeners to prevent accessing context after unmount
    _onMessageTopupSuccessSubscription?.cancel();
    _onMessageSubscription?.cancel();
    super.dispose();
  }

  void _handleNavigation(Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0); // Mulai dari kanan
          const end = Offset(0.0, 0.0); // Berakhir di tengah
          const curve = Curves.easeInOut; // Kurva animasi smooth

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration:
            const Duration(milliseconds: 300), // Durasi animasi masuk
        reverseTransitionDuration:
            const Duration(milliseconds: 300), // Durasi animasi keluar
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coinProvider = Provider.of<CoinProvider>(context);
    final double expandedHeight = MediaQuery.of(context).size.height / 4;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (!user.permission.contains('read beranda')) {
      return const Center(child: Text('TIDAK ADA AKSES WOY'));
    }

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ));

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: CustomScrollView(
          // controller: _scrollController, // Tambahkan controller
          slivers: [
            SliverAppBar(
              toolbarHeight: 60,
              backgroundColor: AppColors.backgroundColor,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              pinned: true,
              floating: false,
              expandedHeight: expandedHeight,
              flexibleSpace: Stack(
                children: [
                  Positioned.fill(
                    child: FlexibleSpaceBar(
                      background: Image.asset(
                        'assets/images/beranda_banner3.png',
                        fit: BoxFit
                            .cover, // atau BoxFit.fill, tergantung kebutuhan
                      ),
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 5,
                    left: 15,
                    right: 15,
                    child: SearchWidget(
                      paddingHorizontal: 0,
                      paddingVertical: 0,
                      formHeight: 43,
                      tittle: "Cari menu kesukaanmu . . .",
                      onChanged: filterTenantsDebounced,
                    ),
                  ),
                  Positioned(
                    top: MediaQuery.of(context).padding.top + 5,
                    right: 20,
                    child: InkWell(
                      onTap: () {
                        print('halo');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.shopping_bag_outlined,
                          size: 30,
                          color: Colors.yellow[700],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                margin:
                    const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1), // shadow tipis
                      blurRadius: 2,
                      offset: const Offset(0, 1), // arah dan jarak bayangan
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.toll,
                        size: 20,
                        color: Colors.yellow[700],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Saldo kamu',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: regular,
                            color: AppColors.textColorBlack,
                          ),
                        ),
                        Text(
                          // '$saldoCoin',
                          FormatCurrency.intToStringCoin(
                            coinProvider.saldoKoin,
                          ),
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: semibold,
                            color: AppColors.textColorBlack,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        _handleNavigation(
                          TopupPage(
                            email: user.email,
                          ),
                        );
                        // NotificationHelper.openNotificationSettings();
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 100,
                        height: 35,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundColor,
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.add_box,
                              size: 20,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'Top Up',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: AppColors.primaryColor,
                                fontWeight: bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<TenantModel>>(
              future: futureTenant,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    isSearching) {
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ShimmerCard(
                        pageType: 'tenant',
                      ),
                      childCount: 2,
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return const SliverToBoxAdapter(child: SizedBox());
                }
                fullTenant = snapshot.data ?? [];
                if (isFirstLoad) {
                  foundTenant = fullTenant;
                  // Sort foundTenant: isOnline true comes first, false/null comes last
                  foundTenant.sort((a, b) {
                    // Treat null as false for sorting
                    bool aOnline = a.isOnline ?? false;
                    bool bOnline = b.isOnline ?? false;
                    return aOnline
                        ? -1
                        : bOnline
                            ? 1
                            : 0;
                  });
                  isFirstLoad = false;
                }
                return foundTenant.isEmpty
                    ? const SliverToBoxAdapter(
                        child: ShimmerLoadingWidget(
                          itemHeight: 200,
                          itemCount: 4,
                          showContainerTitle: false,
                          showContainer: false,
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ListTenant(
                            url: url,
                            fullTenant: fullTenant,
                            foundTenant: foundTenant,
                            onNavigate: _handleNavigation,
                          ),
                          childCount: 1,
                        ),
                      );
              },
            ),
          ],
        ),
      ),
    );
  }
}
