import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFF06144C);
  static const Color secondaryColor = Color(0xFFF79009);
  // static const Color backgroundColor = Color(0xFFFF5E5E);
  static const Color backgroundColor = Color(0xffFCFCFC);
  static const Color unselectedIconColor = Color(0xFF808191);
  static const Color selectedIconColor = Color(0xFF14487A);
  static const Color lineDividerColor = Color(0xFFB3B3B3);
  static const Color debugColor = Color.fromARGB(255, 246, 38, 38);
  static const Color lineColorBlack = Color(0xFF323232);
  static const Color containerColorGrey = Color.fromARGB(255, 177, 178, 179);
  static const Color containerColorSemiBlack = Color(0xff686A6A);
  static const Color containerColorWhite = Color(0xffFFFFFF);
  static const Color containerColorGrey200 = Color(0xFFE5E7EB);

  // static const Color textColorBlack = Color(0xff303030);
  static const Color textColorBlack = Color(0xFF323232);
  static const Color textColorwhite = Color(0xFFFFFFFF);
  static const Color textColorGrey700 = Color(0xFF374151);
  static const Color textColorGrey500 = Color(0xFF9E9E9E);
}

Color getStatusColor(String status) {
  switch (status) {
    case 'pesanan_masuk':
      return Colors.green;
    case 'pesanan_ditolak':
      return Colors.red;
    case 'pesanan_diproses':
      return Color(0xFFFFCA28);
    case 'siap_diantar':
      return Colors.blue;
    case 'pending':
      return Colors.orange;
    case 'selesai':
      return Colors.purple;
    default:
      return Colors.black;
  }
}
