import 'dart:async';

import 'package:app_settings/app_settings.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/fitur_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
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
  StreamSubscription<RemoteMessage>? _onMessageSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentIndex = widget.pageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.loadUnreadMessages();
      final user = Provider.of<AuthProvider>(context, listen: false).user;

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
        }
      });
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!mounted) return; // ⬅️ Tambah ini

    if (state == AppLifecycleState.resumed) {
      final historyProvider =
          Provider.of<HistoryProvider>(context, listen: false);
      historyProvider.loadUnreadMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    List<FiturModel> listFitur = authProvider.user.menu;

    // Halaman yang baru dipilih bukan halaman kasir, maka bersihkan keranjang belanja
    void clearCartIfRequired(int newIndex) {
      KasirProvider kasirProvider =
          Provider.of<KasirProvider>(context, listen: false);
      FiturModel selectedFeature = listFitur[newIndex];
      if (selectedFeature.nama.toLowerCase() == "kasir") {
        return;
      }
      kasirProvider.clearCart();
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
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (context) => CustomAlertDialog(
            title: 'Konfirmasi Keluar',
            message: 'Apakah Anda yakin ingin keluar aplikasi?',
            showCancelButton: true,
            onOkPressed: () {
              Navigator.of(context).pop(true); // User memilih keluar
            },
            onCancelPressed: () {
              Navigator.of(context).pop(false); // User batal
            },
          ),
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
