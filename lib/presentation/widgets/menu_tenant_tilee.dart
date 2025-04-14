import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';
import 'package:shimmer/shimmer.dart';

class MenuItemTile extends StatefulWidget {
  final TenantFoods food;
  final String tenantName;

  const MenuItemTile({
    Key? key,
    required this.food,
    required this.tenantName,
  }) : super(key: key);

  @override
  _MenuItemTileState createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 0.3,
            color: AppColors.lineColorBlack.withOpacity(0.5),
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildFoodImage(context),
          _buildFoodDetails(),
          _buildCartActions(context),
        ],
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context) {
    return Container(
      height: 105,
      width: 105,
      margin: const EdgeInsets.only(right: 15),
      child: GestureDetector(
        onTap: () {
          showDetailMenuBottomSheet(
            context,
            DetailMenu(
              namaTenant: widget.tenantName,
              dataFoods: widget.food,
            ),
            isCashier: false,
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Positioned.fill(
                child: Visibility(
                  visible: _isLoading,
                  child: Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(color: Colors.white),
                  ),
                ),
              ),
              Image.network(
                "${MasbroConstants.baseUrl}${widget.food.gambar}",
                fit: BoxFit.cover,
                width: 105,
                height: 105,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    });
                    return child;
                  }
                  return Container();
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.broken_image, color: Colors.grey),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFoodDetails() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.only(top: 5),
        height: 100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.food.nama,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 16,
                fontWeight: bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.food.deskripsi ?? '-',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontSize: 12,
                fontWeight: regular,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              FormatCurrency.intToStringCurrency(widget.food.harga),
              style: GoogleFonts.poppins(
                fontWeight: semibold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartActions(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Consumer<CartProvider>(
        builder: (context, cartProvider, _) {
          final cartItemIndex = cartProvider.cart
              .indexWhere((item) => item.menuId == widget.food.id);

          if (cartItemIndex == -1) {
            return _buildAddToCartButton(context, cartProvider);
          } else {
            return _buildCartQuantityControls(
                context, cartProvider, cartItemIndex);
          }
        },
      ),
    );
  }

  Widget _buildAddToCartButton(
      BuildContext context, CartProvider cartProvider) {
    return GestureDetector(
      onTap: () {
        if (widget.food.isReady == 1) {
          final imageUrl = widget.food.gambar ?? 'Kosong';
          log("name: ${widget.food.nama}, gambar: $imageUrl, tenantName: ${widget.tenantName}");
          cartProvider.addItemToCartOrUpdateQuantity(
            widget.food.id,
            widget.food.nama,
            widget.food.harga,
            imageUrl,
            widget.tenantName,
            widget.food.deskripsi ?? '-',
            true,
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.only(top: 70),
        width: 75,
        height: 30,
        decoration: BoxDecoration(
          color: widget.food.isReady == 1
              ? AppColors.primaryColor
              : AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: widget.food.isReady == 1
                ? AppColors.primaryColor
                : AppColors.textColorwhite,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            widget.food.isReady == 1 ? 'Tambah' : 'Habis',
            style: GoogleFonts.poppins(
              color: widget.food.isReady == 1
                  ? AppColors.textColorwhite
                  : Colors.grey,
              fontSize: 12,
              fontWeight: semibold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartQuantityControls(
      BuildContext context, CartProvider cartProvider, int cartItemIndex) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                cartProvider.addItemToCartOrUpdateQuantity(
                  widget.food.id,
                  widget.food.nama,
                  widget.food.harga,
                  widget.food.gambar ?? '-',
                  widget.food.deskripsi ?? '-',
                  widget.tenantName,
                  false,
                );
              },
              icon: Icon(
                Icons.do_not_disturb_on_outlined,
                color: AppColors.primaryColor,
                size: 26,
              ),
            ),
            Text(
              cartProvider.cart[cartItemIndex].count.toString(),
              style: const TextStyle(fontSize: 16),
            ),
            IconButton(
              onPressed: () {
                cartProvider.addItemToCartOrUpdateQuantity(
                  widget.food.id,
                  widget.food.nama,
                  widget.food.harga,
                  widget.food.gambar ?? '-',
                  widget.food.deskripsi ?? '-',
                  widget.tenantName,
                  true,
                );
              },
              icon: Icon(
                Icons.add_circle_outline,
                color: AppColors.primaryColor,
                size: 26,
              ),
            ),
          ],
        ),
        _buildNoteButton(context, cartProvider, cartItemIndex),
      ],
    );
  }

  Widget _buildNoteButton(
      BuildContext context, CartProvider cartProvider, int cartItemIndex) {
    return GestureDetector(
      onTap: () {
        final note = cartProvider.cart
            .firstWhere((item) => item.menuId == widget.food.id)
            .catatan;
        bottomSheetCatatan(context, note ?? '', 'Tambah catatan untuk pesanan')
            .then((value) {
          if (value != null) {
            cartProvider.addNote(widget.food.id, value);
          }
        });
      },
      child: Container(
        width: 75,
        height: 25,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey, width: 1.5),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 12),
            Text(
              'Catatan',
              style: TextStyle(color: Colors.black, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
