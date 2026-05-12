import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class DetailFoodFab extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;
  final CartMenuModel? cartItem;
  final int count;
  final int? indexCart;
  final String catatan;

  const DetailFoodFab({
    Key? key,
    required this.food,
    required this.tenant,
    required this.cartItem,
    required this.count,
    required this.indexCart,
    required this.catatan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        // Kondisi 1: hapus pesanan
        if (count == 0 && cartItem != null) {
          return _DeleteFab(
            onPressed: () async {
              await cartProvider.clearItemFromCart(
                tenant.id.toString(),
                indexCart!,
              );
              if (context.mounted) Navigator.pop(context);
            },
          );
        }

        // Kondisi 2: count 0, bukan edit → sembunyikan
        if (count == 0) return const SizedBox.shrink();

        // Kondisi 3: tambah / edit pesanan
        return _SaveFab(
          food: food,
          tenant: tenant,
          cartItem: cartItem,
          count: count,
          indexCart: indexCart,
          catatan: catatan,
          cartProvider: cartProvider,
        );
      },
    );
  }
}

class _DeleteFab extends StatelessWidget {
  final VoidCallback onPressed;
  const _DeleteFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 32,
      child: FloatingActionButton.extended(
        onPressed: onPressed,
        backgroundColor: AppColors.errorColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Text(
            'Hapus Pesanan',
            style: GoogleFonts.poppins(
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

class _SaveFab extends StatelessWidget {
  final TenantFoods food;
  final TenantModel tenant;
  final CartMenuModel? cartItem;
  final int count;
  final int? indexCart;
  final String catatan;
  final CartProvider cartProvider;

  const _SaveFab({
    required this.food,
    required this.tenant,
    required this.cartItem,
    required this.count,
    required this.indexCart,
    required this.catatan,
    required this.cartProvider,
  });

  CartMenuModel get _newCartItem => CartMenuModel(
        tenantId: tenant.id.toString(),
        kategoriId: food.kategoriId,
        isReady: food.isReady,
        menuId: food.id,
        menuGambar: food.gambar,
        menuNama: food.nama,
        menuPrice: food.harga,
        count: count,
        catatan: catatan,
      );

  void _onSave(BuildContext context) {
    if (cartItem != null && indexCart != null) {
      cartProvider.editCartModelToCart(
        cartItem: _newCartItem,
        context: context,
        tenantId: tenant.id.toString(),
        index: indexCart ?? 0,
      );
    } else {
      cartProvider.addCartModelToCart(
        cartItem: _newCartItem,
        tenant: tenant,
        tenantId: tenant.id.toString(),
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = food.harga * count;

    return SizedBox(
      width: MediaQuery.of(context).size.width - 40,
      child: FloatingActionButton.extended(
        onPressed: () => _onSave(context),
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        label: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            spacing: 2,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width / 2,
                ),
                child: Text(
                  cartItem != null ? 'Edit Pesanan' : 'Tambah Pesanan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(' - ',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
              Text(
                FormatCurrency.intToStringCoin(totalPrice),
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
