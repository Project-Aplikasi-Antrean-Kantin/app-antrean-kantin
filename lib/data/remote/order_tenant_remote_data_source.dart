import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';

class OrderTenantRemoteDataSource {
  Future<List<Pesanan>> getOrderCustomer(
      BuildContext context, String auth, String status) async {
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/tenant/order?status=$status'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));

    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final dynamic jsonData = jsonDecode(response.body)['data'];
      List<dynamic> pesananList = jsonData is Map<String, dynamic>
          ? jsonData.values.toList()
          : jsonData is List<dynamic>
              ? jsonData
              : throw Exception("Format data tidak valid");

      return pesananList.map((e) => Pesanan.fromJson(e)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });
      return [];
    } else {
      throw Exception('Data can\'t be loaded');
    }
  }

  Future<bool> updateOrderCustomer(String status, String auth, int id) async {
    try {
      final response = await http.put(
        Uri.parse('${MasbroConstants.url}/tenant/order/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
        },
        body: {'status': status},
      ).timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
            status: 'failed', message: json['message'].toString());
      }
    } catch (e) {
      throw Exception('Failed to update order');
    }
  }

  Future<bool> cancelOrderCustomer(String auth, int id) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/order/cancel/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return true;
      } else {
        throw ApiException(
            status: 'failed', message: json['message'].toString());
      }
    } catch (e) {
      throw Exception('Failed to update order');
    }
  }
}
