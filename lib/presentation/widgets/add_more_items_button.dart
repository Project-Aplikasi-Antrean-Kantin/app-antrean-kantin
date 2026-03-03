import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/menu_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/primary_button.dart';

class AddMoreItemsButton extends StatelessWidget {
  const AddMoreItemsButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Consumer2<CartProvider, TenantProvider>(
        builder: (context, cartProvider, tenantProvider, _) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartProvider.selectedCartTenant.length == 2
                      ? "Multitenant mencapai"
                      : "Mau tambah dari",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: cartProvider.selectedCartTenant.length == 2
                        ? AppColors.warningColor
                        : AppColors.blackColor,
                  ),
                ),
                Text(
                  cartProvider.selectedCartTenant.length == 2
                      ? "batas maksimal"
                      : "tenant lain?",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: cartProvider.selectedCartTenant.length == 2
                        ? AppColors.warningColor
                        : AppColors.blackColor,
                    fontWeight: regular,
                  ),
                ),
              ],
            ),
            PrimaryButton(
              key: Key('addMoreItemsButton'),
              waitingText: "Mencapai Maksimal",
              isEnabled: cartProvider.selectedCartTenant.length < 2,
              borderRadius: 16,
              elevation: 0,
              color: AppColors.primaryColor800,
              borderColor: AppColors.primaryColor,
              width: 128,
              height: 50,
              onPressed: () {
                showBottomSheetCart(context, tenantProvider.tenants!,
                    cartProvider.tenantCarts, true);
              },
              child: Text(
                'Tenant Lain',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textColorwhite,
                  fontWeight: semibold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
