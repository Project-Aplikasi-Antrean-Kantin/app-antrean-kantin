import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/views/pembeli/navbar_home/navbar_home.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class FabHome extends StatelessWidget {
  final List<TenantModel> fullTenant;
  const FabHome({super.key, required this.fullTenant});

  @override
  Widget build(BuildContext context) {
    return Consumer2<CartProvider, AuthProvider>(
        builder: (context, cartProvider, authProvider, child) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            identifier: 'cartButton',
            button: true,
            child: InkWell(
              key: const Key('cartButton'),
              onTap: () {
                if (fullTenant.isNotEmpty) {
                  showBottomSheetCart(
                    context,
                    fullTenant,
                    cartProvider.tenantCarts,
                    false,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Data tenant belum dimuat'),
                    ),
                  );
                }
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: HugeIcon(
                  icon: Iconsax.bag,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          if (authProvider.user.role.contains('tenant'))
            Padding(
              padding: const EdgeInsets.only(top: 12.0),
              child: InkWell(
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    CustomPageBuilder(
                      page: NavbarHome(
                        pageIndex: authProvider.user.menu
                            .indexWhere((element) => element.url == '/pesanan'),
                      ),
                    ),
                    (route) => false,
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: HugeIcon(
                    icon: Iconsax.receipt_add, // iconsax receipt add
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}
