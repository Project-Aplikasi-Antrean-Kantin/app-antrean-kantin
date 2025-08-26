import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/presentation/provider/cart_provider.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/views/pembeli/detail_food_page.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/presentation/widgets/custom_page_builder.dart';
import 'package:testgetdata/presentation/widgets/image_by_url.dart';
import 'package:testgetdata/utils/has_internet_access.dart';

class ListCart extends StatelessWidget {
  final CartMenuModel cart;
  final bool isKasir;
  final String? tenantId;

  const ListCart({
    super.key,
    required this.cart,
    required this.isKasir,
    this.tenantId,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: true);
    final kasirProvider = Provider.of<KasirProvider>(context, listen: false);

    return Card(
      elevation: 0,
      color: AppColors.containerColorWhite,
      margin: const EdgeInsets.symmetric(vertical: 5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(10),
          ),
          border: Border.all(
            color: Colors.grey,
            width: 0.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: const Color.fromARGB(255, 200, 200, 200),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: cart.menuGambar.isNotEmpty
                        ? ImageByUrl(
                            url: "${MasbroConstants.baseUrl}${cart.menuGambar}",
                            fit: BoxFit.cover,
                          )
                        : const Icon(
                            Icons.photo,
                            color: Color.fromARGB(255, 120, 120, 120),
                            size: 30,
                          ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 5),
                      Text(
                        cart.menuNama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: semibold,
                          fontSize: 16,
                          color: AppColors.textColorBlack,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        FormatCurrency.intToStringCurrency(cart.menuPrice),
                        style: GoogleFonts.poppins(
                          fontWeight: medium,
                          fontSize: 14,
                          color: AppColors.textColorBlack,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 10),
                        child: Consumer<CartProvider>(
                          builder: (context, data, _) {
                            final index = data.cart.indexWhere((element) =>
                                element.menuId == cart.menuId &&
                                element.catatan == cart.catatan);

                            if (index == -1) {
                              return Container(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        kasirProvider
                                            .addItemToCartOrUpdateQuantity(
                                          cart.menuId,
                                          cart.menuNama,
                                          cart.menuPrice,
                                          cart.menuNama,
                                          cart.deskripsi ?? '',
                                          false,
                                        );
                                      },
                                      splashColor: Colors.transparent,
                                      child: Icon(
                                        Icons.indeterminate_check_box_outlined,
                                        color: AppColors.primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                    SizedBox(
                                      width:
                                          30, // Pastikan lebar tetap agar tidak bergeser
                                      child: Text(
                                        kasirProvider
                                            .getItemCount(cart.menuId)
                                            .toString(),
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: medium,
                                          color: AppColors.textColorBlack,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        kasirProvider
                                            .addItemToCartOrUpdateQuantity(
                                          cart.menuId,
                                          cart.menuNama,
                                          cart.menuPrice,
                                          cart.menuNama,
                                          cart.deskripsi ?? '',
                                          true,
                                        );
                                      },
                                      splashColor: Colors.transparent,
                                      child: Icon(
                                        Icons.add_box,
                                        color: AppColors.primaryColor,
                                        size: 30,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final internetConnection =
                                          await hasInternetAccess();
                                      if (!internetConnection) {
                                        Fluttertoast.showToast(
                                            msg: "Tidak ada koneksi internet");
                                        return;
                                      }
                                      Navigator.push(
                                          context,
                                          CustomPageBuilder(
                                              page: DetailFoodPage(
                                                  cartItem: cart,
                                                  addNewItem: true,
                                                  catatan: cart.catatan,
                                                  tenant: cartProvider
                                                      .currentTenant!)));
                                    },
                                    child: Container(
                                      width: 90,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.description_outlined,
                                            size: 15,
                                            color: AppColors.textColorBlack,
                                          ),
                                          SizedBox(width: 5),
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
                                  ),
                                  Row(
                                    children: [
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              cartProvider
                                                  .removeItemFromTenantCart(
                                                      catatan: cart.catatan,
                                                      tenantId ?? '',
                                                      cart.menuId);
                                            },
                                            splashColor: Colors.transparent,
                                            child: Icon(
                                              Icons
                                                  .indeterminate_check_box_outlined,
                                              color: AppColors.primaryColor,
                                              size: 30,
                                            ),
                                          ),
                                          SizedBox(
                                            width:
                                                30, // Pastikan lebar tetap agar tidak bergeser
                                            child: Text(
                                              data.cart[index].count.toString(),
                                              textAlign: TextAlign.center,
                                              style: GoogleFonts.poppins(
                                                fontSize: 16,
                                                fontWeight: medium,
                                                color: AppColors.textColorBlack,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              cartProvider.addItemToCart(
                                                  catatan: cart.catatan,
                                                  tenantId: tenantId ?? '',
                                                  cart: cart);
                                            },
                                            splashColor: Colors.transparent,
                                            child: Icon(
                                              Icons.add_box,
                                              color: AppColors.primaryColor,
                                              size: 30,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (cart.catatan?.isNotEmpty == true)
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
                        text: cart.catatan ?? '-',
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
        ),
      ),
    );
  }
}
