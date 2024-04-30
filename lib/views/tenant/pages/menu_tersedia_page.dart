import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/katalog_menu_tile.dart';
import 'package:testgetdata/http/update_menu_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/tenant/tambah_menu.dart';

class MenuTersedia extends StatefulWidget {
  final List<TenantFoods> data;
  const MenuTersedia({Key? key, required this.data}) : super(key: key);

  @override
  State<MenuTersedia> createState() => _MenuTersediaState();
}

class _MenuTersediaState extends State<MenuTersedia> {
  // late TenantModel data;

  // @override
  // void initState() {
  //   super.initState();
  //   AuthProvider authProvider =
  //       Provider.of<AuthProvider>(context, listen: false);
  //   UserModel user = authProvider.user;
  //   fetchKatalogTenant(user.token).then(
  //     (value) => setState(
  //       () {
  //         data = value;
  //       },
  //     ),
  //   );
  // }

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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: Colors.grey,
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        hintText: "Cari menu...",
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Color.fromARGB(255, 75, 75, 75),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        border: Border.all(
                          color: Colors.redAccent,
                          width: 1.5,
                        ),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Icon(
                            Icons.filter_list,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color(0xFFB3B3B3),
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
                    ...widget.data
                        .map((item) => KatalogMenuTile(
                              item: item,
                              onChanged: (value) {
                                updateMenuTenant(
                                        value, user.token, item.detailMenu!.id)
                                    .then((value) {
                                  if (value) {
                                    setState(() {
                                      item.detailMenu!.isReady = value ? 0 : 1;
                                    });
                                  } else {
                                    print("GAK BISA");
                                  }
                                });
                              },
                            ))
                        .where(
                          (element) => element.item.detailMenu!.isReady == 1,
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
      //     backgroundColor: Colors.redAccent,
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
          backgroundColor: Colors.redAccent,
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
