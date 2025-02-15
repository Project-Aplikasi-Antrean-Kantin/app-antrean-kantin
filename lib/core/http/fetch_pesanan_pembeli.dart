import 'dart:convert';
// import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Pesanan>> fetchPesananPembeli(String auth, status) async {
  final response = await http.get(
    Uri.parse('${MasbroConstants.url}/tenant/order?status=$status'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );
  debugPrint(response.statusCode.toString());
  if (response.statusCode == 200) {
    final jsonData =
        jsonDecode(response.body)['data']['pesanan'] as List<dynamic>;
    // print(jsonData);
    return jsonData.map((e) => Pesanan.fromJson(e)).toList();
  } else {
    debugPrint(response.statusCode.toString());
    throw Exception('Data cant be load');
  }
}
