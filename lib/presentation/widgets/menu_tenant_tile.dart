import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/bottom_sheet_detail_menu.dart';
import 'package:testgetdata/core/theme/theme.dart';

class MenuTenantTile extends StatelessWidget {
  final TenantFoods item1;

  const MenuTenantTile({
    Key? key,
    required this.item1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3),
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(15),
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
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              showDetailMenuBottomSheet(
                context,
                DetailMenu(
                  idMenu: item1.id,
                  title: item1.nama ?? item1.nama,
                  gambar: item1.gambar,
                  description: item1.deskripsi ?? '-',
                  price: item1.harga,
                  isReady: item1.isReady,
                ),
                isCashier: true,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                image: DecorationImage(
                  image:
                      NetworkImage("${MasbroConstants.baseUrl}${item1.gambar}"),
                  fit: BoxFit.cover,
                ),
              ),
              height: 100,
              width: 100,
              margin: const EdgeInsets.only(right: 15),
            ),
          ),
          Expanded(
            child: Container(
              height: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item1.nama ?? item1.nama,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    FormatCurrency.intToStringCurrency(item1.harga),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    item1.deskripsi ?? '-',
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
                    .indexWhere((element) => element.menuId == item1.id);
                if (id == -1) {
                  return GestureDetector(
                    onTap: () {
                      if (item1.isReady == 1) {
                        String name = item1.nama ?? 'nama kosong';
                        String gambar = item1.gambar ?? 'gambar kosong';

                        Provider.of<KasirProvider>(context, listen: false)
                            .addRemove(
                          item1.id,
                          name,
                          item1.harga,
                          gambar,
                          item1.deskripsi,
                          true,
                        );
                      }
                    },
                    child: Container(
                      width: 75,
                      height: 25,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              item1.isReady == 1 ? primaryColor : Colors.grey,
                          width: 1.5,
                        ),
                      ),
                      // child: Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     Text(
                      //       'Tambah',
                      //       style: TextStyle(
                      //         color: primaryColor,
                      //         fontSize: 12,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item1.isReady == 1 ? 'Tambah' : 'Habis',
                            style: TextStyle(
                              color: item1.isReady == 1
                                  ? primaryColor
                                  : Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else {
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
                                  item1.id,
                                  item1.nama,
                                  item1.harga,
                                  item1.nama,
                                  item1.deskripsi,
                                  false,
                                );
                              },
                              icon: Icon(
                                Icons.do_not_disturb_on_outlined,
                                color: primaryColor,
                                size: 26,
                              ),
                            ),
                            Consumer<KasirProvider>(
                              builder: (context, data, widget) {
                                var id = data.cart.indexWhere(
                                    (element) => element.menuId == item1.id);
                                return Text(
                                  (id == -1)
                                      ? "0"
                                      : data.cart[id].count.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              onPressed: () {
                                Provider.of<KasirProvider>(context,
                                        listen: false)
                                    .addRemove(
                                  item1.id,
                                  item1.nama,
                                  item1.harga,
                                  item1.nama,
                                  item1.deskripsi,
                                  true,
                                );
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: primaryColor,
                                size: 26,
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
    );
  }
}
