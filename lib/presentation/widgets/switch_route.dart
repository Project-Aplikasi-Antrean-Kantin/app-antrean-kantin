// feature_router.dart
import 'package:flutter/material.dart';
import 'package:testgetdata/presentation/views/pembeli/home_page.dart';
import 'package:testgetdata/presentation/views/penjual/kasir_page.dart';
import 'package:testgetdata/presentation/views/pembeli/profile_page.dart';
import 'package:testgetdata/presentation/views/pembeli/riwayat_page_as_role.dart';
import 'package:testgetdata/presentation/views/pengantar/pengantaran_page.dart';
import 'package:testgetdata/presentation/views/penjual/pesanan_page.dart';

Widget getFeaturePage(String url) {
  switch (url) {
    case '/beranda':
      return HomePage();
    case '/pengantaran':
      return PerluPengantaran();
    case '/pesanan':
      return PesananTenant();
    case '/riwayat':
      return RiwayatPageAsRole();
    case '/profile':
      return ProfilePage();
    case '/kasir':
      return KasirPage();
    default:
      return const Center(
        child: Text('Page not found'),
      );
  }
}
