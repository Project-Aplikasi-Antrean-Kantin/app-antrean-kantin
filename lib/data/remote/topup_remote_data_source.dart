import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/top_up_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopupRemoteDataSource {
  Future<TopUpModel> addTopup(String token, String nominal) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    try {
      print('${MasbroConstants.url}/transaksi/topup');
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/transaksi/topup'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode({
          'nominal': nominal,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData =
            jsonDecode(response.body)['data']['topup'] as Map<String, dynamic>;
        final topUp = TopUpModel.fromJson(jsonData);
        final encoded = jsonEncode(topUp.toJson());
        sharedPreferences.setString('current_va', encoded);
        print('iki cak topup $topUp');
        return topUp;
      } else {
        throw Exception('Kesalahan dalam memuat data');
        // throw Exception('Data cant be load');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<TopUpModel> createQRIS(String token, String nominal) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    try {
      print('${MasbroConstants.url}/transaksi/topup/midtrans');
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/transaksi/topup/midtrans'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
        body: jsonEncode({
          'nominal': nominal,
        }),
      );
      print(response.body);
      if (response.statusCode == 200) {
        final jsonData =
            jsonDecode(response.body)['data']['topup'] as Map<String, dynamic>;
        print('iki cak topup $jsonData');
        final topUp = TopUpModel.fromJsonQris(jsonData);
        final encoded = jsonEncode(topUp.toJson());
        print('iki cak encoded $encoded');
        sharedPreferences.setString('current_va', encoded);
        print('iki cak topup $topUp');
        return topUp;
      } else {
        throw Exception('Data cant be load');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<TopUpModel> getTopup(String token, String kodeBayar) async {
    try {
      print('${MasbroConstants.url}/transaksi/get-top-up/$kodeBayar');

      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/transaksi/get-top-up/$kodeBayar'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
      );
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final jsonData =
            jsonDecode(response.body)['data']['topup'] as Map<String, dynamic>;
        final topUp = TopUpModel.fromJson(jsonData);
        return topUp;
      } else {
        throw Exception('Data cant be load');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }

  Future<TopUpModel> getTopUpQris(String token, String kodeMidtrans) async {
    try {
      print(
          '${MasbroConstants.url}/transaksi/get/topup/midtrans/$kodeMidtrans');

      final response = await http.get(
        Uri.parse(
            '${MasbroConstants.url}/transaksi/get/topup/midtrans/$kodeMidtrans'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
          HttpHeaders.contentTypeHeader: 'application/json'
        },
      );
      print("Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      if (response.statusCode == 200) {
        final jsonData =
            jsonDecode(response.body)['data']['topup'] as Map<String, dynamic>;
        final topUp = TopUpModel.fromJson(jsonData);
        return topUp;
      } else {
        throw Exception('Data cant be load');
      }
    } catch (e) {
      throw Exception('error: $e');
    }
  }
}
