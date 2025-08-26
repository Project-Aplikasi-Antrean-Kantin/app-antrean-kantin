import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor100 = Color(0xFFCCDCF1);
  static const Color primaryColor200 = Color(0xFFAAC5E8);
  static const Color primaryColor300 = Color(0xFF80A8DD);
  static const Color primaryColor400 = Color(0xFF568CD2);
  static const Color primaryColor = Color(0xFF0152BB); //500
  static const Color primaryColor600 = Color(0xFF01377D);
  static const Color primaryColor700 = Color(0xFF01295E);
  static const Color primaryColor800 = Color(0xFF001B3E);
  static const Color primaryColor900 = Color(0xFF001025);

  static const Color secondaryColor100 = Color(0xFFFFF8D1);
  static const Color secondaryColor200 = Color(0xFFFFF3B3);
  static const Color secondaryColor300 = Color(0xFFFFED8D);
  static const Color secondaryColor400 = Color(0xFFFFE767);
  static const Color secondaryColor = Color(0xFFFFDB1B);
  static const Color secondaryColor600 = Color(0xFFAA9212);
  static const Color secondaryColor700 = Color(0xFF806E0E);
  static const Color secondaryColor800 = Color(0xFF554909);
  static const Color secondaryColor900 = Color(0xFF332C05);

  static const Color whiteColor100 = Color(0xFFFDFDFD);
  static const Color whiteColor200 = Color(0xFFFCFCFC);
  static const Color whiteColor300 = Color(0xFFFAFAFA);
  static const Color whiteColor400 = Color(0xFFF8F8F8);
  static const Color whiteColor = Color(0xFFF5F5F5);
  static const Color whiteColor600 = Color(0xFFA3A3A3);
  static const Color whiteColor700 = Color(0xFF7B7B7B);
  static const Color whiteColor800 = Color(0xFF525252);
  static const Color whiteColor900 = Color(0xFF313131);

  static const Color blackColor100 = Color(0xFFCDCDCD);
  static const Color blackColor200 = Color(0xFFACACAC);
  static const Color blackColor300 = Color(0xFF828282);
  static const Color blackColor400 = Color(0xFF585858);
  static const Color blackColor = Color(0xFF050505);
  static const Color blackColor600 = Color(0xFF030303);
  static const Color blackColor700 = Color(0xFF030303);
  static const Color blackColor800 = Color(0xFF020202);
  static const Color blackColor900 = Color(0xFF010101);

  static const Color successColor100 = Color(0xFFD0F1E1);
  static const Color successColor200 = Color(0xFFB0E7CD);
  static const Color successColor300 = Color(0xFF88DBB4);
  static const Color successColor400 = Color(0xFF61CF9C);
  static const Color successColor = Color(0xFF12B76A);
  static const Color successColor600 = Color(0xFF0C7A47);
  static const Color successColor700 = Color(0xFF095C35);
  static const Color successColor800 = Color(0xFF063D23);
  static const Color successColor900 = Color(0xFF042515);

  static const Color warningColor100 = Color(0xFFFDE9CE);
  static const Color warningColor200 = Color(0xFFFCDAAD);
  static const Color warningColor300 = Color(0xFFFBC784);
  static const Color warningColor400 = Color(0xFFFAB55B);
  static const Color warningColor = Color(0xFFF79009);
  static const Color warningColor600 = Color(0xFFA56006);
  static const Color warningColor700 = Color(0xFF7C4805);
  static const Color warningColor800 = Color(0xFF523003);
  static const Color warningColor900 = Color(0xFF311D02);

  static const Color errorColor100 = Color(0xFFFCDAD7);
  static const Color errorColor200 = Color(0xFFFAC1BD);
  static const Color errorColor300 = Color(0xFFF7A19B);
  static const Color errorColor400 = Color(0xFFF5827A);
  static const Color errorColor = Color(0xFFF04438);
  static const Color errorColor600 = Color(0xFFA02D25);
  static const Color errorColor700 = Color(0xFF78221C);
  static const Color errorColor800 = Color(0xFF501713);
  static const Color errorColor900 = Color(0xFF300E0B);

  static const Color infoColor100 = Color(0xFFD7EAFC);
  static const Color infoColor200 = Color(0xFFBCDCFA);
  static const Color infoColor300 = Color(0xFF9BCBF7);
  static const Color infoColor400 = Color(0xFF7AB9F5);
  static const Color infoColor = Color(0xFF3897F0);
  static const Color infoColor600 = Color(0xFF2564A0);
  static const Color infoColor700 = Color(0xFF1C4B78);
  static const Color infoColor800 = Color(0xFF123250);
  static const Color infoColor900 = Color(0xFF0B1E30);

  static const Color backgroundColor = Color(0xFFF5F5F5);
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
