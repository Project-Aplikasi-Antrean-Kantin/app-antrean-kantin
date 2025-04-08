import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/provider/cart_provider.dart';
import 'package:testgetdata/data/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';

class DetailMenu {
  TenantFoods dataFoods;
  String? namaTenant;
  // final int idMenu;
  // final String title;
  // final String gambar;
  // final String? description;
  // final int price;
  // final int isReady;
  // bool? isTambah;

  DetailMenu({
    required this.dataFoods,
    this.namaTenant,
    // required this.idMenu,
    // required this.title,
    // required this.gambar,
    // this.description,
    // required this.price,
    // required this.isReady,
    // this.isTambah,
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
                    "${MasbroConstants.baseUrl}${menu.dataFoods.gambar}",
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // nama menu
              Text(
                menu.dataFoods.nama ?? menu.dataFoods.nama,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              // harga menu
              Text(
                FormatCurrency.intToStringCurrency(
                  menu.dataFoods.harga,
                ),
                style: const TextStyle(
                  fontSize: 16.0,
                ),
              ),
              const SizedBox(height: 8),
              // deskripsi menu
              Text(
                menu.dataFoods.deskripsi != null
                    ? menu.dataFoods.deskripsi!
                    : '-',
                style: TextStyle(
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 50),
              GestureDetector(
                onTap: () {
                  if (menu.dataFoods.isReady == 1) {
                    if (isCashier) {
                      kasirProvider.addItemToCartOrUpdateQuantity(
                        menu.dataFoods.id,
                        menu.dataFoods.nama,
                        menu.dataFoods.harga,
                        menu.dataFoods.gambar,
                        menu.dataFoods.deskripsi.toString(),
                        true,
                      );
                    } else {
                      cartProvider.addItemToCartOrUpdateQuantity(
                        menu.dataFoods.id,
                        menu.dataFoods.nama,
                        menu.dataFoods.harga,
                        menu.dataFoods.gambar,
                        menu.dataFoods.deskripsi ?? "-",
                        menu.namaTenant!,
                        true,
                      );
                    }
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: menu.dataFoods.isReady == 1
                        ? AppColors.primaryColor
                        : Colors.grey,
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
                          menu.dataFoods.isReady == 1 ? 'Tambah' : 'Habis',
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
