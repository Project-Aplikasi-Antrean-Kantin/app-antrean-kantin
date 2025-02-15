import 'package:flutter/material.dart';
import 'package:testgetdata/core/constants.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
// import 'package:testgetdata/http/fetch_katalog_tenant.dart';

Future<bool> deleteMenu(String token, int menuId) async {
  final response = await http.delete(
    Uri.parse('${MasbroConstants.url}/tenant/menu/$menuId'),
    headers: {'Authorization': "Bearer $token", 'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    debugPrint('Menu berhasil dihapus');
    // fetchKatalogTenant(token);
    return true;
  } else {
    debugPrint('Gagal menghapus menu: ${response.statusCode}');
    throw Exception('Gagal hapus menu');
  }
}
