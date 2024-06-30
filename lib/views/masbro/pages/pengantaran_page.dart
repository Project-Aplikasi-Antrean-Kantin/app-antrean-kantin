import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/http/fetch_pengantaran.dart';
import 'package:testgetdata/http/update_pengantaran.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/masbro/pages/pesanan_diantar.dart';
import 'package:testgetdata/views/masbro/pages/pesanan_menunggu.dart';
import 'package:testgetdata/views/theme.dart';

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
        Fluttertoast.showToast(
          msg: "Segera antar pesanan!",
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

  void removePesananDiantar(int idPesanan, auth) async {
    updatePengantaran('selesai', auth, idPesanan).then((value) {
      if (value) {
        setState(() {
          pesananDiantar.removeWhere((element) => element.id == idPesanan);
        });
        Fluttertoast.showToast(
          msg: "Pesanan selesai 🎉",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
          fontSize: 16,
        );
      }
    });
  }

  Future<void> _refreshPengantaran() async {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;
    await Future.delayed(const Duration(seconds: 1));
    List<Pesanan> fetchedPesananMasuk =
        await fetchPengantaran(user.token, 'siap_diantar');
    setState(() {
      pesananSiapDiantar = fetchedPesananMasuk;
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
          backgroundColor: backgroundColor,
          automaticallyImplyLeading: false,
          toolbarHeight: 50,
          scrolledUnderElevation: 0,
          title: Text(
            'Pengantaran',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: secondaryTextColor,
            ),
          ),
          centerTitle: true,
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
                    color: primaryTextColor,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  'Diantar',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: primaryTextColor,
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
            RefreshIndicator(
              onRefresh: _refreshPengantaran,
              child: pesananSiapDiantar.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'Pesanan kosong',
                              style: GoogleFonts.poppins(
                                color: primaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : PesananMenunggu(
                      pesananSiapDiantar: pesananSiapDiantar,
                      pesananDiantar: diantar,
                      onRefresh: _refreshPengantaran,
                    ),
            ),
            RefreshIndicator(
              onRefresh: _refreshPengantaran,
              child: pesananDiantar.isEmpty
                  ? ListView(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 1.4,
                          color: Colors.transparent,
                          child: Center(
                            child: Text(
                              'Pesanan kosong',
                              style: GoogleFonts.poppins(
                                color: primaryTextColor,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : PesananDiantar(
                      pesananDiantar: pesananDiantar,
                      pesananSelesai: removePesananDiantar,
                      onRefresh: _refreshPengantaran,
                    ),
            ),
          ],
        ),
        // bottomNavigationBar: NavbarHome(
        //   pageIndex:
        //       user.menu.indexWhere((element) => element.url == '/pengantaran'),
        // ),
      ),
    );
  }
}
