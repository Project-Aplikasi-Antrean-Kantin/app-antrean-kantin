import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/fitur_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_review.dart';
import 'package:testgetdata/presentation/widgets/custom_alert_new.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';
import 'package:testgetdata/presentation/widgets/switch_route.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class NavbarHome extends StatefulWidget {
  final int pageIndex;
  final Widget? initialRouteAfterOpen;
  const NavbarHome(
      {Key? key, required this.pageIndex, this.initialRouteAfterOpen})
      : super(key: key);

  @override
  State<NavbarHome> createState() => _NavbarHomeState();
}

class _NavbarHomeState extends State<NavbarHome> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool showBottomSheet = false;
  bool showPopUpBusy = false;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.pageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      final prefs = SharedPreferences.getInstance().then((prefs) {
        final tenantSibuk = prefs.getString("tenant_sibuk");
        if (tenantSibuk != null) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: AppColors.primaryColor100.withOpacity(0.5),
            builder: (context) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                backgroundColor: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(20)),
                  child: Column(
                    spacing: 8,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tenant Sibuk',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warningColor,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: HugeIcon(
                                  size: 24,
                                  icon: HugeIcons.strokeRoundedCancelCircle,
                                  color:
                                      AppColors.warningColor.withOpacity(0.5)),
                            )
                          ]),
                      Text(
                        'Tenant sedang sibuk, tekan siap untuk mengubah status menjadi buka kembali dalam 3 menit.',
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: PrimaryButton(
                            height: 32,
                            borderRadius: 16,
                            color: AppColors.warningColor,
                            child: Text("Siap",
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                )),
                            width: 96,
                            onPressed: () async {
                              final statusTenant =
                                  await TenantRemoteDataSource()
                                      .updateBusy(user.token);
                              if (statusTenant) {
                                prefs.remove("tenant_sibuk");

                                Fluttertoast.showToast(
                                    msg:
                                        "Dalam 3 menit status tenantmu akan menjadi Buka",
                                    backgroundColor: AppColors.successColor,
                                    textColor: Colors.white);
                              }
                              Navigator.of(context).pop();
                            }),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        }
      });
      historyProvider.loadUnreadMessages();

      if (widget.initialRouteAfterOpen != null) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            Navigator.of(context).push(
              CustomPageBuilder(page: widget.initialRouteAfterOpen!),
            );
          }
        });
      }
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        print("User clicked notif while app in BACKGROUND");
        final title = message.data['title']?.toString().toLowerCase();

        if (title != null && title.contains('Chat Baru')) {
          if (user.role.length == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => NavbarHome(
                      pageIndex: user.menu
                          .indexWhere((element) => element.url == '/riwayat'))),
            );
          } else if (user.role.contains('masbro')) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NavbarHome(
                        pageIndex: user.menu.indexWhere(
                            (element) => element.url == '/pengantaran'))));
          } else if (user.role.contains('tenant')) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NavbarHome(
                        pageIndex: user.menu.indexWhere(
                            (element) => element.url == '/pesanan'))));
          }
        }
      });

      _onMessageSubscription =
          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final title = message.data['title']?.toString().toLowerCase();
        print('title: $title');
        if (title != null && title.contains('chat baru')) {
          final transaksiId =
              int.parse(message.notification!.title!.split(' ').last);

          historyProvider.saveUnreadMessages(transaksiId).then((_) {
            historyProvider.loadUnreadMessages();
          });
        }
        if (title != null && title.contains('pesanan selesai')) {
          final transaksiId =
              int.parse(message.notification!.body!.split(' ')[1]);

          historyProvider.removeAvailableChat(transaksiId);
          historyProvider.removeUnreadMessages(transaksiId).then((_) {
            historyProvider.loadUnreadMessages();
          });
          PublicRemoteDataSource()
              .isNeededReview(user.token)
              .then((bool value) {
            if (value) {
              showBottomSheetReview(context: context, user: user);
            }
            ;
          });
        }
        if (title != null && title.contains('top-up berhasil')) {
          final prefs = SharedPreferences.getInstance().then((prefs) {
            if (prefs.getString('current_va') != null)
              prefs.remove('current_va');
          });
        }
        if (title != null && title.contains('tidak sibuk')) {
          final prefs = SharedPreferences.getInstance().then((prefs) {
            if (prefs.getString('tenant_sibuk') != null)
              prefs.remove('tenant_sibuk');
          });
        }
        if (title != null && title.contains('tenant sibuk')) {
          final prefs = SharedPreferences.getInstance().then((prefs) {
            prefs.setString('tenant_sibuk', 'true');

            setState(() {
              showPopUpBusy = true;
            });

            // ⬇️ langsung munculkan dialog
            showDialog(
              context: context,
              barrierDismissible: true,
              barrierColor: AppColors.primaryColor100.withOpacity(0.5),
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppColors.whiteColor,
                        borderRadius: BorderRadius.circular(20)),
                    child: Column(
                      spacing: 8,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Tenant Sibuk',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.warningColor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: HugeIcon(
                                    size: 24,
                                    icon: HugeIcons.strokeRoundedCancelCircle,
                                    color: AppColors.warningColor
                                        .withOpacity(0.5)),
                              )
                            ]),
                        Text(
                          'Tenant sedang sibuk, tekan siap untuk mengubah statu menjadi buka kembali dalam 3 menit.',
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: PrimaryButton(
                              height: 32,
                              borderRadius: 16,
                              color: AppColors.warningColor,
                              child: Text("Siap",
                                  style: GoogleFonts.poppins(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  )),
                              width: 96,
                              onPressed: () async {
                                final statusTenant =
                                    await TenantRemoteDataSource()
                                        .updateBusy(user.token);
                                if (statusTenant) {
                                  prefs.remove("tenant_sibuk");

                                  Fluttertoast.showToast(
                                      msg:
                                          "Dalam 3 menit status tenantmu akan menjadi Buka",
                                      backgroundColor: AppColors.successColor,
                                      textColor: Colors.white);
                                }
                                Navigator.of(context).pop();
                              }),
                        )
                      ],
                    ),
                  ),
                );
              },
            );
          });
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return; // ⬅️ Tambah ini

    if (state == AppLifecycleState.resumed) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.loadUnreadMessages();
      final user = Provider.of<AuthProvider>(context, listen: false).user;

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload(); // ⬅️ wajib ditunggu
      final tenantSibuk = prefs.getString("tenant_sibuk");
      final needReview = prefs.getBool("user_review");
      print("needReview: $needReview");
      if (tenantSibuk != null) {
        if (!mounted) return;
        showDialog(
          context: context,
          barrierDismissible: true,
          barrierColor: AppColors.primaryColor100.withOpacity(0.5),
          builder: (context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(20)),
                child: Column(
                  spacing: 8,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tenant Sibuk',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.warningColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: HugeIcon(
                                size: 24,
                                icon: HugeIcons.strokeRoundedCancelCircle,
                                color: AppColors.warningColor.withOpacity(0.5)),
                          )
                        ]),
                    Text(
                      'Tenant sedang sibuk, tekan siap untuk mengubah statu menjadi buka kembali dalam 3 menit.',
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: PrimaryButton(
                          height: 32,
                          borderRadius: 16,
                          color: AppColors.warningColor,
                          child: Text("Siap",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              )),
                          width: 96,
                          onPressed: () async {
                            final statusTenant = await TenantRemoteDataSource()
                                .updateBusy(user.token);
                            if (statusTenant) {
                              prefs.remove("tenant_sibuk");

                              Fluttertoast.showToast(
                                  msg:
                                      "Dalam 3 menit status tenantmu akan menjadi Buka",
                                  backgroundColor: AppColors.successColor,
                                  textColor: Colors.white);
                            }
                            Navigator.of(context).pop();
                          }),
                    )
                  ],
                ),
              ),
            );
          },
        );
      }
      if (needReview != null && needReview) {
        PublicRemoteDataSource().isNeededReview(user.token).then((bool value) {
          if (value) {
            showBottomSheetReview(context: context, user: user);
          }
          ;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);

    List<FiturModel> listFitur = [
      ...authProvider.user.menu
    ]; // copy dulu biar ga rusak state asli

    // Halaman yang baru dipilih bukan halaman kasir, maka bersihkan keranjang belanja
    void clearCartIfRequired(int newIndex) {
      FiturModel selectedFeature = listFitur[newIndex];
      if (selectedFeature.nama.toLowerCase() == "kasir") {
        return;
      }
    }

    String kapitalHurufDepan(String text) {
      if (text.isEmpty) return text;
      return text.split(' ').map((word) {
        if (word.isEmpty) return word;
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      }).join(' ');
    }

    Widget _buildNotificationBadge() {
      return Positioned(
        top: 0,
        right: 8,
        child: Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryColor,
          ),
        ),
      );
    }

    List<BottomNavigationBarItem> _buildBottomNavigationBarItems(
        List<FiturModel> listFitur, BuildContext context) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: true);
      return listFitur.map((e) {
        return BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SvgPicture.network(
                  e.ikon!,
                  height: 24,
                  colorFilter: ColorFilter.mode(
                    AppColors.blackColor300,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              if (historyProvider.unreadMessagesList.isNotEmpty &&
                  e.nama.toLowerCase().trim() == 'riwayat' &&
                  authProvider.user.role.length == 1)
                _buildNotificationBadge(),
              // if (historyProvider.unreadMessagesList.isNotEmpty &&
              //     e.nama.toLowerCase().trim() == 'pengantaran' &&
              //     authProvider.user.role.contains('masbro') &&
              //     authProvider.user.role.length == 2)
              //   _buildNotificationBadge(),
              if (historyProvider.unreadMessagesList.isNotEmpty &&
                  e.nama.toLowerCase().trim() == 'pesanan' &&
                  authProvider.user.role.contains('tenant') &&
                  authProvider.user.role.length == 2)
                _buildNotificationBadge(),
            ],
          ),
          activeIcon: Stack(clipBehavior: Clip.none, children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SvgPicture.network(
                e.ikon!,
                height: 24,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor,
                  BlendMode.srcIn,
                ),
              ),
            ),
            if (historyProvider.unreadMessagesList.isNotEmpty &&
                e.nama.toLowerCase().trim() == 'riwayat' &&
                authProvider.user.role.length == 1)
              _buildNotificationBadge(),
            // if (historyProvider.unreadMessagesList.isNotEmpty &&
            //     e.nama.toLowerCase().trim() == 'pengantaran' &&
            //     authProvider.user.role.contains('masbro') &&
            //     authProvider.user.role.length == 2)
            //   _buildNotificationBadge(),
            if (historyProvider.unreadMessagesList.isNotEmpty &&
                e.nama.toLowerCase().trim() == 'pesanan' &&
                authProvider.user.role.contains('tenant') &&
                authProvider.user.role.length == 2)
              _buildNotificationBadge(),
          ]),
          label: kapitalHurufDepan(e.nama),
        );
      }).toList();
    }

    Widget _buildPage(FiturModel fitur) {
      return FeaturePage(
        url: fitur.url!,
        authProvider: authProvider,
      );
    }

    return WillPopScope(
      onWillPop: () async {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.height < 600;
        final shouldExit = await showModalBottomSheet<bool>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          enableDrag: false,
          builder: (_) {
            return SafeArea(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxHeight: screenSize.height * 0.8,
                    ),
                    padding: EdgeInsets.all(screenSize.width * 0.05),
                    decoration: const BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(
                                vertical: screenSize.height * 0.01),
                            child: Image.asset(
                              'assets/images/confirmation-exit.png',
                              width: screenSize.width * 0.5,
                              height: screenSize.width * 0.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.02),
                          Text(
                            "Keluar Aplikasi",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: isSmallScreen ? 16 : 20,
                              color: AppColors.textColorBlack,
                            ),
                          ),
                          SizedBox(height: screenSize.height * 0.015),
                          Text(
                            "Yakin mau keluar aplikasi?",
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              fontSize: isSmallScreen ? 12 : 14,
                              color: AppColors.textColorBlack,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenSize.height * 0.03),
                          Row(
                            children: [
                              Expanded(
                                child: PrimaryButton(
                                  borderColor: AppColors.primaryColor,
                                  borderRadius: 20,
                                  height: screenSize.height * 0.06,
                                  elevation: 0,
                                  color: AppColors.containerColorWhite,
                                  child: Text(
                                    "Batal",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: AppColors.primaryColor,
                                    ),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                  },
                                ),
                              ),
                              SizedBox(width: screenSize.width * 0.03),
                              Expanded(
                                child: PrimaryButton(
                                  elevation: 0,
                                  color: AppColors.primaryColor,
                                  height: screenSize.height * 0.06,
                                  borderRadius: 20,
                                  child: Text(
                                    "Keluar",
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: isSmallScreen ? 12 : 14,
                                      color: AppColors.textColorwhite,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(true); // User memilih keluar
                                    ;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -50,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.close,
                          color: AppColors.textColorBlack,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );

        return shouldExit ?? false;
      },
      child: Scaffold(
        body: _buildPage(listFitur[_currentIndex]),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 0.2,
              color: Colors.grey,
            ),
            // BottomNavigationBar(
            //   backgroundColor: AppColors.backgroundColor,
            //   type: BottomNavigationBarType.fixed,
            //   elevation: 0,
            //   selectedFontSize: 12,
            //   selectedLabelStyle: GoogleFonts.poppins(
            //     fontSize: 9,
            //   ),
            //   unselectedLabelStyle: GoogleFonts.poppins(
            //     fontSize: 9,
            //   ),
            //   unselectedFontSize: 12,
            //   unselectedItemColor: AppColors.unselectedIconColor,
            //   selectedItemColor: AppColors.selectedIconColor,
            //   currentIndex: _currentIndex,
            //   showUnselectedLabels: true,
            //   onTap: (index) {
            //     // Panggil fungsi clearCartIfRequired saat pengguna mengubah halaman
            //     clearCartIfRequired(index);
            //     setState(() {
            //       _currentIndex = index;
            //     });
            //   },
            //   items: _buildBottomNavigationBarItems(listFitur),
            // ),
            Theme(
              data: Theme.of(context).copyWith(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
              ),
              child: BottomNavigationBar(
                backgroundColor: AppColors.backgroundColor,
                type: BottomNavigationBarType.fixed,
                elevation: 0,
                selectedFontSize: 10,
                selectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
                unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
                unselectedFontSize: 10,
                unselectedItemColor: AppColors.blackColor400,
                selectedItemColor: AppColors.primaryColor,
                currentIndex: _currentIndex,
                showUnselectedLabels: true,
                onTap: (index) async {
                  clearCartIfRequired(index);
                  setState(() {
                    _currentIndex = index;
                  });

                  // Tambahkan pengecekan koneksi setelah pindah tab
                  await Future.delayed(Duration(
                      milliseconds:
                          100)); // kasih delay kecil biar context ready
                  if (mounted) {
                    final result = await hasInternetAccess();
                    if (!result) {
                      showNoConnectionBottomSheet(
                        context: context,
                        onRetry: () {
                          // optional: implement retry logic
                        },
                      );
                    }
                  }
                },
                items: _buildBottomNavigationBarItems(listFitur, context),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class FeaturePage extends StatefulWidget {
  final String url;
  final AuthProvider authProvider;

  const FeaturePage({Key? key, required this.url, required this.authProvider})
      : super(key: key);

  @override
  State<FeaturePage> createState() => _FeaturePageState();
}

class _FeaturePageState extends State<FeaturePage> with WidgetsBindingObserver {
  bool showBottomSheet = false;
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Aplikasi kembali ke foreground
      _checkInternetConnection();
    }
  }

  void _checkInternetConnection() async {
    final result = await hasInternetAccess();
    print('Status koneksi: ${result ? 'ada koneksi' : 'tidak ada koneksi'}');

    if (!result) {
      showNoConnectionBottomSheet(
          context: context,
          onRetry: () {
            _checkInternetConnection();
          });
      showBottomSheet = true;
    } else {
      if (showBottomSheet && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
        showBottomSheet = false;
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return getFeaturePage(widget.url);
  }
}
