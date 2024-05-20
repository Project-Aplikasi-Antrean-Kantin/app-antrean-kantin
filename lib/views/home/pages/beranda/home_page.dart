import 'dart:io';
import 'package:testgetdata/views/home/pages/navbar_home.dart';
import 'package:testgetdata/views/home/widgets/carousel_widget.dart';
import 'package:testgetdata/views/components/custom_snackbar.dart';
import 'package:testgetdata/views/home/widgets/list_tenant.dart';
import 'package:testgetdata/views/components/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/http/fetch_all_tenant.dart';
import 'package:testgetdata/model/tenant_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/theme.dart';

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
  bool isPertama = true;

  void showErrorBottomSheet() {
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
              const SizedBox(
                height: 20,
              ),
              const Text(
                'Tidak ada koneksi internet',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(
                height: 70,
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const NavbarHome(
                        pageIndex: 0,
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                },
                child: Text('Coba Lagi'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    futureTenant = fetchTenant(url, user.token);
  }

  @override
  Widget build(BuildContext context) {
    print(user);
    print(user.menu);

    final hasPermission = user.permission.contains('read beranda');
    print(hasPermission);
    if (!hasPermission) {
      return const Center(
        child: Text('TIDAK ADA AKSES WOY'),
      );
    }
    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   toolbarHeight: 50,
      //   scrolledUnderElevation: 0,
      //   bottomOpacity: 0,
      //   title: Text(
      //     'Beranda',
      //     style: GoogleFonts.poppins(
      //       fontWeight: FontWeight.bold,
      //       fontSize: 20,
      //       color: Colors.black,
      //     ),
      //   ),
      //   centerTitle: true,
      //   // actions: [
      //   //   IconButton(
      //   //     icon: const Icon(
      //   //       Icons.notifications,
      //   //       color: Colors.black,
      //   //       size: 24,
      //   //     ),
      //   //     onPressed: () {
      //   //       // Navigator.pop(context);
      //   //     },
      //   //   ),
      //   // ],
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(4.0),
      //     child: Container(
      //       color: Colors.grey,
      //       height: 0.5,
      //     ),
      //   ),
      // ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi ${user.nama}",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: primaryextColor,
                      ),
                    ),
                    Text(
                      "Spesial untuk kamu",
                      style: GoogleFonts.poppins(
                        color: secondaryTextColor,
                        fontSize: 20,
                        fontWeight: bold,
                      ),
                    ),
                  ],
                ),
              ),
              SearchWidget(
                paddingHorizontal: 20,
                tittle: "Cari menu kesukaanmu . . .",
                onChanged: (value) {
                  List<TenantModel> result = [];
                  if (value.isEmpty) {
                    result = fullTenant;
                  } else {
                    result = fullTenant
                        .where((tenant) => (tenant.namaTenant +
                                tenant.namaKavling +
                                tenant.tenantFoods!
                                    .map(
                                      (food) => food.nama,
                                    )
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
                    if (isPertama) {
                      foundTenant = fullTenant;
                      isPertama = false;
                    } else {
                      if (foundTenant.isEmpty) {
                        foundTenant = [];
                        return Center(
                          child: Text(
                            "Data Tidak Ditemukan",
                            style: GoogleFonts.poppins(
                              color: Colors.black26,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      }
                    }
                    return ListTenant(
                      url: url,
                      foundTenant: foundTenant,
                    );
                  } else if (snapshot.hasError) {
                    WidgetsBinding.instance!.addPostFrameCallback(
                      (_) {
                        if (snapshot.error is ApiException) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            CustomSnackBar(
                              status: 'failed',
                              message: (snapshot.error as ApiException).message,
                            ),
                          );
                        } else if (snapshot.error is SocketException) {
                          WidgetsBinding.instance!.addPostFrameCallback(
                            (_) {
                              showErrorBottomSheet();
                            },
                          );
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
                      },
                    );
                    // return Container();
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                    ),
                  );
                },
              ),
              // const SizedBox(
              //   height: 150,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// import 'dart:io';
// import 'package:testgetdata/views/home/widgets/carousel_widget.dart';
// import 'package:testgetdata/views/components/custom_snackbar.dart';
// import 'package:testgetdata/views/home/widgets/list_tenant.dart';
// import 'package:testgetdata/views/components/search_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:provider/provider.dart';
// import 'package:testgetdata/constants.dart';
// import 'package:testgetdata/exceptions/api_exception.dart';
// import 'package:testgetdata/http/fetch_all_tenant.dart';
// import 'package:testgetdata/model/tenant_model.dart';
// import 'package:testgetdata/model/user_model.dart';
// import 'package:testgetdata/provider/auth_provider.dart';
// import 'package:testgetdata/views/theme.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({Key? key}) : super(key: key);

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   String url = "${MasbroConstants.url}/tenants";
//   List<TenantModel> foundTenant = [];
//   List<TenantModel> fullTenant = [];
//   late AuthProvider authProvider =
//       Provider.of<AuthProvider>(context, listen: false);
//   late UserModel user = authProvider.user;
//   bool isPertama = true;

//   @override
//   void initState() {
//     super.initState();
//     fetchTenantData();
//   }

//   Future<void> fetchTenantData() async {
//     try {
//       String url = "${MasbroConstants.url}/tenants";
//       fullTenant = await fetchTenant(url, user.token);
//       setState(() {
//         foundTenant = fullTenant;
//       });
//     } catch (error) {
//       if (error is ApiException) {
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           CustomSnackBar(status: 'failed', message: error.message),
//         );
//       } else if (error is SocketException) {
//         // ignore: use_build_context_synchronously
//         showModalBottomSheet(
//           context: context,
//           builder: (BuildContext context) {
//             return Container(
//               height: 300,
//               width: MediaQuery.of(context).size.width,
//               padding: const EdgeInsets.all(20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(Icons.wifi_off, size: 72, color: Colors.red),
//                   const SizedBox(height: 20),
//                   const Text(
//                     'Tidak ada koneksi internet',
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   const SizedBox(height: 70),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                       fetchTenantData();
//                     },
//                     child: const Text('Coba Lagi'),
//                   ),
//                 ],
//               ),
//             );
//           },
//         );
//       } else {
//         // ignore: use_build_context_synchronously
//         ScaffoldMessenger.of(context).showSnackBar(
//           CustomSnackBar(
//               status: 'failed', message: 'An unexpected error occurred.'),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final hasPermission = user.permission.contains('read beranda');

//     if (!hasPermission) {
//       return const Center(
//         child: Text('TIDAK ADA AKSES WOY'),
//       );
//     }
//     return Scaffold(
//       backgroundColor: backgroundColor,
//       body: SafeArea(
//         bottom: false,
//         child: SingleChildScrollView(
//           physics: const BouncingScrollPhysics(
//               parent: AlwaysScrollableScrollPhysics()),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "Hi ${user.nama}",
//                       style: GoogleFonts.poppins(fontSize: 16),
//                     ),
//                     Text(
//                       "Spesial untuk kamu",
//                       style: GoogleFonts.poppins(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SearchWidget(
//                 paddingHorizontal: 20,
//                 tittle: "Cari menu kesukaanmu . . .",
//                 onChanged: (value) {
//                   List<TenantModel> result = [];
//                   if (value.isEmpty) {
//                     result = fullTenant;
//                   } else {
//                     result = fullTenant
//                         .where((tenant) => (tenant.namaTenant +
//                                 tenant.namaKavling +
//                                 tenant.tenantFoods!
//                                     .map((food) => food.nama)
//                                     .join(' ')
//                                     .toString())
//                             .toLowerCase()
//                             .contains(value.toLowerCase()))
//                         .toList();
//                   }
//                   setState(() {
//                     foundTenant = result;
//                   });
//                 },
//               ),
//               CarouselWidget(),
//               if (foundTenant.isEmpty && !isPertama)
//                 Center(
//                   child: Text(
//                     "Data Tidak Ditemukan",
//                     style: GoogleFonts.poppins(
//                         color: Colors.black26,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16),
//                   ),
//                 ),
//               // Text(foundTenant.length.toString()),
//               // ...foundTenant.map((tenant) {
//               //   print('data');
//               //   return ListTenant(
//               //     url: url,
//               //     foundTenant: foundTenant,
//               //   );
//               // }).toList(),
//               ListTenant(url: url, foundTenant: foundTenant),
//               const SizedBox(height: 50),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
