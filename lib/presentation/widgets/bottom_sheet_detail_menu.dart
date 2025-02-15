import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/core/theme/theme.dart';

class DetailMenu {
  String? namaTenant;
  final int idMenu;
  final String title;
  final String gambar;
  final String? description;
  final int price;
  final int isReady;
  bool? isTambah;

  DetailMenu({
    this.namaTenant,
    required this.idMenu,
    required this.title,
    required this.gambar,
    this.description,
    required this.price,
    required this.isReady,
    this.isTambah,
  });
}

Future<void> showDetailMenuBottomSheet(BuildContext context, DetailMenu menu,
    {bool isCashier = false}) {
  final CartProvider cartProvider =
      Provider.of<CartProvider>(context, listen: false);
  final KasirProvider kasirProvider =
      Provider.of<KasirProvider>(context, listen: false);

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(15),
      ),
    ),
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.only(
            top: 8,
            bottom: 18,
            left: 18,
            right: 18,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Indikator tutup botomsheet lurrr
              Container(
                height: 5,
                margin: const EdgeInsets.only(
                  bottom: 20,
                  left: 150,
                  right: 150,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              // gambar
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    "${MasbroConstants.baseUrl}${menu.gambar}",
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // nama menu
              Text(
                menu.title,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // harga menu
              Text(
                FormatCurrency.intToStringCurrency(
                  menu.price,
                ),
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8),
              // deskripsi menu
              Text(
                menu.description!.isNotEmpty
                    ? menu.description!
                    : 'Deskripsi tidak tersedia',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                // onTap: () {
                //   if (menu.isReady == 1) {
                //     cartProvider.addRemove(
                //       menu.idMenu,
                //       menu.title,
                //       menu.price,
                //       menu.gambar,
                //       menu.description,
                //       menu.namaTenant,
                //       true,
                //     );
                //     Navigator.of(context).pop();
                //   }
                // },
                onTap: () {
                  if (menu.isReady == 1) {
                    if (isCashier) {
                      kasirProvider.addRemove(
                        menu.idMenu,
                        menu.title,
                        menu.price,
                        menu.gambar,
                        menu.description,
                        true,
                      );
                    } else {
                      cartProvider.addItemToCartOrUpdateQuantity(
                        menu.idMenu,
                        menu.title,
                        menu.price,
                        menu.gambar,
                        menu.description!,
                        menu.namaTenant!,
                        true,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: menu.isReady == 1 ? primaryColor : Colors.grey,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12.0,
                        horizontal: 16.0,
                      ),
                      child: Center(
                        child: Text(
                          menu.isReady == 1 ? 'Tambah' : 'Habis',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      );
    },
  );
}
