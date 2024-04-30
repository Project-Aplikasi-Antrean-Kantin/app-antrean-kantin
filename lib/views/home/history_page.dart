import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/components/appbar.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/navbar_home.dart';
import 'package:testgetdata/views/test_riwayat.dart';

class RiwayatPage extends StatelessWidget {
  const RiwayatPage({Key? key}) : super(key: key);
  static const int PageIndex = 1;

  // List Tab = [
  //   "read riwayat",
  //   "read riwayat",
  //   "read riwayat",
  // ];

  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider =
        Provider.of<AuthProvider>(context, listen: false);
    UserModel user = authProvider.user;

    List<Widget> tabs = [];

    if (user.permission.contains('read order user')) {
      tabs.add(TestRiwayat(role: 'user'));
    }
    if (user.permission.contains('read order tenant')) {
      tabs.add(TestRiwayat(role: 'tenant'));
    }
    if (user.permission.contains('read order masbro')) {
      tabs.add(TestRiwayat(role: 'masbro'));
    }

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBarWidget(
          title: "Riwayat",
          tab1Title:
              user.permission.contains('read order user') ? "Beli" : null,
          tab2Title:
              user.permission.contains('read order tenant') ? "Jual" : null,
          tab3Title:
              user.permission.contains('read order masbro') ? "Antar" : null,
        ),
        body: tabs.isEmpty
            ? const Center(
                child: Text("Anda tidak memiliki akses ke riwayat."),
              )
            : TabBarView(
                children: tabs,
              ),
        bottomNavigationBar: NavbarHome(
          pageIndex:
              user.menu.indexWhere((element) => element.url == '/riwayat'),
        ),
      ),
    );
  }
}
