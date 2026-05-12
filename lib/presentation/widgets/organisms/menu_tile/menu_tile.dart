import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_bottom_sheet.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_food_details.dart';
import 'package:testgetdata/presentation/widgets/organisms/menu_tile/widgets/menu_tile_image.dart';

class MenuTile extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;
  final int cartItemCount;
  final bool isOwner; // widget.tenant.emailPemilik == authProvider.user.email

  const MenuTile({
    Key? key,
    required this.food,
    required this.tenant,
    required this.cartItemCount,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => _onTap(context, cartProvider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MenuTileImage(
              food: food,
              tenant: tenant,
              cartItemCount: cartItemCount,
              isOwner: isOwner,
            ),
            MenuTileFoodDetails(food: food),
          ],
        ),
      ),
    );
  }

  void _showMenuCartBottomSheet(BuildContext context, TenantFoods food) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.whiteColor400,
      builder: (_) => MenuCartBottomSheet(food: food),
    );
  }

  void _onTap(BuildContext context, CartProvider cartProvider) {
    if (food.isReady == 0) {
      Fluttertoast.showToast(
        msg: "Menu belum tersedia",
        backgroundColor: AppColors.errorColor,
        textColor: AppColors.whiteColor,
      );
      cartProvider.clearItemByMenuIdFromCart(
        tenant.id.toString(),
        food.id,
      );
      return;
    }

    if (cartItemCount > 0) {
      _showMenuCartBottomSheet(context, food);
    } else {
      Navigator.push(
          context,
          CustomPageBuilder(
            page: DetailFoodPage(addNewItem: true, food: food, tenant: tenant),
          ));
    }
  }
}
