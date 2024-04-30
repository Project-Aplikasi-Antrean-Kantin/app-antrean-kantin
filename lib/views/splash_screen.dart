import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/common/token_manager.dart';
import 'package:testgetdata/components/custom_snackbar.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/login.dart';
import 'package:testgetdata/views/tenant.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final tokenManager = TokenManager();
  late AuthProvider authProvider =
      Provider.of<AuthProvider>(context, listen: false);

  Future authCheck() async {
    log("MASUK AUTH");
    final token =
        await tokenManager.getToken(); // Ambil token dari Shared Preferences
    if (token != null) {
      log("TOKEN ONOK");
      final success = await authProvider.authWithToken(errorCallback: (error) {
        CustomSnackBar(
          message: error.toString(),
          status: error.toString(),
        );
      });
      if (success) {
        log("SUKSES BOLO");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ));
      } else {
        log("GAISOK COKK");
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      }
    } else {
      log("NuLL COKK");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginPage(),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    authCheck();
    return Scaffold(
      backgroundColor: const Color(0xF8F8F8F8),
      body: Center(
        child: Column(
          children: [
            Image(
              width: MediaQuery.of(context).size.width,
              image: const AssetImage('assets/images/Frame 1.png'),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(
              strokeWidth: 3,
            )
          ],
        ),
      ),
    );
  }
}
