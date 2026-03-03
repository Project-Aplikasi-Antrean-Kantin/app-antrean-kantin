import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/add_more_items_button.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page/widgets/tenant_cart_section.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';

class DetailPesanan extends StatelessWidget {
  const DetailPesanan({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        spacing: 12,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Consumer<CartProvider>(builder: (context, cartProvider, _) {
            return ListView.separated(
              separatorBuilder: (context, index) => DashedDivider(
                color: AppColors.blackColor100,
                height: 2,
              ),
              itemCount: cartProvider.selectedCartTenant.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final tenantCart = cartProvider.selectedCartTenant[index];
                final menuList = tenantCart.cartMenuList ?? [];

                return TenantCartSection(
                  tenant: tenantCart,
                  menuList: menuList,
                  cartProvider: cartProvider,
                  index: index,
                );
              },
            );
          }),
          DashedDivider(
            color: AppColors.blackColor100,
            height: 2,
          ),
          AddMoreItemsButton(),
        ],
      ),
    );
  }
}
