// menu_habis.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/core/http/update_menu_tenant.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/provider/auth_provider.dart';
import 'package:testgetdata/presentation/widgets/katalog_menu_tile.dart';
import 'package:testgetdata/presentation/widgets/search_widget.dart';

class MenuHabis extends StatefulWidget {
  final List<TenantFoods> data;
  const MenuHabis({Key? key, required this.data}) : super(key: key);

  @override
  State<MenuHabis> createState() => _MenuHabisState();
}

class _MenuHabisState extends State<MenuHabis> {
  late List<TenantFoods> searchResult;

  @override
  void initState() {
    super.initState();
    searchResult = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
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
                  print("ini Result : $result");
                  print("value : $value");
                  setState(
                    () {
                      searchResult = result;
                    },
                  );
                  print("ini SearchResult : $searchResult");
                },
                tittle: "Cari menu . . . ",
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFB3B3B3),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(
                        left: 10,
                        bottom: 10,
                      ),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 1,
                          ),
                        ),
                      ),
                      child: Text(
                        'Makanan',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...searchResult
                        .map((item) => KatalogMenuTile(
                              item: item,
                              onChanged: (value) {
                                print(user.token);
                                updateMenuTenant(value, user.token, item.id)
                                    .then((value) {
                                  if (value) {
                                    setState(() {
                                      item.isReady = value ? 1 : 0;
                                    });
                                  } else {
                                    print("GAK BISA");
                                  }
                                });
                              },
                            ))
                        .where(
                          (element) => element.item.isReady == 0,
                        )
                        .toList(),
                  ],
                ),
              ),
              const SizedBox(
                height: 80,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
