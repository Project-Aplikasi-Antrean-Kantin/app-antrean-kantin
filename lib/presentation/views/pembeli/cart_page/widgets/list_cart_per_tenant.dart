import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/tenant_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/organisms/item_cart/item_cart.dart';

class ListCartPerTenant extends StatelessWidget {
  final CartProvider cartProvider;
  final List<CartMenuModel> menuList;

  const ListCartPerTenant(
      {super.key, required this.cartProvider, required this.menuList});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: menuList.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final tenantProvider =
            Provider.of<TenantProvider>(context, listen: false);
        final item = menuList[i];
        final tenant = tenantProvider.getTenantById(int.parse(item.tenantId));
        if (tenant == null) {
          return Container();
        }
        return ItemCart(
          item: item,
          onEdit: () {
            Navigator.push(
              context,
              CustomPageBuilder(
                page: DetailFoodPage(
                  cartItem: item,
                  addNewItem: false,
                  catatan: item.catatan,
                  tenant: tenant,
                ),
              ),
            );
          },
          onIncrement: () {
            cartProvider.addItemToCart(
              catatan: item.catatan,
              tenantId: item.tenantId,
              cart: item,
            );
          },
          onDecrement: () {
            cartProvider.removeItemFromTenantCart(
              catatan: item.catatan,
              item.tenantId,
              item.menuId,
              context,
            );
          },
          onCountChanged: (count) {
            cartProvider.updateItemCount(
              tenantId: item.tenantId,
              menuId: item.menuId,
              count: count,
            );
          },
        );
      },
    );
  }
}
