import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/coin_transaction_model.dart';
import 'package:testgetdata/data/remote/coin_remote_data_source.dart';

class CoinProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool _isLoadMore = false;
  int saldoKoin = 0;
  int totalPrice = 0;
  List<CoinTransactionModel> transactionCoin = [];
  int currentPage = 1;
  int maxPage = 1;
  bool get isLoading => _isLoading;
  bool get isLoadMore => _isLoadMore;

  Future<void> getCoinAmount(String token) async {
    _isLoading = true;
    try {
      final fetchedData = await CoinRemoteDataSource().getCoinAmount(token);

      // Log nilai saldo_koin yang diterima dari API

      saldoKoin = fetchedData!.saldoKoin; // Default ke 0 jika null
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching saldo koin: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getHistoryCoin(String token, bool isInitialFetch) async {
    if (isLoading || isLoadMore) return;
    if (maxPage != 1) {
      if (isInitialFetch) {
        transactionCoin = [];
        maxPage = 1;
      }
      // kasih notify biar UI update
      _isLoading = false;
      _isLoadMore = false;
      notifyListeners();
      return;
    }

    if (isInitialFetch) {
      transactionCoin = [];
      currentPage = 1;
      _isLoading = true;
    } else {
      _isLoadMore = true;
    }
    notifyListeners();

    try {
      final fetchedData = await CoinRemoteDataSource()
          .getHistoryTransactionCoin(token, currentPage);
      print("currentPage $currentPage");
// Gabungin semua data lama + baru
      final combined = [...transactionCoin, ...fetchedData];

// Unik berdasarkan id
      transactionCoin = combined
          .fold<Map<int, CoinTransactionModel>>({}, (map, tx) {
            map[tx.id] = tx;
            return map;
          })
          .values
          .toList();

      if (fetchedData.isNotEmpty) {
        currentPage++;
      } else {
        maxPage = currentPage;
      }

      log(transactionCoin.toString());
    } catch (error) {
      debugPrint('Error fetching transaction: $error');
      transactionCoin = [];
    } finally {
      _isLoading = false;
      _isLoadMore = false;
      notifyListeners();
    }
  }
}
