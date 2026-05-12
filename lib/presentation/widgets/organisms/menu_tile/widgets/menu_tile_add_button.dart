import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';

class MenuTileAddButton extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;
  final bool isOwner;

  const MenuTileAddButton({
    Key? key,
    required this.food,
    required this.tenant,
    required this.isOwner,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return GestureDetector(
      onTap: () {
        if (!isOwner) {
          Navigator.push(
              context,
              CustomPageBuilder(
                page: DetailFoodPage(
                    addNewItem: true, food: food, tenant: tenant),
              ));
          return;
        }
        cartProvider.addItemToCart(
          tenantId: tenant.id.toString(),
          newItem: food,
          tenantName: tenant.namaTenant,
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
