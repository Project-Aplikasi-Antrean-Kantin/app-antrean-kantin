import 'package:flutter/material.dart';

class AppColors {
  // static const Color primaryColor = Color(0xffFF5E5E);
  static const Color primaryColor = Color(0xFF14487A);
  static const Color backgroundColor = Color(0xffFCFCFC);
  // static const Color backgroundColor = Color(0xffF8F8FF);
  static const Color primaryTextColor = Color(0xff303030);
  static const Color secondaryTextColor = Color(0xff2B2B2B);
  static const Color unselectedIconColor = Color(0xFF808191);
  // static const Color selectedIconColor = Color(0xFFFF5E5E);
  static const Color selectedIconColor = Color(0xFF14487A);
  static const Color lineDividerColor = Color(0xFFB3B3B3);

  static const Color textColorBlack = Color(0xFF323232);
}

Color getStatusColor(String status) {
  switch (status) {
    case 'pesanan_masuk':
      return Colors.green;
    case 'pesanan_ditolak':
      return Colors.red;
    case 'pesanan_diproses':
      return Colors.yellow;
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
