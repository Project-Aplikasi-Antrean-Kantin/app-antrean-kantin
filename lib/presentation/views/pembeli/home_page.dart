import 'dart:async';
import 'dart:convert';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/coin_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/provider/review_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/provider/topup_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/views/pembeli/kode_va_page.dart';
import 'package:testgetdata/presentation/views/pembeli/koin_info_page.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/pembeli/topup_page.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_review.dart';
import 'package:testgetdata/presentation/widgets/card_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/list_tenant.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/widgets/shimmer_card.dart';
import 'package:testgetdata/presentation/widgets/shimmer_widget.dart';
import 'package:testgetdata/presentation/widgets/tenant_button.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  late Future<List<TenantModel>> futureTenant;
  final String url = "${MasbroConstants.url}/tenants";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];
  TenantModel? yourTenant;
  bool isBusyNotInterruptYet = false;
  bool isFirstLoad = true;
  DateTime? _lastFetch;
  Timer? _debounce;
  bool isSearching = false;
  final ScrollController _scrollController = ScrollController();
  bool isScrolledEnough = false;
  late double expandedHeight;
  bool showBottomSheet = false;
  bool isLoadingTenant = true;

  StreamSubscription<RemoteMessage>? _onMessageSubscription;

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

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      // Aplikasi kembali ke foreground
      await RetryFetch(false);
      final prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      final tenantSibuk = prefs.getString("tenant_sibuk");
      if (tenantSibuk != null) {
        RetryFetch(true);
      }
    }
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

  Future<void> RetryFetch(bool fetchTenant) async {
    final internetConnection = await hasInternetAccess();

    if (!internetConnection) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);

    final user = authProvider.user;
    authProvider.fetchUserData(user.token);
    cartProvider.getAllCarts();
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    if (prefs.getString('tenant_sibuk') != null) {
      setState(() {
        isBusyNotInterruptYet = true;
      });
    }
    if (fetchTenant)
      setState(() {
        futureTenant =
            PublicRemoteDataSource().getTenant(context, url, user.token);
        isFirstLoad = true; // optional, biar fullTenant di-refresh juga
      });

    await topUpProvider.setTopUp();
    if (topUpProvider.topUp != null) {
      final kodeBayar = topUpProvider.topUp!.kodeBayar;
      if (kodeBayar.contains('https:')) {
        await topUpProvider.getTopUpQris(
            user.token, topUpProvider.topUp!.midtransId!);
      } else {
        await topUpProvider.getVirtualAccount(user.token, kodeBayar);
      }
    }
    coinProvider.getCoinAmount(user.token);
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final coinProvider = Provider.of<CoinProvider>(context, listen: false);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final topUpProvider = Provider.of<TopupProvider>(context, listen: false);
    final reviewProvider = Provider.of<ReviewProvider>(context, listen: false);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);
    final tenantProvider = Provider.of<TenantProvider>(context, listen: false);

    final user = authProvider.user;
    _scrollController.addListener(_scrollListener);

    authProvider.fetchUserData(user.token);
    cartProvider.getAllCarts();
    reviewProvider.setReviewSelection(user.token).then((_) {
      PublicRemoteDataSource().isNeededReview(user.token).then((bool value) {
        if (value) {
          showBottomSheetReview(context: context, user: user);
        }
      });
    });
    futureTenant = PublicRemoteDataSource()
        .getTenant(context, url, user.token)
        .then((listTenant) {
      final yourTenant = listTenant
          .firstWhereOrNull((tenant) => tenant.emailPemilik == user.email);
      tenantProvider.setListTenant(listTenant);
      if (yourTenant != null) {
        kasirProvider.setTenant(yourTenant);
      }
      return listTenant;
    });
    final prefs = SharedPreferences.getInstance().then((prefs) {
      prefs.reload();
      if (prefs.getString('tenant_sibuk') != null) {
        setState(() {
          isBusyNotInterruptYet = true;
        });
      }
    });

    /// Langkah penting:
    /// 1. setTopUp() dari SharedPreferences
    /// 2. Kalau berhasil dan ada kodeBayar, panggil getVirtualAccount()
    topUpProvider.setTopUp().then((_) async {
      if (topUpProvider.topUp != null) {
        final kodeBayar = topUpProvider.topUp!.kodeBayar;
        await topUpProvider.getVirtualAccount(user.token, kodeBayar);
      }
      coinProvider.getCoinAmount(user.token);
    });

    /// Handle notifikasi
    _onMessageSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.data['title']?.toString().toLowerCase();
      if (title == 'refund berhasil') {
        _handleCoinByNotification(coinProvider, user);
      }
      if (title == 'top-up berhasil' || title!.contains('cashback berhasil')) {
        _handleCoinByNotification(coinProvider, user);
      }
      if (title == 'tenant sibuk') {
        RetryFetch(true);
      }
      if (title!.contains('tidak')) {
        RetryFetch(true);
      }
    });
  }

  void _scrollListener() {
    final scrollOffset = _scrollController.offset;
    if (scrollOffset > expandedHeight - 60 && !isScrolledEnough) {
      setState(() => isScrolledEnough = true);
    } else if (scrollOffset <= expandedHeight - 60 && isScrolledEnough) {
      setState(() => isScrolledEnough = false);
    }
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
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
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
    expandedHeight = MediaQuery.of(context).size.height / 3.5;
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (!user.permission.contains('read beranda')) {
      return const Center(child: Text('TIDAK ADA AKSES WOY'));
    }

    return RefreshIndicator(
      onRefresh: () => RetryFetch(true),
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          floatingActionButton: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // == FAB TAMBAHAN UNTUK ROLE TENANT ==

                  // == FAB KERANJANG YANG SUDAH ADA ==
                  Semantics(
                    label: 'Keranjang',
                    button: true,
                    child: InkWell(
                      key: const Key('cartButton'),
                      onTap: () {
                        if (fullTenant.isNotEmpty) {
                          showBottomSheetCart(
                            context,
                            fullTenant,
                            cartProvider.tenantCarts,
                            false,
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Data tenant belum dimuat'),
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: HugeIcon(
                          icon: Iconsax.bag,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                  if (user.role.contains('tenant'))
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            CustomPageBuilder(
                              page: NavbarHome(
                                pageIndex: user.menu.indexWhere(
                                    (element) => element.url == '/pesanan'),
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: HugeIcon(
                            icon: Iconsax.receipt_add, // iconsax receipt add
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          backgroundColor: AppColors.backgroundColor,
          body: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SizedBox(
                      height: 96,
                    ),
                    Image.asset(
                      'assets/images/beranda_banner6.png',
                      fit: BoxFit.cover,
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 1,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        spacing: 8,
                        children: [
                          Expanded(
                            flex: 60,
                            child: Semantics(
                              label: 'Riwayat Saldo',
                              button: true,
                              child: Material(
                                key: const Key('riwayatSaldoButton'),
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors
                                      .transparent, // hilangkan efek ripple
                                  onTap: () async {
                                    final internetConnection =
                                        await hasInternetAccess();
                                    if (!internetConnection) {
                                      Fluttertoast.showToast(
                                          msg: "Tidak ada koneksi internet");
                                      return;
                                    }
                                    Navigator.push(
                                        context,
                                        CustomPageBuilder(
                                            page: const KoinInfoPage()));
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(16)),
                                    padding: const EdgeInsets.all(16),
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Image.asset(
                                              'assets/images/icon-koin-blue.png',
                                              height: 32),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'FoodLAB Koin',
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      AppColors.textColorBlack,
                                                ),
                                              ),
                                              Text(
                                                FormatCurrency
                                                    .intToStringCurrency(
                                                  coinProvider.saldoKoin,
                                                ),
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primaryColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: const SizedBox(
                              height: 52,
                              child: VerticalDivider(
                                color: Color(0xFFCDCDCD),
                                thickness: 1,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: Semantics(
                              label: 'TopUp',
                              button: true,
                              child: Material(
                                key: const Key('topUpButton'),
                                color: Colors.transparent,
                                child: InkWell(
                                  splashColor: Colors
                                      .transparent, // hilangkan efek ripple
                                  // behavior: HitTestBehavior
                                  //     .opaque, // ✅ area tap jadi selebar parent-nya

                                  onTap: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final jsonCurrentVa =
                                        prefs.getString('current_va');
                                    TopUpModel? currentVa;
                                    final internetConnection =
                                        await hasInternetAccess();
                                    if (!internetConnection) {
                                      Fluttertoast.showToast(
                                          msg: "Tidak ada koneksi internet");
                                      return;
                                    }
                                    if (jsonCurrentVa != null) {
                                      final decoded = jsonDecode(
                                          jsonCurrentVa); // ini Map<String, dynamic>
                                      final kodeBayar =
                                          decoded['kode_bayar'] as String;
                                      if (kodeBayar.contains('https:')) {
                                        currentVa =
                                            TopUpModel.fromJsonQris(decoded);
                                      } else {
                                        currentVa = TopUpModel.fromJson(
                                            decoded); // ini TopUpModel
                                      }
                                    }

                                    if (jsonCurrentVa != null &&
                                        jsonCurrentVa.isNotEmpty &&
                                        currentVa != null) {
                                      _handleNavigation(KodeVaPage(
                                        currentVa: currentVa,
                                      ));
                                    } else {
                                      _handleNavigation(
                                          TopupPage(email: user.email));
                                    }
                                  },
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        Image.asset(
                                          'assets/images/icon-koin-plus-blue.png',
                                          height: 32,
                                        ),
                                        Text(
                                          'Isi Koin',
                                          style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    FutureBuilder<List<TenantModel>>(
                      future: futureTenant,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                                ConnectionState.waiting ||
                            isSearching) {
                          return Skeletonizer(
                            child: ListView.builder(
                              shrinkWrap: true, // ✅ biar ukurannya sesuai isi
                              physics:
                                  NeverScrollableScrollPhysics(), // ✅ biar gak scroll dobel
                              padding: EdgeInsets.zero,
                              itemCount: 7,
                              itemBuilder: (context, index) {
                                return CardTenant(
                                  tenant: TenantModel(
                                    id: 1,
                                    namaTenant: 'Bakso Pak Budi',
                                    namaKavling: 'Kavling A1',
                                    transaksiBerhasil: 120,
                                    gambar:
                                        'https://example.com/images/bakso.jpg',
                                    userId: 10,
                                    createdAt: DateTime.now(),
                                    updatedAt: DateTime.now(),
                                  ),
                                  email: 'ezra',
                                );
                              },
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                              child: Column(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image(
                                  height: 216,
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
                            ],
                          ));
                        }
                        if (isFirstLoad) {
                          fullTenant = snapshot.data ?? [];
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (mounted) {
                              setState(() {
                                yourTenant = fullTenant.firstWhereOrNull(
                                  (tenant) => tenant.emailPemilik == user.email,
                                );
                              });
                              setState(() {
                                isLoadingTenant = false;
                              });
                            }
                          });

                          fullTenant.sort((a, b) {
                            return (b.transaksiBerhasil ?? 0)
                                .compareTo(a.transaksiBerhasil ?? 0);
                          });

                          foundTenant = fullTenant;
                          isFirstLoad = false;
                        }

                        return foundTenant.isEmpty
                            ? Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 16),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Image(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                2,
                                        image: const AssetImage(
                                            "assets/images/404-Not-Found.png"),
                                      ),
                                      Text(
                                          'Yah menu yang kamu cari masih belum tersedia nih :(',
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              color: AppColors.blackColor400))
                                    ],
                                  ),
                                ),
                              )
                            : ListTenant(
                                url: url,
                                fullTenant: fullTenant,
                                foundTenant: foundTenant,
                                onNavigate: _handleNavigation,
                              );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.only(
                    top: 40,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  color: isScrolledEnough
                      ? Colors.white.withOpacity(1)
                      : Colors.white.withOpacity(0.0),
                  child: Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Skeletonizer(
                          enabled: isLoadingTenant,
                          child: SearchWidget(
                            key: const Key('searchHome'),
                            paddingHorizontal: 0,
                            paddingVertical: 0,
                            tittle: "Lagi pengen makan apa?",
                            onChanged: filterTenantsDebounced,
                          ),
                        ),
                      ),
                      if (user.role.contains('tenant'))
                        Skeletonizer(
                          enabled: isLoadingTenant,
                          child: TenantButton(
                            isBusyNotInterruptYet: isBusyNotInterruptYet,
                            onRefresh: () => RetryFetch(true),
                            yourTenant: yourTenant,
                            isScrolledEnough: isScrolledEnough,
                            user: user,
                          ),
                        ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
