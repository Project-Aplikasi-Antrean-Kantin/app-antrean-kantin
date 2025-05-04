import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/coin_model.dart';
import 'package:testgetdata/data/model/coin_transaction_model.dart';

class CoinRemoteDataSource {
  Future<CoinModel?> getCoinAmount(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/saldo'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Raw API Response: ${response.body}'); // Tambahkan log

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || !data.containsKey('saldo_koin')) {
          debugPrint(
              'Invalid API response: Data is null or missing saldo_koin');
          return CoinModel(
              saldoKoin: 0); // Default return jika tidak ada saldo_koin
        }

        return CoinModel(saldoKoin: data['saldo_koin']);
      } else {
        debugPrint(
            'Failed to fetch saldo. Status code: ${response.statusCode}');
        return CoinModel(saldoKoin: 0);
      }
    } catch (e) {
      debugPrint('Error fetching saldo: $e');
      return CoinModel(saldoKoin: 0);
    }
  }

  Future<List<CoinTransactionModel>> getHistoryTransactionCoin(
      String token) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/saldo/riwayat'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      debugPrint('Raw API Response Transaksi: ${response.body}');

      if (response.statusCode == 200) {
        // final jsonData =
        //     jsonDecode(response.body)['transaksi'] as List<dynamic>;
        final List<Map<String, dynamic>> jsonData =
            List<Map<String, dynamic>>.from(
          jsonDecode(response.body)['transaksi'],
        );

        return jsonData.map((e) => CoinTransactionModel.fromJson(e)).toList();
      } else {
        print(response.statusCode);
        throw Exception('Data cant be load');
      }
    } catch (e) {
      debugPrint('Error fetching transaksi: $e');
      return [];
    }
  }
}
