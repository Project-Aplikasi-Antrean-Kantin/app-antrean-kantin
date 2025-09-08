import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/history_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_riwayat.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';

class OrderSuccess extends StatelessWidget {
  final Pesanan pesanan;
  const OrderSuccess({super.key, required this.pesanan});

  Route HomePageUser() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => const NavbarHome(
        pageIndex: 0,
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

  // Routing ke NavbarHome
  Route HistoryPage(UserModel user, HistoryProvider historyProvider) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => NavbarHome(
        pageIndex: user.menu.indexWhere((element) => element.url == '/riwayat'),
        initialRouteAfterOpen: DetailRiwayat(
          label: "Beli",
          token: user.token.toString(),
          pesanan: pesanan,
          refreshData: () {
            historyProvider.fetchHistory(context, user, "user", true);
          },
        ),
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
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
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    HistoryProvider historyProvider = Provider.of<HistoryProvider>(context);

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Mengarahkan user kembali ke beranda
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const NavbarHome(
              pageIndex: 0,
            ),
          ),
          (route) => false,
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Selamat! Pesanan Anda berhasil dibuat🎉',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Image.asset(
                            'assets/images/sukses-order-pict.png',
                            width: 400,
                            height: 400,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              HomePageUser(),
                              (route) => false,
                              // (route) => route.isFirst,
                            );
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                                AppColors.primaryColor),
                          ),
                          child: Text(
                            'Kembali ke Halaman Utama',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pushAndRemoveUntil(
                              context,
                              HistoryPage(user, historyProvider),
                              (route) => false,
                            );
                          },
                          child: Center(
                            child: Text(
                              'Lihat Riwayat Pesanan',
                              style: GoogleFonts.poppins(
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
