import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/update_menu_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/provider/kasir_provider.dart';
import 'package:testgetdata/views/common/format_currency.dart';
import 'package:testgetdata/views/home/pages/keranjang/cart_page.dart';
import 'package:testgetdata/views/home/widgets/menu_tenant.dart';
import 'package:testgetdata/views/tenant/widgets/katalog_menu_tile.dart';
import 'package:testgetdata/views/components/search_widget.dart';
import 'package:testgetdata/views/tenant/widgets/menu_tenant_tile.dart';
import 'package:testgetdata/views/theme.dart';

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
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
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
              ...searchResult
                  .map((item) => MenuTenantTile(
                        item1: item,
                      ))
                  .toList(),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSwitcher(
        duration: const Duration(
          milliseconds: 100,
        ),
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        child: context.watch<KasirProvider>().isCartShow
            ? SizedBox(
                width: MediaQuery.of(context).size.width - 20,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) {
                        return const Cart();
                      },
                    ));
                  },
                  backgroundColor: primaryColor,
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
                            const SizedBox(
                              width: 10,
                            ),
                            Expanded(
                              child: Text(
                                FormatCurrency.intToStringCurrency(
                                  data.cost,
                                ),
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Text(
                              data.total >= 2
                                  ? "${data.total} items"
                                  : "${data.total} item",
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
