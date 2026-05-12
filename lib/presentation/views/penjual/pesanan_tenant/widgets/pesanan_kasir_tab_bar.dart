import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';

class PesananKasirTabBar extends StatelessWidget {
  final TabController controller;
  const PesananKasirTabBar({Key? key, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicatorColor: AppColors.primaryColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      labelColor: AppColors.primaryColor,
      labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: medium),
      tabs: const [
        Tab(child: Text('Pending')),
        Tab(child: Text('Diproses')),
      ],
    );
  }
}
