import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/common/token_manager.dart';
import 'package:testgetdata/presentation/widgets/custom_snackbar.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';
import 'package:testgetdata/presentation/views/pembeli/login_page.dart';
// import 'package:testgetdata/views/tenant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenManager = TokenManager();

  @override
  void initState() {
    super.initState();
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

    if (token != null) {
      debugPrint("TOKEN TERSEDIA");
      final success = await authProvider.authWithToken(errorCallback: (error) {
        CustomSnackBar(
          message: error.toString(),
          status: error.toString(),
        );
      });

      if (!mounted) return;

      if (success) {
        log("Sukses Masuk, Token Tersedia");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const NavbarHome(pageIndex: 0),
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
        child: Image(
          width: 300,
          height: 300,
          image: const AssetImage('assets/images/splash_screen_foodlab.png'),
          fit: BoxFit.cover, // Gunakan BoxFit.cover untuk efek cover
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
