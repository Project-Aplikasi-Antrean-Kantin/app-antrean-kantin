import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';

import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/add_more_item.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/list_cart_per_tenant.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class TenantCartSection extends StatelessWidget {
  final CartPerTenant tenant;
  final List<CartMenuModel> menuList;
  final CartProvider cartProvider;
  final int index;
  const TenantCartSection(
      {super.key,
      required this.tenant,
      required this.menuList,
      required this.cartProvider,
      required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          // 🏪 Nama Tenant
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                tenant.tenantName,
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              GestureDetector(
                onTap: () =>
                    cartProvider.removeSelectedCartTenantByIndex(index),
                child: Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.errorColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    spacing: 4,
                    children: [
                      Icon(Iconsax.trash,
                          size: 16, color: AppColors.whiteColor),
                      Text(
                        'Hapus',
                        style: GoogleFonts.poppins(
                            color: AppColors.whiteColor, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // 🍔 Daftar Menu Tenant Ini
          ListCartPerTenant(cartProvider: cartProvider, menuList: menuList),

          // 💰 Subtotal
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal: ${menuList.length} Menu',
                style: GoogleFonts.poppins(color: AppColors.primaryColor),
              ),
              Text(
                FormatCurrency.intToStringCurrency(menuList.fold(
                  0,
                  (prev, item) => prev + (item.count * item.menuPrice),
                )),
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          DashedDivider(
              height: 1, dashWidth: 4, color: AppColors.blackColor100),
          AddMoreItem(tenant: tenant)
        ],
      ),
    );
  }
}
