import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Pesanan>> fetchRiwayat(String auth, String role) async {
  final response = await http.get(
    Uri.parse('${MasbroConstants.url}/order/$role'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );
  debugPrint(response.statusCode.toString());
  if (response.statusCode == 200) {
    final jsonData =
        jsonDecode(response.body)['data']['transaksi'] as List<dynamic>;
    debugPrint("iki respon e bro: $jsonData");
    return jsonData.map((e) => Pesanan.fromJson(e)).toList();
  } else {
    debugPrint(response.statusCode.toString());
    throw Exception('Data cant be load');
  }
}
