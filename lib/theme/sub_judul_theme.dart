import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class SubJudul extends TextStyle {
  SubJudul({Color? warna})
      : super(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    fontFamily: GoogleFonts.poppins().fontFamily,
    color: warna ?? Colors.black,
  );
}