import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';

// Inline counter khusus kasir/owner: [ - | n | + ]
class MenuTileCounter extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;

  const MenuTileCounter({Key? key, required this.food, required this.tenant})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentCart =
        cartProvider.cart.firstWhere((cart) => cart.menuId == food.id);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primaryColor, width: 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CounterButton(
            label: '-',
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
            onTap: () => cartProvider.removeItemFromTenantCart(
              catatan: currentCart.catatan,
              tenant.id.toString(),
              currentCart.menuId,
              context,
            ),
          ),
          _CounterField(food: food, tenant: tenant),
          _CounterButton(
            label: '+',
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            onTap: () => cartProvider.addItemToCart(
              catatan: currentCart.catatan,
              tenantId: tenant.id.toString(),
              cart: currentCart,
            ),
          ),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final String label;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  const _CounterButton({
    required this.label,
    required this.borderRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 32,
        decoration: BoxDecoration(borderRadius: borderRadius),
        child: Center(
          child: Text(label,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteColor,
              )),
        ),
      ),
    );
  }
}

class _CounterField extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;

  const _CounterField({required this.food, required this.tenant});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentCart =
        cartProvider.cart.firstWhere((cart) => cart.menuId == food.id);

    return Container(
      width: 28,
      height: 32,
      alignment: Alignment.center,
      child: TextFormField(
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        key: ValueKey(currentCart.count),
        initialValue: currentCart.count.toString(),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
        style: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.whiteColor,
        ),
        onChanged: (value) {
          final intCount = int.tryParse(value);
          if (intCount != null && intCount >= 0) {
            cartProvider.updateItemCount(
              tenantId: tenant.id.toString(),
              menuId: currentCart.menuId,
              count: intCount,
            );
          }
        },
      ),
    );
  }
}
