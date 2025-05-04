import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/data/remote/order_tenant_remote_data_source.dart';
import 'package:testgetdata/core/theme/colors_theme.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/presentation/provider/auth_provider.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_diproses.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_masuk.dart';

class PesananTenant extends StatefulWidget {
  const PesananTenant({Key? key}) : super(key: key);

  @override
  State<PesananTenant> createState() => _PesananTenantState();
}

class _PesananTenantState extends State<PesananTenant> {
  List<Pesanan> pesananMasuk = [];
  List<Pesanan> pesananDiproses = [];
  bool isLoading = false;

  void terimaPesanan(int idPesanan, Pesanan pesanan, auth) async {
    OrderTenantRemoteDataSource()
        .updateOrderCustomer('pesanan_diproses', auth, idPesanan)
        .then((value) {
      if (value && mounted) {
        setState(() {
          pesananMasuk.removeWhere((element) => element.id == pesanan.id);
          pesananDiproses.add(pesanan);
        });
        Fluttertoast.showToast(
          msg: "Segera proses pesanan!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      } else {
        debugPrint("GAK BISA");
      }
    });
  }

  void tolakPesanan(int idPesanan, Pesanan pesanan, auth) async {
    OrderTenantRemoteDataSource()
        .cancelOrderCustomer(auth, idPesanan)
        .then((value) {
      if (value && mounted) {
        setState(() {
          pesananMasuk.removeWhere((element) => element.id == pesanan.id);
        });
      } else {
        print("GAK BISA");
      }
    });
  }

  void tolakPesananBaru(int idPesanan, Pesanan pesanan, auth) async {
    OrderTenantRemoteDataSource()
        .updateOrderCustomer('pesanan_ditolak', auth, idPesanan)
        .then((value) {
      if (value && mounted) {
        setState(() {
          pesananMasuk.removeWhere((element) => element.id == pesanan.id);
        });
      } else {
        print("GAK BISA");
      }
    });
  }

  void removePesananDiproses(Pesanan pesanan, auth) async {
    final status = pesanan.isAntar == 1 ? 'siap_diantar' : 'selesai';
    OrderTenantRemoteDataSource()
        .updateOrderCustomer(status, auth, pesanan.id)
        .then((value) {
      if (value && mounted) {
        setState(() {
          pesananDiproses.removeWhere((element) => element.id == pesanan.id);
        });
        Fluttertoast.showToast(
          msg: "Pesanan Siap",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16.0,
        );
      }
    });
  }

  Future<void> _refreshPesananMasuk() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    await Future.delayed(const Duration(seconds: 1));
    List<Pesanan> fetchedPesananMasuk = await OrderTenantRemoteDataSource()
        .getOrderCustomer(context, user.token, 'pesanan_masuk');
    setState(() {
      pesananMasuk = fetchedPesananMasuk;
    });
  }

  // @override
  // void initState() {
  //   super.initState();
  //   isLoading = true;
  //   AuthProvider authProvider =
  //       Provider.of<AuthProvider>(context, listen: false);
  //   UserModel user = authProvider.user;
  //   OrderTenantRemoteDataSource()
  //       .getOrderCustomer(user.token, 'pesanan_masuk')
  //       .then(
  //         (value) => setState(() {
  //           isLoading = false;
  //           pesananMasuk = value;
  //         }),
  //       );
  // }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    OrderTenantRemoteDataSource()
        .getOrderCustomer(context, user.token, 'pesanan_masuk')
        .then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
          pesananMasuk = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          title: Text(
            'Pesanan',
            style: GoogleFonts.poppins(
              color: AppColors.textColorBlack,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          backgroundColor: AppColors.backgroundColor,
          centerTitle: true,
          bottom: TabBar(
            onTap: (value) {
              if (value == 0) {
                OrderTenantRemoteDataSource()
                    .getOrderCustomer(context, user.token, 'pesanan_masuk')
                    .then((value) {
                  setState(() {
                    pesananMasuk = value;
                  });
                });
              } else {
                OrderTenantRemoteDataSource()
                    .getOrderCustomer(context, user.token, 'pesanan_diproses')
                    .then((value) {
                  setState(() {
                    pesananDiproses = value;
                  });
                });
              }
            },
            indicatorColor: Colors.black,
            indicatorWeight: 1,
            labelColor: Colors.black,
            isScrollable: false,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              Tab(
                child: Text(
                  'Masuk',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack,
                    fontSize: 14,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Diproses',
                  style: GoogleFonts.poppins(
                    color: AppColors.textColorBlack,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          key: UniqueKey(),
          children: [
            pesananMasuk.isEmpty
                ? Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: AppColors.backgroundColor,
                          child: Center(
                            child: Text(
                              'Pesanan kosong',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorBlack,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : PesananMasuk(
                    pesananMasuk: pesananMasuk,
                    terimaPesanan: terimaPesanan,
                    tolakPesanan: tolakPesanan,
                    onRefresh: _refreshPesananMasuk,
                  ),
            pesananDiproses.isEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          color: AppColors.backgroundColor,
                          child: Center(
                            child: Text(
                              'Pesanan kosong',
                              style: GoogleFonts.poppins(
                                color: AppColors.textColorBlack,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      )
                    ],
                  )
                : PesananDiproses(
                    pesananDiproses: pesananDiproses,
                    removePesanan: removePesananDiproses,
                  ),
          ],
        ),
      ),
    );
  }
}
