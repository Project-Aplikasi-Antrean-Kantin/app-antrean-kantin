import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class MenuCartBottomSheet extends StatelessWidget {
  final TenantFoods food;

  const MenuCartBottomSheet({Key? key, required this.food}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItemsByMenuId =
            cartProvider.cart.where((item) => item.menuId == food.id).toList();

        final totalPrice = cartItemsByMenuId.fold<int>(
          0,
          (sum, item) => sum + (item.menuPrice * item.count),
        );

        // auto close kalau cart kosong
        if (cartItemsByMenuId.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (Navigator.of(context).canPop()) Navigator.pop(context);
          });
          return const SizedBox.shrink();
        }

        return SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  spacing: 16,
                  children: [
                    _buildHandle(),
                    _buildHeader(food.nama, totalPrice),
                    DashedDivider(height: 2, color: AppColors.blackColor100),
                    Expanded(
                      child: _buildCartList(
                          context, cartProvider, cartItemsByMenuId),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: _buildAddMoreButton(context, cartProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.blackColor300,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _buildHeader(String nama, int totalPrice) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          flex: 2,
          child: Text(
            capitalizeFirstLetter(nama),
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: AppColors.blackColor,
            ),
          ),
        ),
        Flexible(
          child: Text(
            FormatCurrency.intToStringCurrency(totalPrice),
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCartList(
    BuildContext context,
    CartProvider cartProvider,
    List<CartMenuModel> items,
  ) {
    return ListView.separated(
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemCount: items.length + 1, // +1 untuk spacing bawah
      itemBuilder: (context, index) {
        if (index == items.length) return const SizedBox(height: 36);
        return _CartItemRow(food: food, cartItem: items[index]);
      },
    );
  }

  Widget _buildAddMoreButton(BuildContext context, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        CustomPageBuilder(
          page: DetailFoodPage(
            addNewItem: true,
            food: food,
            tenant: cartProvider.currentTenant!,
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            'Tambah Lagi',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Cart Item Row ───────────────────────────────────────────────
class _CartItemRow extends StatelessWidget {
  final TenantFoods food;
  final CartMenuModel cartItem;

  const _CartItemRow({required this.food, required this.cartItem});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        _buildImage(),
        _buildInfo(context),
        _buildCountAndPrice(),
      ],
    );
  }

  Widget _buildImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ImageByUrl(
        key: Key(
            '${cartItem.menuId}-${cartItem.menuGambar}-${cartItem.catatan}'),
        url: cartItem.menuGambar,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return SizedBox(
      width: MediaQuery.of(context).size.width / 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            capitalizeFirstLetter(cartItem.menuNama),
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          Text(
            cartItem.catatan != null && cartItem.catatan!.isNotEmpty
                ? cartItem.catatan!
                : 'Catatan Kosong',
            style: TextStyle(color: AppColors.blackColor200, fontSize: 12),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              CustomPageBuilder(
                page: DetailFoodPage(
                  cartItem: cartItem,
                  addNewItem: true,
                  catatan: cartItem.catatan,
                  food: food,
                  tenant: cartProvider.currentTenant!,
                ),
              ),
            ),
            child: Text(
              'Edit',
              style: TextStyle(color: AppColors.primaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountAndPrice() {
    return Expanded(
      child: Column(
        spacing: 8,
        children: [
          Text(
            FormatCurrency.intToStringCurrency(
                cartItem.count * cartItem.menuPrice),
            style: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              color: AppColors.primaryColor,
            ),
            child: Text(
              '${cartItem.count}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
