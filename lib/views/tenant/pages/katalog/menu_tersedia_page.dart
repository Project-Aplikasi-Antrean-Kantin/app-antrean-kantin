import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/update_menu_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/tenant/widgets/katalog_menu_tile.dart';
import 'package:testgetdata/views/components/search_widget.dart';
import 'package:testgetdata/views/theme.dart';

class MenuTersedia extends StatefulWidget {
  final List<TenantFoods> data;

  const MenuTersedia({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  State<MenuTersedia> createState() => _MenuTersediaState();
}

class _MenuTersediaState extends State<MenuTersedia> {
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
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Column(
            children: [
              SearchWidget(
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
                      child: const Text(
                        'Makanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...searchResult
                        .map((item) => KatalogMenuTile(
                              item: item,
                              onChanged: (value) {
                                updateMenuTenant(value, user.token, item.id)
                                    .then((value) {
                                  if (value) {
                                    setState(() {
                                      item.isReady = value ? 0 : 1;
                                    });
                                  } else {
                                    print("GAK BISA");
                                  }
                                });
                              },
                            ))
                        .where(
                          (element) => element.item.isReady == 1,
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

      // floatingActionButton: SizedBox(
      //   width: 160,
      //   child: FloatingActionButton(
      //     backgroundColor: primaryColor,
      //     onPressed: () {
      //       Navigator.pushNamed(context, '/tambah_menu');
      //     },
      //     child: const Padding(
      //       padding: EdgeInsets.symmetric(horizontal: 15),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Icon(
      //             Icons.add,
      //             color: Colors.white,
      //           ),
      //           Text(
      //             'Tambah Menu',
      //             style: TextStyle(
      //               color: Colors.white,
      //               fontSize: 14,
      //             ),
      //           ),
      //         ],
      //       ),
      //     ),
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      floatingActionButton: SizedBox(
        width: MediaQuery.of(context).size.width * 0.45,
        child: FloatingActionButton(
          backgroundColor: primaryColor,
          onPressed: () {
            Navigator.pushNamed(context, '/tambah_menu');
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * 0.02,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.05,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.02,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: MediaQuery.of(context).size.width * 0.02,
                  ),
                  child: Text(
                    'Tambah Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.038,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
