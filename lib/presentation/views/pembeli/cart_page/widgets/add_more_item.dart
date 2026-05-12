import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant/menu_tenant.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class AddMoreItem extends StatelessWidget {
  final CartPerTenant tenant;
  const AddMoreItem({super.key, required this.tenant});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Mau tambah",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.blackColor,
              ),
            ),
            Text(
              "Pesanan?",
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.blackColor,
                fontWeight: regular,
              ),
            ),
          ],
        ),
        PrimaryButton(
          borderRadius: 16,
          elevation: 0,
          color: AppColors.primaryColor,
          borderColor: AppColors.primaryColor,
          width: 128,
          height: 50,
          onPressed: () {
            Navigator.push(
                context,
                CustomPageBuilder(
                    page: MenuTenant(
                        url:
                            '${MasbroConstants.url}/tenants/${tenant.tenantId.toString()}')));
          },
          child: Text(
            'Tambah',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: AppColors.textColorwhite,
              fontWeight: semibold,
            ),
          ),
        ),
      ],
    );
  }
}
