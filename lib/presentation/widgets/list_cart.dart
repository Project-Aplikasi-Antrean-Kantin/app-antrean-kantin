import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/core/theme/text_theme.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_catatan.dart';

class ListCart extends StatelessWidget {
  final CartMenuModel cart;
  final bool isKasir;

  const ListCart({
    super.key,
    required this.cart,
    required this.isKasir,
  });

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Card(
      elevation: 0,
      color: Colors.white,
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
        child: Row(
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
                    ? Image.network(
                        "${MasbroConstants.baseUrl}${cart.menuGambar}",
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
                  Consumer<CartProvider>(
                    builder: (context, data, _) {
                      final index = data.cart.indexWhere(
                          (element) => element.menuId == cart.menuId);
                      if (index == -1) {
                        return Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Provider.of<KasirProvider>(context,
                                          listen: false)
                                      .addRemove(
                                    cart.menuId,
                                    cart.menuNama,
                                    cart.menuPrice,
                                    cart.menuNama,
                                    cart.deskripsi,
                                    false,
                                  );
                                },
                                icon: Icon(
                                  Icons.remove_circle_outline,
                                  color: AppColors.primaryColor,
                                  size: 30,
                                ),
                              ),
                              Text(
                                // data.cart[index].count.toString(),
                                context
                                    .watch<KasirProvider>()
                                    .getItemCount(cart.menuId)
                                    .toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: medium,
                                  color: AppColors.textColorBlack,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  Provider.of<KasirProvider>(context,
                                          listen: false)
                                      .addRemove(
                                    cart.menuId,
                                    cart.menuNama,
                                    cart.menuPrice,
                                    cart.menuNama,
                                    cart.deskripsi,
                                    true,
                                  );
                                },
                                icon: Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.primaryColor,
                                  size: 30,
                                ),
                              ),
                            ],
                          ),
                        );
                        // return ElevatedButton(
                        // onPressed: () {
                        //   if (isKasir) {
                        //     Provider.of<KasirProvider>(context, listen: false)
                        //         .addRemove(
                        //       cart.menuId,
                        //       cart.menuNama,
                        //       cart.menuPrice,
                        //       cart.menuNama,
                        //       cart.deskripsi,
                        //       true,
                        //     );
                        //   } else {
                        //     cartProvider.addItemToCartOrUpdateQuantity(
                        //       cart.menuId,
                        //       cart.menuNama,
                        //       cart.menuPrice,
                        //       cart.menuNama,
                        //       cart.deskripsi ?? '',
                        //       cart.tenantName ?? '',
                        //       true,
                        //     );
                        //   }
                        // },
                        //   style: ElevatedButton.styleFrom(
                        //     backgroundColor: AppColors.primaryColor,
                        //     shape: RoundedRectangleBorder(
                        //       borderRadius: BorderRadius.circular(8),
                        //     ),
                        //     minimumSize: const Size(30, 30),
                        //   ),
                        //   child: const Icon(
                        //     Icons.add,
                        //     size: 15,
                        //     color: Colors.white,
                        //   ),
                        // );
                      } else {
                        return Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                final catatan = await bottomSheetCatatan(
                                    context, cart.catatan ?? '');
                                if (catatan != null) {
                                  data.addNote(cart.menuId, catatan);
                                }
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
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                IconButton(
                                  onPressed: () {
                                    cartProvider.addItemToCartOrUpdateQuantity(
                                      cart.menuId,
                                      cart.menuNama,
                                      cart.menuPrice,
                                      cart.menuNama,
                                      cart.deskripsi ?? '',
                                      cart.tenantName ?? '',
                                      false,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.remove_circle_outline,
                                    color: AppColors.primaryColor,
                                    size: 30,
                                  ),
                                ),
                                Text(
                                  data.cart[index].count.toString(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    fontWeight: medium,
                                    color: AppColors.textColorBlack,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    cartProvider.addItemToCartOrUpdateQuantity(
                                      cart.menuId,
                                      cart.menuNama,
                                      cart.menuPrice,
                                      cart.menuNama,
                                      cart.deskripsi ?? '',
                                      cart.tenantName ?? '',
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outline,
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
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
