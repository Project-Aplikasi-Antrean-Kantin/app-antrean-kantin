import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/user_provider.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/login.dart';
import 'package:testgetdata/views/masbro.dart';
import 'package:testgetdata/views/splash_screen.dart';
import 'package:testgetdata/views/tenant/home.dart';
import 'package:testgetdata/views/tenant/menu.dart';
import 'package:testgetdata/views/tenant/tambah_menu.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MasBro',
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: Consumer<UserProvider>(
          builder: (context, provider, child) {
            return FutureBuilder<String>(
              future: provider.token,
              builder: (context, snapshot) {
                return Menu();
                // if (snapshot.hasData) {
                //   print(snapshot.data!);
                //   if (snapshot.data!.isEmpty)
                //     return Login();
                //   else if (snapshot.data! == 'Dosen') {
                //     return HomePage();
                //   } else {
                //     // massbro
                //     return Masbro();
                //   }
                // } else {
                //   // halaman masbro
                //   return Login();
                // }
              },
            );
          },
        ),
      ),
    );
  }
}
