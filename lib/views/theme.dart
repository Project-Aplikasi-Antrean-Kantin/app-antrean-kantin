import 'package:flutter/material.dart';

Color primaryColor = const Color(0xffFF5E5E);

Color backgroundColor = const Color(0xffFFF8F8);

// buat text keseluruhan
Color primaryextColor = const Color(0xff303030);
// buat judul
Color secondaryTextColor = const Color(0xff2B2B2B);

Color unselectedIconColor = const Color(0xFF808191);
Color selectedIconColor = const Color(0xFFFF5E5E);

FontWeight light = FontWeight.w300;
FontWeight regular = FontWeight.w400;
FontWeight medium = FontWeight.w500;
FontWeight semibold = FontWeight.w600;
FontWeight bold = FontWeight.w700;

String capitalizeFirstLetter(String input) {
  if (input.isEmpty) return input;
  return input.split(' ').map((word) {
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
