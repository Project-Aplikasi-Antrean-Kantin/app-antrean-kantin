import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/cashback.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/model/voucher_model.dart';

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

      if (response.statusCode == 201) {
        return OrderModel.fromJson(jsonBody);
      } else if (response.statusCode == 400)
        throw jsonBody['message'][0];
      else {
        throw '${jsonBody['message'][0]}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString()); // cukup pakai e
    }
  }

  Future<CashierTransaction> getCashierTransactionById(
      String auth, int id) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/tenant/kasir/riwayat/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
        },
      );

      final jsonBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CashierTransaction.fromJson(jsonBody['data']);
      } else if (response.statusCode == 400)
        throw jsonBody['message'];
      else {
        throw '${jsonBody['message']}';
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<bool> updateStatusCashierTransaction(
      String auth, String newStatus, String id) async {
    try {
      final response = await http.put(
        Uri.parse(
            '${MasbroConstants.url}/tenant/kasir/order/$id?status=$newStatus'),
        headers: {
          'Authorization': 'Bearer $auth',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        throw '${jsonDecode(response.body)['message']}';
      }
    } catch (e) {
      throw ('$e');
    }
  }

  Future<CashierTransaction> createCashierTransaction(
      String auth, String data) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/tenant/kasir'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: data,
      );

      final jsonBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return CashierTransaction.fromJson(jsonBody['data']);
      } else if (response.statusCode == 400)
        throw jsonBody['message'][0];
      else {
        throw '${jsonBody['message'][0]}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString()); // cukup pakai e
    }
  }

  Future<CashierTransaction> updateCashierTransaction(
      String auth, String data, String id) async {
    try {
      final response = await http.put(
        Uri.parse('${MasbroConstants.url}/tenant/kasir/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: data,
      );

      final jsonBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return CashierTransaction.fromJson(jsonBody['data']);
      } else if (response.statusCode == 400)
        throw jsonBody['message'];
      else {
        throw '${jsonBody['message']}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString()); // cukup pakai e
    }
  }

  Future<List<CashierTransaction>> getListCashierTransaction(
      String auth) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/tenant/kasir/riwayat'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
      );

      final jsonBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return (jsonBody['data'] as List)
            .map((e) => CashierTransaction.fromJson(e))
            .toList();
      } else if (response.statusCode == 400)
        throw jsonBody['message'][0];
      else {
        throw '${jsonBody['message'][0]}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw Exception(e.toString()); // cukup pakai e
    }
  }

  Future<Voucher> claimCashback(String auth, String referralCode) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/get/voucher/$referralCode'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
      );

      final jsonBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return Voucher.fromJson(jsonBody['data']);
      } else if (response.statusCode == 400)
        throw jsonBody['message'];
      else {
        throw '${jsonBody['message']}';
      }
    } catch (e) {
      print('An error occurred: $e');
      throw (e.toString()); // cukup pakai e
    }
  }

  Future<List<Voucher>> getVoucherData(String token) async {
    final response = await http.get(
      Uri.parse("${MasbroConstants.url}/list/voucher/active"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['data'] as List<dynamic>;
      return jsonData.map((e) => Voucher.fromJson(e)).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)["message"],
      );
    }
  }

  Future<List<Cashback>> getCashbackData(String token) async {
    final response = await http.get(
      Uri.parse("${MasbroConstants.url}/list/cashback/active"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body)['data'] as List<dynamic>;
      return jsonData.map((e) => Cashback.fromJson(e)).toList();
    } else {
      throw Exception(
        jsonDecode(response.body)["message"],
      );
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
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/order/$role?page=$page&per_page=5'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body)['data']['data'] as List<dynamic>;
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
      throw Exception('Data can\'t be loaded');
    }
  }

  Future<Pesanan> getOrderById(String auth, String id) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/order/user/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json'
        },
      );
      // final jsonBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return Pesanan.fromJson(jsonDecode(response.body)["data"]["transaksi"]);
      } else {
        throw Exception('Data cant be load ${response.body}');
      }
    } catch (e) {
      throw Exception('Data cant be load: $e');
    }
  }
}
