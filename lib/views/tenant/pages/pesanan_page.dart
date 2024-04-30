import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_pesanan_pembeli.dart';
import 'package:testgetdata/http/update_pesanan.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/tenant/pages/pesanan_masuk.dart';
import 'package:testgetdata/views/tenant/pages/pesanan_diproses_page.dart';

class PesananTenant extends StatefulWidget {
  const PesananTenant({Key? key}) : super(key: key);

  @override
  State<PesananTenant> createState() => _PesananTenantState();
}

class _PesananTenantState extends State<PesananTenant> {
  // Map<String, List<Map<String, dynamic>>> pesananDiproses = {};
  List<Pesanan> pesananMasuk = [];
  List<Pesanan> pesananDiproses = [];
  bool isLoading = false;

  void terimaPesanan(int idPesanan, Pesanan pesanan, auth) async {
    updatePesanan('pesanan_diproses', auth, idPesanan).then((value) {
      if (value) {
        setState(() {
          pesananMasuk.removeWhere((element) => element.id == pesanan.id);
          pesananDiproses.add(pesanan);
        });
      } else {
        print("GAK BISA");
      }
    });
  }

  void tolakPesanan(int idPesanan, Pesanan pesanan, auth) async {
    updatePesanan('pesanan_ditolak', auth, idPesanan).then((value) {
      if (value) {
        setState(() {
          pesananMasuk.removeWhere((element) => element.id == pesanan.id);
          // pesananDiproses.add(pesanan);
        });
      } else {
        print("GAK BISA");
      }
    });
  }

  // remove apabila penjual udah menekan antar
  void removePesananDiproses(Pesanan pesanan, auth) async {
    final status = pesanan.isAntar == 1 ? 'siap_diantar' : 'selesai';
    updatePesanan(status, auth, pesanan.id).then((value) {
      if (value) {
        setState(() {
          pesananDiproses.removeWhere((element) => element.id == pesanan.id);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    isLoading = true;
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    fetchPesananPembeli(user.token, 'pesanan_masuk').then(
      (value) => setState(() {
        isLoading = false;
        pesananMasuk = value;
      }),
      // (value) => setState(() {
      //   print(value);
      //   pesananMasuk = value;
      // }),
    );
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
          bottom: TabBar(
            onTap: (value) {
              if (value == 0) {
                fetchPesananPembeli(user.token, 'pesanan_masuk').then((value) {
                  setState(() {
                    pesananMasuk = value;
                  });
                });
              } else {
                print(value);
                fetchPesananPembeli(user.token, 'pesanan_diproses')
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
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Diproses',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          physics: NeverScrollableScrollPhysics(),
          key: UniqueKey(),
          children: [
            isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show CircularProgressIndicator while loading
                : PesananMasuk(
                    pesananMasuk: pesananMasuk,
                    terimaPesanan: terimaPesanan,
                    tolakPesanan: tolakPesanan,
                  ),
            isLoading
                ? Center(
                    child:
                        CircularProgressIndicator()) // Show CircularProgressIndicator while loading
                : HomeDiproses(
                    pesananDiproses: pesananDiproses,
                    removePesanan: removePesananDiproses,
                  ),
          ],
        ),
        bottomNavigationBar: NavbarHome(
          pageIndex:
              user.menu.indexWhere((element) => element.url == '/pesanan'),
        ),
      ),
    );
  }
}
