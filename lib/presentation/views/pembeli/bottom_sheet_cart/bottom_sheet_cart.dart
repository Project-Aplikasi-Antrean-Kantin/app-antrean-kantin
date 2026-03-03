import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/local/cart_local_data_source.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/build_list_cart_per_tenant.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/empty_cart.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/footer_bottom_sheet_cart.dart';
import 'package:testgetdata/presentation/views/pembeli/bottom_sheet_cart/widgets/header_bottom_sheet_cart.dart';

void validateCart(
  Map<String, CartPerTenant> cart,
  List<TenantModel> tenants,
  BuildContext context,
) async {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final tenantMap = {for (var t in tenants) t.id: t};
  final cartLocal = CartLocalDataSource();

  // Simpan daftar tenantId yang akan dihapus (karena perlu async clearCart)
  final List<int> tenantsToClear = [];

  cart.removeWhere((key, tenantCart) {
    final tenantIdStr = key.replaceFirst("cart_", "");
    final tenantId = int.tryParse(tenantIdStr);

    if (tenantId == null) return true; // key cart gak valid

    final tenant = tenantMap[tenantId];
    if (tenant == null) return true; // tenant tidak ada lagi

    // 🔥 Hapus semua menu di tenant ini kalau pemilik tenant = user login
    if (tenant.emailPemilik == authProvider.user.email) {
      tenantsToClear.add(tenantId);
      return true;
    }

    // 🚨 Jika ada menu yang tidak memiliki tenantId, hapus seluruh cart
    final hasInvalidTenantId = tenantCart.cartMenuList?.any(
          (menu) => menu.tenantId == '',
        ) ??
        false;

    if (hasInvalidTenantId) {
      tenantsToClear.add(tenantId);
      return true;
    }

    // Hapus menu yang tidak ada lagi di daftar tenantFoods
    tenantCart.cartMenuList?.removeWhere((menu) {
      final exists =
          (tenant.tenantFoods?.any((f) => f.id == menu.menuId)) ?? false;
      return !exists;
    });

    // Hapus tenantCart kalau kosong setelah filtering
    final shouldRemove = tenantCart.cartMenuList?.isEmpty ?? true;
    if (shouldRemove) {
      tenantsToClear.add(tenantId);
    }
    return shouldRemove;
  });

  // Jalankan clearCart untuk semua tenant yang dihapus
  for (final tenantId in tenantsToClear) {
    await cartLocal.clearCart(tenantId.toString());
  }
}

Future<void> showBottomSheetCart(
    BuildContext context,
    List<TenantModel> tenants,
    Map<String, CartPerTenant> cart,
    bool fromCartPage) {
  validateCart(cart, tenants, context);

  return showModalBottomSheet(
    enableDrag: true,
    backgroundColor: AppColors.backgroundColor,
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
    ),
    builder: (BuildContext context) {
      final screenHeight = MediaQuery.of(context).size.height;

      return SafeArea(
        key: const Key('bottomSheetCart'),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Consumer<CartProvider>(
              builder: (context, cartProvider, _) {
                final isCartBenarBenarKosong = cart.isEmpty ||
                    cart.values.every((tenantCart) =>
                        tenantCart.cartMenuList == null ||
                        tenantCart.cartMenuList!.isEmpty);

                return ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight:
                          screenHeight * 0.6), // BATASI tinggi bottom sheet
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 8),
                      HeaderBottomSheetCart(cartProvider: cartProvider),
                      const SizedBox(height: 8),
                      isCartBenarBenarKosong
                          ? EmptyCart()
                          : BuildListCartPerTenant(
                              fromCartPage: fromCartPage,
                              tenants: tenants,
                              cartProvider: cartProvider),
                      if (!fromCartPage)
                        FooterBottomSheetCart(tenants: tenants),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      );
    },
  );
}
