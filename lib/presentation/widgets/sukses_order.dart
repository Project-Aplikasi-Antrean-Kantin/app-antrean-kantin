import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home.dart';

class OrderSuccess extends StatelessWidget {
  const OrderSuccess({super.key});

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

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
        body: Center(
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const NavbarHome(
                                pageIndex: 0,
                              ),
                            ),
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
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => NavbarHome(
                                pageIndex: user.menu.indexWhere(
                                    (element) => element.url == '/riwayat'),
                              ),
                            ),
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
    );
  }
}
