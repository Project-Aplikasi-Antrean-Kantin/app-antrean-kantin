import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/auth_provider.dart';
import 'package:testgetdata/views/home/pages/navbar_home.dart';

class PenjualanOffline extends StatefulWidget {
  const PenjualanOffline({super.key});

  @override
  State<PenjualanOffline> createState() => _PenjualanOfflineState();
}

class _PenjualanOfflineState extends State<PenjualanOffline> {
  @override
  Widget build(BuildContext context) {
    AuthProvider authProvider = Provider.of<AuthProvider>(context);
    UserModel user = authProvider.user;
    return Scaffold(
      body: const Center(
        child: Text("Page penjualan offline"),
      ),
      bottomNavigationBar: NavbarHome(
        pageIndex: user.menu.indexWhere((element) => element.url == '/kasir'),
      ),
    );
  }
}
