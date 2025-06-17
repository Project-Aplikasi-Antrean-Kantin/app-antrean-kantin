import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/presentation/provider/kasir_provider.dart';
import 'package:testgetdata/presentation/views/common/format_currency.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';
import 'package:testgetdata/presentation/views/pembeli/cart_page.dart';
import 'package:testgetdata/presentation/widgets/menu_tile.dart';

class MenuKasir extends StatefulWidget {
  final List<TenantFoods> data;

  const MenuKasir({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<MenuKasir> createState() => _MenuKasirState();
}

class _MenuKasirState extends State<MenuKasir> {
  late List<TenantFoods> searchResult;

  @override
  void initState() {
    super.initState();
    searchResult = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    print("object");

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: Column(
            children: [
              SearchWidget(
                paddingVertical: 0,
                paddingHorizontal: 0,
                onChanged: (value) {
                  List<TenantFoods> result = widget.data;
                  if (value.isEmpty) {
                    result = result;
                  } else {
                    result = result
                        .where(
                          (tenanfoods) =>
                              (tenanfoods.nama != null &&
                                  tenanfoods.nama!
                                      .toLowerCase()
                                      .contains(value.toLowerCase())) ||
                              (tenanfoods.nama != null &&
                                  tenanfoods.nama!
                                      .toLowerCase()
                                      .contains(value.toLowerCase())),
                        )
                        .toList();
                  }
                  debugPrint("ini Result : $result");
                  debugPrint("value : $value");
                  setState(
                    () {
                      searchResult = result;
                    },
                  );
                  debugPrint("ini SearchResult : $searchResult");
                },
                tittle: "Cari menu . . . ",
              ),
              const SizedBox(
                height: 10,
              ),
              // ...searchResult
              //     .map((item) => MenuTile(
              //           food: item,
              //           isTenantMenu: false,
              //           enableNotes: false,
              //         ))
              //     .toList(),
              ...searchResult.asMap().entries.expand((entry) {
                final index = entry.key;
                final item = entry.value;
                return [
                  MenuTile(
                    food: item,
                    isTenantMenu: false,
                    enableNotes: false,
                  ),
                  if (index < searchResult.length - 1)
                    Divider(
                      color: Colors.grey,
                      thickness: 0.2,
                      height: 1,
                    ),
                ];
              }).toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: context.watch<KasirProvider>().isCartVisible
            ? SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: FloatingActionButton(
                  onPressed: () {
                    // Trigger perubahan state Kasir
                    final kasirProvider = context.read<KasirProvider>();
                    // kasirProvider.setIsKasir(!kasirProvider.isKasir == true);
                    kasirProvider.setIsKasir(true);
                    log(kasirProvider.isKasir.toString());

                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            CartPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset(0.0, 0.0);
                          const curve = Curves.easeInOut;

                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);

                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Consumer<KasirProvider>(
                    builder: (context, data, _) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Icon(
                              Icons.shopping_cart,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                FormatCurrency.intToStringCurrency(
                                  data.cartCost,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              data.totalItems >= 2
                                  ? "${data.totalItems} items"
                                  : "${data.totalItems} item",
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              )
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
