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

      final jsonBody = jsonDecode(response.body);
      // print('Response status code: ${jsonBody['message'][0]}');
      // print('Response body: ${jsonBody['data']['transaksi']}');

      if (response.statusCode == 201) {
        return OrderModel.fromJson(jsonBody);
      } else if (response.statusCode == 400)
        throw jsonBody['message'][0];
      else {
        print('Request failed with status: ${response.statusCode}');
        print('Error response body: ${response.body}');
        throw '${jsonBody['message'][0]}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString()); // cukup pakai e
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

  Future<({int currentPage, List<Pesanan>? listPesanan})> getHistory(
      BuildContext context, String auth, String role, int page) async {
    print("${MasbroConstants.url}/order/$role?page=$page&per_page=5");
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/order/$role?page=$page&per_page=5'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );

    debugPrint("Status Code: ${response.statusCode}");

    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body)['data']['data'] as List<dynamic>;
      debugPrint("iki respon e bro: $jsonData");
      return (
        currentPage: jsonDecode(response.body)['data']['current_page'] as int,
        listPesanan: jsonData.map((e) => Pesanan.fromJson(e)).toList()
      );
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Redirect ke login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return Future.error(
          "Unauthorized"); // atau bisa return Future.error("Unauthorized");
    } else {
      debugPrint("Error: ${response.statusCode}");
      throw Exception('Data can\'t be loaded');
    }
  }

  Future<Pesanan> getOrderById(String auth, String id) async {
    print("id kontol: $id");
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/order/user/$id'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );
    final jsonBody = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print(
          "Response body: ${(jsonBody['data']['transaksi']['metode_pembayaran'])}");
      return Pesanan.fromJson(jsonDecode(response.body)["data"]["transaksi"]);
    } else {
      throw Exception('Data cant be load');
    }
  }
}
