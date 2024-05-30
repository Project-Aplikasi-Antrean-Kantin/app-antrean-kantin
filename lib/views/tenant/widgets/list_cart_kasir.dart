import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/provider/cart_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/home/widgets/bottom_sheet_catatan.dart';
import 'package:testgetdata/views/theme.dart';

class ListCartKasir extends StatelessWidget {
  final CartMenuModel cart;

  const ListCartKasir({super.key, required this.cart});

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
            bottom: BorderSide(
              color: Colors.grey, // Warna border
              width: 1.0, // Lebar border
            ),
            top: BorderSide(
              color: Colors.grey, // Warna border
              width: 0.2, // Lebar border
            ),
            left: BorderSide(
              color: Colors.grey, // Warna border
              width: 0.2, // Lebar border
            ),
            right: BorderSide(
              color: Colors.grey, // Warna border
              width: 0.2, // Lebar border
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 200, 200, 200),
                ),
                height: 100,
                width: 100,
                margin: const EdgeInsets.only(right: 15),
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
                  // decoration: BoxDecoration(
                  //   border: Border.all(
                  //     color: Colors.grey,
                  //     width: 1.0,
                  //   ),
                  //   borderRadius: BorderRadius.circular(5.0),
                  // ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // mainAxisAlignment: MainAxisAlignment.center,
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
                        //'Deskripis produk diisi nanti diambilkan dari api',
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
                child: Consumer<KasirProvider>(
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
                              Provider.of<KasirProvider>(context, listen: false)
                                  .addRemove(
                                      cart.menuId,
                                      cart.menuNama,
                                      cart.menuPrice,
                                      cart.menuNama,
                                      cart.deskripsi,
                                      true);
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
                                      Provider.of<KasirProvider>(context,
                                              listen: false)
                                          .addRemove(
                                              cart.menuId,
                                              cart.menuNama,
                                              cart.menuPrice,
                                              cart.menuNama,
                                              cart.deskripsi,
                                              false);
                                    },
                                    icon: Icon(
                                      Icons.do_not_disturb_on_outlined,
                                      color: primaryColor,
                                      size: 24,
                                    )),
                                Consumer<KasirProvider>(
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
                                    Provider.of<KasirProvider>(context,
                                            listen: false)
                                        .addRemove(
                                            cart.menuId,
                                            cart.menuNama,
                                            cart.menuPrice,
                                            cart.menuNama,
                                            cart.deskripsi,
                                            true);
                                  },
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: primaryColor,
                                    size: 24,
                                  ),
                                ),
                              ],
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
