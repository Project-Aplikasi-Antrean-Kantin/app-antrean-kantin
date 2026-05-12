import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class DetailFoodInfo extends StatelessWidget {
  final TenantFoods food;

  const DetailFoodInfo({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 16,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width / 1.75,
                child: Text(
                  food.nama,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  FormatCurrency.intToStringCurrency(food.harga),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: AppColors.textColorBlack,
                  ),
                ),
              ),
            ],
          ),
          if (food.deskripsi != null &&
              food.deskripsi.toString().toLowerCase() != 'null')
            Text(
              food.deskripsi.toString(),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
        ],
      ),
    );
  }
}
