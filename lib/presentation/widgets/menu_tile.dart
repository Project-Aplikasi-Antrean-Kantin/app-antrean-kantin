import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/dashed_divider.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';

class MenuTile extends StatefulWidget {
  final TenantFoods food;
  final String? tenantName;
  final bool isTenantMenu;
  final bool enableNotes;
  final TenantModel tenant;

  const MenuTile({
    Key? key,
    required this.food,
    this.tenantName,
    this.isTenantMenu = false,
    this.enableNotes = true,
    required this.tenant,
  }) : super(key: key);

  @override
  _MenuTileState createState() => _MenuTileState();
}

class _MenuTileState extends State<MenuTile> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final cartItemCount = cartProvider.cart
        .where((item) => item.menuId == widget.food.id)
        .fold<int>(0, (sum, item) => sum + (item.count));

    return GestureDetector(
      onTap: () {
        if (authProvider.user.email == widget.tenant.emailPemilik) {
          Fluttertoast.showToast(
            msg: "Tidak bisa menambahkan ke keranjang, karena ini tenantmu",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: AppColors.errorColor,
            textColor: AppColors.whiteColor,
          );
          cartProvider.clearItemByMenuIdFromCart(
              cartProvider.currentTenant!.id.toString(), widget.food.id);
          return;
        }
        if (widget.food.isReady == 0) {
          Fluttertoast.showToast(
            msg: "Menu belum tersedia",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: AppColors.errorColor,
            textColor: AppColors.whiteColor,
          );
          cartProvider.clearItemByMenuIdFromCart(
              cartProvider.currentTenant!.id.toString(), widget.food.id);
          return;
        }

        if (cartItemCount > 0) {
          _buildBottomSheetMenu(context, widget.food);
        } else {
          Navigator.push(
              context,
              CustomPageBuilder(
                  page: DetailFoodPage(
                addNewItem: true,
                food: widget.food,
                tenant: widget.tenant,
              )));
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.food.isReady == 1
                    ? Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            child: ImageByUrl(
                              key: Key(widget.food.gambar.toString()),
                              url: '${widget.food.gambar.toString()}',
                              width: 144,
                              height: 144,
                            ),
                          ),
                          widget.tenant.emailPemilik == authProvider.user.email
                              ? Container()
                              : Positioned(
                                  bottom: 4,
                                  right: 4,
                                  child: Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: cartItemCount > 0
                                        ? Center(
                                            child: Text('${cartItemCount}',
                                                style: GoogleFonts.poppins(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16)))
                                        : Icon(Icons.add, color: Colors.white),
                                  ),
                                ),
                        ],
                      )
                    : ColorFiltered(
                        colorFilter: const ColorFilter.matrix(<double>[
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0.2126,
                          0.7152,
                          0.0722,
                          0,
                          0,
                          0,
                          0,
                          0,
                          1,
                          0,
                        ]),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                              child: ImageByUrl(
                                key: Key(widget.food.gambar.toString()),
                                url: '${widget.food.gambar.toString()}',
                                width: 144,
                                height: 144,
                              ),
                            ),
                            widget.tenant.emailPemilik ==
                                    authProvider.user.email
                                ? Container()
                                : Positioned(
                                    bottom: 4,
                                    right: 4,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: AppColors.primaryColor,
                                        shape: BoxShape.circle,
                                      ),
                                      child: cartItemCount > 0
                                          ? Center(
                                              child: Text('${cartItemCount}',
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 16)))
                                          : Icon(Icons.add,
                                              color: Colors.white),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                _buildFoodDetails(context),
              ],
            );
          },
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
          FormatCurrency.intToStringCurrency(widget.food.harga),
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: AppColors.textColorBlack,
          ),
        ),
        Text(
          capitalizeFirstLetter(widget.food.nama),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: AppColors.textColorBlack,
          ),
        ),
        const SizedBox(height: 5),
        // Container(
        //   margin: const EdgeInsets.only(top: 10),
        //   child: widget.isTenantMenu
        //       ? _buildTenantCartActions(context)
        //       : _buildKasirCartActions(context),
        // ),
      ],
    );
  }

  Future<void> _buildBottomSheetMenu(BuildContext context, TenantFoods food) {
    return showModalBottomSheet(
        backgroundColor: AppColors.whiteColor400,
        context: context,
        builder: (BuildContext context) {
          return Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final List<CartMenuModel> cartItemsByMenuId = cartProvider.cart
                  .where((item) => item.menuId == widget.food.id)
                  .toList();

              final totalPrice = cartItemsByMenuId.fold<int>(
                0,
                (sum, item) => sum + ((item.menuPrice) * (item.count)),
              );
              if (cartItemsByMenuId.isEmpty) {
                Navigator.pop(context);
              }

              return SafeArea(
                child: Stack(children: [
                  Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      spacing: 16,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width / 1.7,
                                child: Text(
                                  capitalizeFirstLetter(food.nama),
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: AppColors.blackColor,
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                              child: Text(
                                FormatCurrency.intToStringCurrency(totalPrice),
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          ],
                        ),
                        DashedDivider(
                            height: 2, color: AppColors.blackColor100),
                        Expanded(
                          child: ListView.separated(
                              separatorBuilder: (context, index) =>
                                  const SizedBox(height: 12),
                              itemCount: cartItemsByMenuId.length,
                              itemBuilder: (context, index) {
                                final cartItem = cartItemsByMenuId[index];
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: ImageByUrl(
                                        key: Key(
                                            '${cartItem.menuId}-${cartItem.menuGambar}-${cartItem.catatan}'),
                                        url: cartItem.menuGambar,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width /
                                          2.5,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            capitalizeFirstLetter(
                                                cartItem.menuNama),
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: AppColors.blackColor,
                                                fontWeight: FontWeight.w600),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          cartItem.catatan != '' &&
                                                  cartItem.catatan != null
                                              ? Text(
                                                  '${cartItem.catatan}',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  maxLines: 2,
                                                )
                                              : Text(
                                                  'Catatan Kosong',
                                                  style: TextStyle(
                                                      color: AppColors
                                                          .blackColor200,
                                                      fontSize: 12),
                                                ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.push(
                                                  context,
                                                  CustomPageBuilder(
                                                      page: DetailFoodPage(
                                                          cartItem: cartItem,
                                                          addNewItem: true,
                                                          catatan:
                                                              cartItem.catatan,
                                                          food: widget.food,
                                                          tenant: cartProvider
                                                              .currentTenant!)));
                                            },
                                            child: Text(
                                              'Edit',
                                              style: TextStyle(
                                                  color:
                                                      AppColors.primaryColor),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                        child: Column(
                                      spacing: 8,
                                      children: [
                                        Text(
                                          FormatCurrency.intToStringCurrency(
                                              cartItem.count *
                                                  cartItem.menuPrice),
                                          style: GoogleFonts.poppins(
                                            color: AppColors.blackColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Container(
                                          height: 36,
                                          width: 36,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(100),
                                            color: AppColors.primaryColor,
                                          ),
                                          alignment: Alignment
                                              .center, // ini alternatif dari Center()
                                          child: Text(
                                            '${cartItem.count}',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ],
                                    ))
                                  ],
                                );
                              }),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    left: 10,
                    child: GestureDetector(
                      onTap: () => {
                        Navigator.push(
                            context,
                            CustomPageBuilder(
                                page: DetailFoodPage(
                                    addNewItem: true,
                                    food: food,
                                    tenant: cartProvider.currentTenant!)))
                      },
                      child: Container(
                        padding: EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width - 20,
                          child: Center(
                            child: Text(
                              'Tambah Lagi',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
              );
            },
          );
        });
  }
}
