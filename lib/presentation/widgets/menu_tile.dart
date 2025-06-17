import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';

class MenuTile extends StatefulWidget {
  final TenantFoods food;
  final String? tenantName;
  final bool isTenantMenu;
  final bool enableNotes;

  const MenuTile({
    Key? key,
    required this.food,
    this.tenantName,
    this.isTenantMenu = false,
    this.enableNotes = true,
  }) : super(key: key);

  @override
  _MenuTileState createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  void _showDetailBottomSheet() {
    showDetailMenuBottomSheet(
      context,
      DetailMenu(
        namaTenant: widget.tenantName ?? '',
        dataFoods: widget.food,
      ),
      isCashier: !widget.isTenantMenu,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showDetailBottomSheet,
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            final cartItemIndex = cartProvider.cart
                .indexWhere((item) => item.menuId == widget.food.id);
            final note = cartItemIndex != -1
                ? cartProvider.cart[cartItemIndex].catatan
                : null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFoodImage(context),
                    Expanded(child: _buildFoodDetails(context)),
                  ],
                ),
                if (note != null && note.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8, left: 5),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Catatan: ',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: semibold,
                              color: AppColors.textColorBlack,
                            ),
                          ),
                          TextSpan(
                            text: note,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: regular,
                              color: AppColors.textColorBlack,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFoodImage(BuildContext context) {
    return Container(
      height: 120,
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color.fromARGB(255, 200, 200, 200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: widget.food.gambar.isNotEmpty
            ? Image.network(
                "${MasbroConstants.baseUrl}${widget.food.gambar}",
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      color: Colors.white,
                      width: 100,
                      height: 100,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.photo,
                    color: Color.fromARGB(255, 120, 120, 120),
                    size: 30,
                  );
                },
              )
            : const Icon(
                Icons.photo,
                color: Color.fromARGB(255, 120, 120, 120),
                size: 30,
              ),
      ),
    );
  }

  Widget _buildFoodDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),
        Text(
          widget.food.nama,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: medium,
            fontSize: 16,
            color: AppColors.textColorBlack,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          widget.food.deskripsi ?? '-',
          // 'makanan enak bergisi besar dan super enak, pokoknya dijamin enak dan super enak',
          style: GoogleFonts.poppins(
            fontWeight: regular,
            fontSize: 12,
            color: AppColors.textColorGrey700,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.left,
        ),
        const SizedBox(height: 5),
        Text(
          FormatCurrency.intToStringCurrency(widget.food.harga),
          style: GoogleFonts.poppins(
            fontWeight: bold,
            fontSize: 14,
            color: AppColors.textColorBlack,
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          child: widget.isTenantMenu
              ? _buildTenantCartActions(context)
              : _buildKasirCartActions(context),
        ),
      ],
    );
  }

  Widget _buildTenantCartActions(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final cartItemIndex = cartProvider.cart
            .indexWhere((item) => item.menuId == widget.food.id);

        if (cartItemIndex == -1) {
          return _buildAddToCartButton(context, cartProvider: cartProvider);
        } else {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.enableNotes)
                _buildNoteButton(context, cartProvider, cartItemIndex),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      cartProvider.addItemToCartOrUpdateQuantity(
                        widget.food.id,
                        widget.food.nama,
                        widget.food.harga,
                        widget.food.gambar ?? '-',
                        widget.tenantName ?? '',
                        widget.food.deskripsi ?? '-',
                        false,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.indeterminate_check_box_outlined,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  ),
                  SizedBox(
                    width: 30,
                    child: Text(
                      cartProvider.cart[cartItemIndex].count.toString(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: medium,
                        color: AppColors.textColorBlack,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      cartProvider.addItemToCartOrUpdateQuantity(
                        widget.food.id,
                        widget.food.nama,
                        widget.food.harga,
                        widget.food.gambar ?? '-',
                        widget.tenantName ?? '',
                        widget.food.deskripsi ?? '-',
                        true,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.add_box,
                      color: AppColors.primaryColor,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildKasirCartActions(BuildContext context) {
    return Consumer<KasirProvider>(
      builder: (context, kasirProvider, _) {
        final cartItemIndex = kasirProvider.cart
            .indexWhere((item) => item.menuId == widget.food.id);

        if (cartItemIndex == -1) {
          return _buildAddToCartButton(context, kasirProvider: kasirProvider);
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  kasirProvider.addItemToCartOrUpdateQuantity(
                    widget.food.id,
                    widget.food.nama,
                    widget.food.harga,
                    widget.food.gambar ?? '-',
                    widget.food.deskripsi ?? '-',
                    false,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.indeterminate_check_box_outlined,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
              ),
              SizedBox(
                width: 30,
                child: Text(
                  kasirProvider.cart[cartItemIndex].count.toString(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: medium,
                    color: AppColors.textColorBlack,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  kasirProvider.addItemToCartOrUpdateQuantity(
                    widget.food.id,
                    widget.food.nama,
                    widget.food.harga,
                    widget.food.gambar ?? '-',
                    widget.food.deskripsi ?? '-',
                    true,
                  );
                },
                behavior: HitTestBehavior.opaque,
                child: Icon(
                  Icons.add_box,
                  color: AppColors.primaryColor,
                  size: 30,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildAddToCartButton(
    BuildContext context, {
    CartProvider? cartProvider,
    KasirProvider? kasirProvider,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        GestureDetector(
          onTap: () {
            if (widget.food.isReady == 1) {
              if (!widget.isTenantMenu && kasirProvider != null) {
                kasirProvider.addItemToCartOrUpdateQuantity(
                  widget.food.id,
                  widget.food.nama,
                  widget.food.harga,
                  widget.food.gambar ?? '-',
                  widget.food.deskripsi ?? '-',
                  true,
                );
              } else if (cartProvider != null) {
                cartProvider.addItemToCartOrUpdateQuantity(
                  widget.food.id,
                  widget.food.nama,
                  widget.food.harga,
                  widget.food.gambar ?? '-',
                  widget.tenantName ?? '',
                  widget.food.deskripsi ?? '-',
                  true,
                );
              }
            }
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 90,
            height: 35,
            decoration: BoxDecoration(
              color: widget.food.isReady == 1
                  ? AppColors.primaryColor
                  : AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: widget.food.isReady == 1
                    ? AppColors.primaryColor
                    : Colors.grey,
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.food.isReady == 1 ? 'Tambah' : 'Habis',
                style: GoogleFonts.poppins(
                  color: widget.food.isReady == 1 ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteButton(
      BuildContext context, CartProvider cartProvider, int cartItemIndex) {
    return GestureDetector(
      onTap: () async {
        final note = cartProvider.cart
            .firstWhere((item) => item.menuId == widget.food.id)
            .catatan;
        final catatan = await bottomSheetCatatan(
          context,
          note ?? '',
          'Tambah catatan untuk pesanan',
        );
        if (catatan != null) {
          cartProvider.addNote(widget.food.id, catatan);
        }
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 90,
        height: 35,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 15,
              color: AppColors.textColorBlack,
            ),
            const SizedBox(width: 5),
            Text(
              'Catatan',
              style: GoogleFonts.poppins(
                color: AppColors.textColorBlack,
                fontWeight: medium,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
