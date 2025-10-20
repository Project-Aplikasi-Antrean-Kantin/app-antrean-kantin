import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/token_manager.dart';
import 'package:testgetdata/presentation/widgets/custom_snackbar.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
import 'package:testgetdata/presentation/widgets/no_connection_bottom_sheet.dart';
import 'package:testgetdata/utils/has_internet_access.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
import 'package:collection/collection.dart';

// import 'package:testgetdata/views/tenant.dart';

class SplashScreen extends StatefulWidget {
  final bool? isFromNotification;
  const SplashScreen({Key? key, this.isFromNotification}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with WidgetsBindingObserver {
  final tokenManager = TokenManager();

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    internetChecking();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Aplikasi kembali dari background
      log("APP RESUMED");
      // Jalankan ulang pengecekan
      authCheck();
    }
  }

  Future<void> internetChecking() async {
    final internetCheck = await hasInternetAccess();
    if (!internetCheck) {
      showNoConnectionBottomSheet(
        context: context,
        onRetry: () {
          Navigator.pop(context);
          internetChecking();
        },
      );
      return;
    }
    startSplashScreen();
  }

  Future<void> startSplashScreen() async {
    await Future.delayed(const Duration(seconds: 2));
    authCheck();
  }

  Future authCheck() async {
    debugPrint("MASUK TOKEN AUTH");

    final token = await tokenManager.getToken();
    final role = await tokenManager.getRoles();
    log("role user: $role");

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final version = await authProvider.getCurrentVersion();

    final maintenance = authProvider.settings
        .firstWhereOrNull((element) => element.nama == 'maintenance')
        ?.nilai;

    if (version != MasbroConstants.version) {
      _showExitConfirmationDialog(context, "Pembaruan aplikasi tersedia!",
          "Segera lakukan pembaruan untuk mengakses fitur terbaru", "Update");
      return;
    }
    if (maintenance != null && maintenance == '1') {
      _showExitConfirmationDialog(context, "Aplikasi sedang dalam perbaikan!",
          "Mohon maaf atas ketidaknyamanan dan tunggu beberapa saat", "Keluar");
      return;
    }

    if (token != null) {
      debugPrint("TOKEN TERSEDIA");
      final result = await authProvider.authWithToken(
        errorCallback: (error) {
          CustomSnackBar(message: error.toString(), status: error.toString());
        },
      );
      print("result: $result");
      if (!mounted) return;

      if (result.success) {
        log("Sukses Masuk, Token Tersedia");
        if (widget.isFromNotification == true) {
          if (result.user!.role.length == 1) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (_) => NavbarHome(
                      pageIndex: result.user!.menu
                          .indexWhere((element) => element.url == '/riwayat'))),
            );
          } else if (result.user!.role.contains('masbro')) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NavbarHome(
                        pageIndex: result.user!.menu.indexWhere(
                            (element) => element.url == '/pengantaran'))));
          } else if (result.user!.role.contains('tenant')) {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (_) => NavbarHome(
                        pageIndex: result.user!.menu.indexWhere(
                            (element) => element.url == '/pesanan'))));
          }
          return;
        }
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => NavbarHome(pageIndex: 0),
          ),
        );
      } else {
        log("Token Tidak Tersedia");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    } else {
      log("Token Null");
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              width: 300,
              height: 300,
              image:
                  const AssetImage('assets/images/splash_screen_foodlab.png'),
              fit: BoxFit.cover, // Gunakan BoxFit.cover untuk efek cover
            ),
            Text('Version ${MasbroConstants.version}')
          ],
        ),
      ),
    );
  }

  Future<void> _showExitConfirmationDialog(BuildContext context, String title,
      String description, String buttonText) async {
    return showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Container(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (buttonText == "Update")
                    TextButton(
                      onPressed: () {
                        // Keluar dari aplikasi
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else {
                          Navigator.of(context).pop(); // iOS disarankan kembali
                        }
                      },
                      style: ButtonStyle(
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            side: const BorderSide(color: Colors.grey),
                          ),
                        ),
                        minimumSize:
                            WidgetStateProperty.all(const Size(100, 30)),
                      ),
                      child: const Text(
                        "Keluar",
                        style:
                            TextStyle(color: Color.fromARGB(255, 99, 99, 99)),
                      ),
                    ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      if (buttonText == "Keluar") {
                        // Keluar dari aplikasi
                        if (Platform.isAndroid) {
                          SystemNavigator.pop();
                        } else {
                          Navigator.of(context).pop(); // iOS disarankan kembali
                        }
                      }
                      const url =
                          'https://play.google.com/store/apps/details?id=com.foodlab.pens';
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(
                          Uri.parse(url),
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        // Jika gagal membuka Play Store
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Gagal membuka Play Store'),
                          ),
                        );
                      }
                    },
                    style: ButtonStyle(
                      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      backgroundColor: WidgetStateProperty.all(
                        AppColors.primaryColor,
                      ),
                      minimumSize: WidgetStateProperty.all(const Size(100, 30)),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: AppColors.backgroundColor,
  //     body: Center(
  //       child: Image(
  //         width: MediaQuery.of(context).size.width,
  //         image: const AssetImage('assets/images/splash_screen_foodlab.png'),
  //       ),
  //     ),
  //   );
  // }
}
