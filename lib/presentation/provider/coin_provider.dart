import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/coin_transaction_model.dart';
import 'package:testgetdata/data/remote/coin_remote_data_source.dart';

class CoinProvider extends ChangeNotifier {
  bool _isLoading = false;
  int saldoKoin = 0;
  int totalPrice = 0;
  List<CoinTransactionModel> transactionCoin = [];
  bool get isLoading => _isLoading;

  Future<void> getCoinAmount(String token) async {
    _isLoading = true;
    try {
      final fetchedData = await CoinRemoteDataSource().getCoinAmount(token);

      // Log nilai saldo_koin yang diterima dari API
      debugPrint('Fetched Saldo Koin: ${fetchedData!.saldoKoin}');

      saldoKoin = fetchedData.saldoKoin; // Default ke 0 jika null
    } catch (e) {
      debugPrint('Error fetching saldo koin: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getHistoryCoin(String token) async {
    _isLoading = true;

    try {
      final fetchedData =
          await CoinRemoteDataSource().getHistoryTransactionCoin(token);
      transactionCoin = fetchedData;
      log(transactionCoin.toString());
    } catch (error) {
      debugPrint('Error fetching transaction: $error');
      transactionCoin = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
