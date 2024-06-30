import 'dart:io';
import 'package:flutter/services.dart';
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
    debugPrint("$user");
    debugPrint("${user.menu}");

    final hasPermission = user.permission.contains('read beranda');
    debugPrint("$hasPermission");
    if (!hasPermission) {
      return const Center(
        child: Text('TIDAK ADA AKSES WOY'),
      );
    }

    // SystemChrome.setSystemUIOverlayStyle(
    //   SystemUiOverlayStyle(
    //     statusBarColor: backgroundColor,
    //     statusBarIconBrightness: Brightness.dark,
    //   ),
    // );

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 255,
              child: Stack(
                children: [
                  CarouselWidget(),
                  Positioned(
                    top: 200.0,
                    left: 15.0,
                    right: 15.0,
                    child: SearchWidget(
                      paddingHorizontal: 0,
                      paddingVertical: 0,
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
                        debugPrint(result.toString());
                        setState(() {
                          foundTenant = result;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Halo ${user.nama}!",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: primaryTextColor,
                      fontWeight: regular,
                    ),
                  ),
                  Text(
                    "Mau makan apa hari ini?",
                    style: GoogleFonts.poppins(
                      color: secondaryTextColor,
                      fontSize: 20,
                      fontWeight: semibold,
                    ),
                  ),
                ],
              ),
            ),
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
                }
                return Container(
                  color: backgroundColor,
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.15,
                  ),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        primaryColor,
                      ),
                    ),
                  ),
                );
              },
            ),
            // SizedBox(
            //   height: MediaQuery.of(context).padding.top,
            // ),
          ],
        ),
      ),
    );
  }
}
