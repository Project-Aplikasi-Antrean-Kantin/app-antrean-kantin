// feature_router.dart
import 'package:flutter/material.dart';
import 'package:testgetdata/views/home/pages/beranda/home_page.dart';
import 'package:testgetdata/views/tenant/pages/kasir/kasir_page.dart';
import 'package:testgetdata/views/home/pages/profile/profile_page.dart';
import 'package:testgetdata/views/home/pages/riwayat/riwayat_page_as_role.dart';
import 'package:testgetdata/views/masbro/pages/pengantaran_page.dart';
import 'package:testgetdata/views/tenant/pages/pesanan/pesanan_page.dart';

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
