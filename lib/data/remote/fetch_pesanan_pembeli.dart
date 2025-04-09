import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Pesanan>> fetchPesananPembeli(String auth, status) async {
  final response = await http.get(
    Uri.parse('${MasbroConstants.url}/tenant/order?status=$status'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );

  debugPrint(response.statusCode.toString());
  log("Response body: ${response.body}");

  if (response.statusCode == 200) {
    final dynamic jsonData = jsonDecode(response.body)['data'];

    List<dynamic> pesananList = [];

    if (jsonData is Map<String, dynamic>) {
      // Jika jsonData adalah Map, ambil semua value-nya
      pesananList = jsonData.values.toList();
    } else if (jsonData is List<dynamic>) {
      // Jika jsonData sudah berupa List, langsung pakai
      pesananList = jsonData;
    } else {
      throw Exception("Format data tidak valid");
    }

    debugPrint("iki respon e pesanan pembeli bro: $pesananList");
    return pesananList.map((e) => Pesanan.fromJson(e)).toList();
  } else {
    debugPrint(response.statusCode.toString());
    throw Exception('Data cant be load');
  }
}
