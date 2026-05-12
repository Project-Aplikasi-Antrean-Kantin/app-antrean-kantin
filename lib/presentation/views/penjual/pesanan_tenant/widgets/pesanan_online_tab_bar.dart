import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/presentation/views/penjual/order_status.dart';

class PesananOnlineTabBar extends StatelessWidget {
  final TabController controller;
  final ValueChanged<int> onTap;

  const PesananOnlineTabBar({
    Key? key,
    required this.controller,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TabBar(
      controller: controller,
      onTap: onTap,
      overlayColor: WidgetStateProperty.all(Colors.transparent),
      indicatorColor: AppColors.primaryColor,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
      ),
      labelColor: AppColors.primaryColor,
      labelStyle: GoogleFonts.poppins(fontSize: 14, fontWeight: medium),
      tabs: OrderStatus.values
          .map((status) => Tab(
                key: Key(status.name),
                child: Text(
                  status.label,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ))
          .toList(),
    );
  }
}
