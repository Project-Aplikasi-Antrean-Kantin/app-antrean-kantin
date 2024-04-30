import 'dart:io';

import 'package:testgetdata/components/search_widget.dart';

import '../cart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/carousel_widget.dart';
import 'package:testgetdata/components/custom_snackbar.dart';
import 'package:testgetdata/components/list_tenant.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/http/fetch_all_tenant.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/provider/cart_provider.dart';

class HomePage extends StatefulWidget {
  // static const int homeIndex = 0;

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<TenantModel>> futureTenant;
  String url = "${MasbroConstants.url}/tenants";
  List<TenantModel> foundTenant = [];
  List<TenantModel> fullTenant = [];
  late AuthProvider authProvider =
      Provider.of<AuthProvider>(context, listen: false);
  late UserModel user = authProvider.user;

  @override
  void initState() {
    // TODO: implement initState'
    super.initState();
    futureTenant = fetchTenant(url, user.token);
  }

  // FocusNode myfokus = new FocusNode();
  bool ispertama = true;

  @override
  Widget build(BuildContext context) {
    // AuthProvider authProvider = Provider.of<AuthProvider>(context);
    // UserModel user = authProvider.user;
    print(user);

    // futureTenant = fetchTenant(url, user.token);
    // print(futureTenant);

    final hasPermission = user.permission.contains('read beranda');
    print(hasPermission);

    if (!hasPermission) {
      return const Center(
        child: Text('TIDAK ADA AKSES WOY'),
      );
    }
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 50,
        scrolledUnderElevation: 0,
        bottomOpacity: 0,
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(
        //       Icons.notifications,
        //       color: Colors.black,
        //       size: 24,
        //     ),
        //     onPressed: () {
        //       // Navigator.pop(context);
        //     },
        //   ),
        // ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.grey,
            height: 0.5,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi ${user.nama}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "Spesial untuk kamu",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // SEARCH
              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 20),
              //   child: TextFormField(
              //     cursorColor: Colors.grey,
              //     textAlign: TextAlign.start,
              //     textAlignVertical: TextAlignVertical.center,
              //     onChanged: (value) {
              //       List<TenantModel> result = [];
              //       if (value.isEmpty) {
              //         result = fullTenant;
              //       } else {
              //         result = fullTenant
              //             .where((tenant) => (tenant.namaTenant +
              //                     tenant.namaKavling +
              //                     tenant.tenantFoods!
              //                         .map((food) => food.nama)
              //                         .join(' ')
              //                         .toString())
              //                 .toLowerCase()
              //                 .contains(value.toLowerCase()))
              //             .toList();
              //       }
              //       print(result);
              //       setState(() {
              //         foundTenant = result;
              //       });
              //     },
              //     decoration: InputDecoration(
              //       contentPadding: const EdgeInsets.symmetric(
              //         vertical: 10,
              //       ),
              //       prefixIcon: const Icon(
              //         Icons.search,
              //         color: Colors.grey,
              //       ),
              //       hintText: "Cari menu kesukaanmu...",
              //       hintStyle: GoogleFonts.poppins(
              //         color: Colors.grey,
              //         // fontSize: 12,
              //       ),
              //       focusedBorder: OutlineInputBorder(
              //         borderSide: const BorderSide(
              //             color: Color.fromARGB(255, 75, 75, 75), width: 1.5),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //       enabledBorder: OutlineInputBorder(
              //         borderSide: BorderSide(color: Colors.grey, width: 1),
              //         borderRadius: BorderRadius.circular(20),
              //       ),
              //     ),
              //   ),
              //   // )
              // ),
              SearchWidget(
                onChanged: (value) {
                  List<TenantModel> result = [];
                  if (value.isEmpty) {
                    result = fullTenant;
                  } else {
                    result = fullTenant
                        .where((tenant) => (tenant.namaTenant +
                                tenant.namaKavling +
                                tenant.tenantFoods!
                                    .map((food) => food.nama)
                                    .join(' ')
                                    .toString())
                            .toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  }
                  print(result);
                  setState(() {
                    foundTenant = result;
                  });
                },
              ),
              CarouselWidget(),
              FutureBuilder<List<TenantModel>>(
                future: futureTenant,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    fullTenant = snapshot.data!;
                    if (ispertama) {
                      foundTenant = fullTenant;
                      ispertama = false;
                    } else {
                      if (foundTenant.isEmpty) {
                        foundTenant = [];
                        return Center(
                            child: Text(
                          "Data Tidak Ditemukan",
                          style: GoogleFonts.poppins(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ));
                      }
                    }
                    return ListTenant(
                      url: url,
                      foundTenant: foundTenant,
                    );
                    // } else if (snapshot.hasError) {
                    //   WidgetsBinding.instance!.addPostFrameCallback((_) {
                    //     ScaffoldMessenger.of(context).showSnackBar(
                    //       CustomSnackBar(
                    //         status: 'failed',
                    //         message: (snapshot.error as ApiException).message,
                    //       ),
                    //     );
                    //   });
                  } else if (snapshot.hasError) {
                    WidgetsBinding.instance!.addPostFrameCallback((_) {
                      if (snapshot.error is ApiException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: 'failed',
                            message: (snapshot.error as ApiException).message,
                          ),
                        );
                      } else if (snapshot.error is SocketException) {
                        WidgetsBinding.instance!.addPostFrameCallback((_) {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                height: 300,
                                width: MediaQuery.of(context).size.width,
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.wifi_off,
                                      size: 72,
                                      color: Colors.red,
                                    ),
                                    SizedBox(height: 20),
                                    const Text(
                                      'Tidak ada koneksi internet',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    SizedBox(height: 70),
                                    ElevatedButton(
                                      onPressed: () {
                                        // todo: perlu refresh halaman disini
                                        Navigator.pop(context);
                                        Navigator.of(context)
                                            .pushReplacementNamed('/beranda');
                                      },
                                      child: Text('Coba Lagi'),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        });
                      } else if (snapshot.error is ClientException) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: 'failed',
                            message: 'Error pas fetching data.',
                            // message: snapshot.error.toString(),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          CustomSnackBar(
                            status: 'failed',
                            message: 'An unexpected error occurred.',
                            // message: snapshot.error.toString(),
                          ),
                        );
                      }
                    });

                    return Container();
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: context.watch<CartProvider>().isCartShow
          ? Consumer<CartProvider>(
              builder: (context, data, _) {
                return Container(
                  // margin: const EdgeInsets.all(20),
                  width: 360,
                  height: 63,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) {
                          return const Cart();
                        },
                      ));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            NumberFormat.currency(
                              symbol: 'Rp',
                              decimalDigits: 0,
                              locale: 'id-ID',
                            ).format(data.cost),
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            data.total >= 2
                                ? "${data.total} items"
                                : "${data.total} item",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : null,

      // FloatingActionButton(
      //   shape: BeveledRectangleBorder(),
      //   onPressed: (){
      //
      //   },
      // ),

      bottomNavigationBar: NavbarHome(
        pageIndex: user.menu.indexWhere((element) => element.url == '/beranda'),
      ),
    );
  }
}
