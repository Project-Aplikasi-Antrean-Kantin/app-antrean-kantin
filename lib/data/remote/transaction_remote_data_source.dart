import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

class TransactionRemoteDataSource {
  Future<OrderModel> createTransaction(String auth, String data) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/order'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: data,
      );

      log(response.statusCode.toString());
      if (response.statusCode == 201) {
        return OrderModel.fromJson(
          jsonDecode(
            response.body,
          ),
        );
      } else {
        print('Request failed with status: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw Exception();
      }
    } catch (e) {
      print('An error occurred: $e');
      // throw Exception(e);
      rethrow;
    }
  }

  Future<List<Ruangan>> getRoomData(String auth) async {
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/ruangan'),
      headers: {
        'Authorization': "Bearer $auth",
        'Accept': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
    );
    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body)['data']['ruangan'] as List<dynamic>;
      return jsonData.map((e) => Ruangan.fromJson(e)).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)["massage"],
      );
    }
  }

  Future<TenantModel> getCashierData(String token) async {
    final response = await http.get(
      Uri.parse("${MasbroConstants.url}/tenant"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
    } else {
      throw Exception('Data cant be load');
    }
  }

  Future<List<Pesanan>> getHistory(
      BuildContext context, String auth, String role) async {
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/order/$role'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );

    debugPrint("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body)['data']['transaksi'] as List<dynamic>;
      debugPrint("iki respon e bro: $jsonData");
      return jsonData.map((e) => Pesanan.fromJson(e)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Redirect ke login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return []; // atau bisa return Future.error("Unauthorized");
    } else {
      debugPrint("Error: ${response.statusCode}");
      throw Exception('Data can\'t be loaded');
    }
  }
}
