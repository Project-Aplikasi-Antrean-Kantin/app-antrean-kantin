import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';

class KasirProvider extends ChangeNotifier {
  List<CashierTransaction> cashierTransactions = [];
  bool isLoading = false;

  void addCashierTransaction(CashierTransaction cashierTransaction) {
    cashierTransactions.add(cashierTransaction);
    notifyListeners();
  }

  void deleteCashierTransaction(CashierTransaction cashierTransaction) {
    cashierTransactions.remove(cashierTransaction);
    notifyListeners();
  }

  Future<void> getListCashierTransaction(String token) async {
    isLoading = true;
    notifyListeners();
    try {
      final result =
          await TransactionRemoteDataSource().getListCashierTransaction(token);
      cashierTransactions = result;
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
