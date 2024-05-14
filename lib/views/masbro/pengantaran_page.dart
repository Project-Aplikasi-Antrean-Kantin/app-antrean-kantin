import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_pengantaran.dart';
import 'package:testgetdata/http/update_pengantaran.dart';
import 'package:testgetdata/model/food_item.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/home_page.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/masbro/pesanan_diantar.dart';
import 'package:testgetdata/views/masbro/pesanan_menunggu.dart';
import 'package:testgetdata/components/appbar.dart';

class PerluPengantaran extends StatefulWidget {
  const PerluPengantaran({super.key});

  @override
  State<PerluPengantaran> createState() => _PerluPengantaranState();
}

class _PerluPengantaranState extends State<PerluPengantaran> {
  List<Pesanan> pesananSiapDiantar = [];
  List<Pesanan> pesananDiantar = [];
  bool isLoading = false;

  void diantar(int idPesanan, Pesanan pesanan, auth) async {
    updatePengantaran('diantar', auth, idPesanan).then((value) {
      if (value) {
        setState(() {
          pesananSiapDiantar.removeWhere((element) => element.id == pesanan.id);
          pesananDiantar.add(pesanan);
        });
      } else {
        print("GAK BISA");
      }
    });
  }

  void removePesananDiantar(int idPesanan, auth) async {
    updatePengantaran('selesai', auth, idPesanan).then((value) {
      if (value) {
        setState(() {
          pesananDiantar.removeWhere((element) => element.id == idPesanan);
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
    fetchPengantaran(user.token, 'siap_diantar').then(
      (value) => setState(
        () {
          isLoading = false;
          print(value);
          pesananSiapDiantar = value;
        },
      ),
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
          scrolledUnderElevation: 0,
          title: Text(
            'Pengantaran',
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
                fetchPengantaran(user.token, 'siap_diantar').then((value) {
                  setState(() {
                    pesananSiapDiantar = value;
                  });
                });
              } else {
                print(value);
                fetchPengantaran(user.token, 'diantar').then((value) {
                  setState(() {
                    pesananDiantar = value;
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
                  'Menunggu',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Diantar',
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
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : PesananMenunggu(
                    pesananSiapDiantar: pesananSiapDiantar,
                    pesananDiantar: diantar,
                  ),
            isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : PesananDiantar(
                    pesananDiantar: pesananDiantar,
                    pesananSelesai: removePesananDiantar,
                  ),
          ],
        ),
        bottomNavigationBar: NavbarHome(
          pageIndex:
              user.menu.indexWhere((element) => element.url == '/pengantaran'),
        ),
      ),
    );
  }
}
