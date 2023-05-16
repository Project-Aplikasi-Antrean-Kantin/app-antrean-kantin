import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/views/login.dart';
import 'package:testgetdata/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MasBro',
        theme: ThemeData(
          fontFamily: GoogleFonts.poppins().fontFamily,
        ),
        home: Login(),
      ),
    );
  }
}