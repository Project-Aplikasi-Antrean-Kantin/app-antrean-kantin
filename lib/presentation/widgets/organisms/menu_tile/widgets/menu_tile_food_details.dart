import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class MenuTileFoodDetails extends StatelessWidget {
  final TenantFoods food;

  const MenuTileFoodDetails({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          FormatCurrency.intToStringCurrency(food.harga),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.textColorBlack,
          ),
        ),
        Text(
          capitalizeFirstLetter(food.nama),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textColorBlack,
          ),
        ),
        const SizedBox(height: 5),
      ],
    );
  }
}
