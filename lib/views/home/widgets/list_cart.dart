import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/home/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/views/theme.dart';

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
    if (cart.count == 0) {
      Navigator.of(context).pop();
    }
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(
        vertical: 5,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      // shadowColor: Colors.transparent,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(20),
          ),
          border: Border(
            bottom: BorderSide(color: Colors.grey, width: 1.0),
            top: BorderSide(color: Colors.grey, width: 0.2),
            left: BorderSide(color: Colors.grey, width: 0.2),
            right: BorderSide(color: Colors.grey, width: 0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(right: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 200, 200, 200),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: cart.menuGambar != null
                      ? Image.network(
                          "${MasbroConstants.baseUrl}${cart.menuGambar}",
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(
                                Icons.photo,
                                color: Color.fromARGB(255, 120, 120, 120),
                                size: 30,
                              ),
                            );
                          },
                        )
                      : const Center(
                          child: Icon(
                            Icons.photo,
                            color: Color.fromARGB(255, 120, 120, 120),
                            size: 30,
                          ),
                        ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 100,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cart.menuNama,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        FormatCurrency.intToStringCurrency(
                          cart.menuPrice,
                        ),
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        cart.deskripsi ?? '-',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Consumer<CartProvider>(
                  builder: (context, data, widget) {
                    var id = data.cart
                        .indexWhere((element) => element.menuId == cart.menuId);
                    if (id == -1) {
                      return Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: IconButton(
                            onPressed: () {
                              if (isKasir) {
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
                              } else {
                                Provider.of<CartProvider>(context,
                                        listen: false)
                                    .addRemove(
                                  cart.menuId,
                                  cart.menuNama,
                                  cart.menuPrice,
                                  cart.menuNama,
                                  cart.deskripsi,
                                  cart.tenantName,
                                  true,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.add,
                              size: 15,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    } else {
                      // item sudah ditambahkan ke dalam keranjang belanja
                      return Container(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                IconButton(
                                    onPressed: () {
                                      Provider.of<CartProvider>(context,
                                              listen: false)
                                          .addRemove(
                                        cart.menuId,
                                        cart.menuNama,
                                        cart.menuPrice,
                                        cart.menuNama,
                                        cart.deskripsi,
                                        cart.tenantName,
                                        false,
                                      );
                                    },
                                    icon: Icon(
                                      Icons.do_not_disturb_on_outlined,
                                      color: primaryColor,
                                      size: 24,
                                    )),
                                Consumer<CartProvider>(
                                    builder: (context, data, widget) {
                                  var id = data.cart.indexWhere((element) =>
                                      element.menuId == cart.menuId);
                                  return Text(
                                    (id == -1)
                                        ? "0"
                                        : data.cart[id].count.toString(),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      // fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                                IconButton(
                                  onPressed: () {
                                    Provider.of<CartProvider>(context,
                                            listen: false)
                                        .addRemove(
                                      cart.menuId,
                                      cart.menuNama,
                                      cart.menuPrice,
                                      cart.menuNama,
                                      cart.deskripsi,
                                      cart.tenantName,
                                      true,
                                    );
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () =>
                                  bottomSheetCatatan(context, cart.catatan!)
                                      .then(
                                (value) {
                                  if (value != null) {
                                    data.tambahCatatan(cart.menuId, value);
                                  }
                                },
                              ),
                              child: Container(
                                width: 85,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.description_outlined,
                                      size: 15,
                                    ),
                                    Text(
                                      'Catatan',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
