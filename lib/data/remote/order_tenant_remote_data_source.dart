import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class OrderTenantRemoteDataSource {
  // Future<List<Pesanan>> getOrderCustomer(String auth, status) async {
  //   final response = await http.get(
  //     Uri.parse('${MasbroConstants.url}/tenant/order?status=$status'),
  //     headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  //   );

  //   debugPrint(response.statusCode.toString());
  //   log("Response body: ${response.body}");

  //   if (response.statusCode == 200) {
  //     final dynamic jsonData = jsonDecode(response.body)['data'];

  //     List<dynamic> pesananList = [];

  //     if (jsonData is Map<String, dynamic>) {
  //       // Jika jsonData adalah Map, ambil semua value-nya
  //       pesananList = jsonData.values.toList();
  //     } else if (jsonData is List<dynamic>) {
  //       // Jika jsonData sudah berupa List, langsung pakai
  //       pesananList = jsonData;
  //     } else {
  //       throw Exception("Format data tidak valid");
  //     }

  //     debugPrint("iki respon e pesanan pembeli bro: $pesananList");
  //     return pesananList.map((e) => Pesanan.fromJson(e)).toList();
  //   } else {
  //     debugPrint(response.statusCode.toString());
  //     throw Exception('Data cant be load');
  //   }
  // }
  Future<List<Pesanan>> getOrderCustomer(
      BuildContext context, String auth, String status) async {
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/tenant/order?status=$status'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );

    debugPrint("Status Code: ${response.statusCode}");
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
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Redirect ke login jika token tidak valid
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return []; // Bisa juga pakai: return Future.error("Unauthorized");
    } else {
      debugPrint("Error: ${response.statusCode}");
      throw Exception('Data can\'t be loaded');
    }
  }

  Future<bool> updateOrderCustomer(String status, String auth, int id) async {
    try {
      print("Starting request to update order...");
      print("Request URL: ${MasbroConstants.url}/tenant/order/$id");
      print("Authorization token: $auth");
      print("Order status to update: $status");

      final response = await http.put(
        Uri.parse('${MasbroConstants.url}/tenant/order/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json'
        },
        body: {'status': "$status"},
      );

      print("HTTP response received. Status code: ${response.statusCode}");

      final json = jsonDecode(response.body);
      String message = json['message'].toString();
      print("Response message: $message");

      if (response.statusCode == 200) {
        print("Order update successful!");
        return true;
      } else {
        print("Failed to update order. Throwing exception...");
        throw ApiException(status: 'failed', message: message);
      }
    } catch (e) {
      print("An error occurred while updating the order: $e");
      throw Exception('Failed to update order');
    }
  }

  Future<bool> cancelOrderCustomer(String auth, int id) async {
    try {
      print("Starting request to update order...");
      print("Request URL: ${MasbroConstants.url}/tenant/order/$id");
      print("Authorization token: $auth");

      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/order/cancel/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json'
        },
      );

      print("HTTP response received. Status code: ${response.statusCode}");

      final json = jsonDecode(response.body);
      String message = json['message'].toString();
      print("Response message: $message");

      if (response.statusCode == 200) {
        print("Order update successful!");
        return true;
      } else {
        print("Failed to update order. Throwing exception...");
        throw ApiException(status: 'failed', message: message);
      }
    } catch (e) {
      print("An error occurred while updating the order: $e");
      throw Exception('Failed to update order');
    }
  }
}
