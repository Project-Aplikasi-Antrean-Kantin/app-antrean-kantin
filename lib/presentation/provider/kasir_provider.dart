import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/cashier_transaction.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';

class KasirProvider extends ChangeNotifier {
  List<CashierTransaction> cashierTransactions = [];
  bool isLoading = false;
  bool submittingCashierTransaction = false;
  TenantModel? tenant;

  void addCashierTransaction(CashierTransaction cashierTransaction) {
    cashierTransactions.add(cashierTransaction);
    notifyListeners();
  }

  void setTenant(TenantModel tenant) {
    this.tenant = tenant;
    notifyListeners();
  }

  void deleteCashierTransaction(CashierTransaction cashierTransaction) {
    cashierTransactions.remove(cashierTransaction);
    notifyListeners();
  }

  void updateCashierTransactionState(CashierTransaction updatedTransaction) {
    int index = cashierTransactions
        .indexWhere((element) => element.id == updatedTransaction.id);

    if (index == -1) return;

    final existingTransaction = cashierTransactions[index];

    // 1️⃣ Ambil list transaksi baru (hapus yang gak ada di updated)
    final updatedDetails = existingTransaction.listTransaksiDetail
        .where((detail) => updatedTransaction.listTransaksiDetail.any(
              (u) =>
                  u.menusKelolaId == detail.menusKelolaId &&
                  u.catatan == detail.catatan,
            ))
        .map((detail) {
      // 2️⃣ Update data yang masih ada
      final matchingUpdatedDetail =
          updatedTransaction.listTransaksiDetail.firstWhere(
        (u) =>
            u.menusKelolaId == detail.menusKelolaId &&
            u.catatan == detail.catatan,
      );

      return detail.copyWith(
        jumlah: matchingUpdatedDetail.jumlah,
        harga: matchingUpdatedDetail.harga,
      );
    }).toList();

    // 3️⃣ Tambahkan item baru yang belum ada di existing
    for (var newDetail in updatedTransaction.listTransaksiDetail) {
      final exists = updatedDetails.any((d) =>
          d.menusKelolaId == newDetail.menusKelolaId &&
          d.catatan == newDetail.catatan);
      if (!exists) {
        updatedDetails.add(newDetail);
      }
    }

    // 4️⃣ Update transaksi di list utama
    cashierTransactions[index] = existingTransaction.copyWith(
      total: updatedTransaction.total ?? existingTransaction.total,
      listTransaksiDetail: updatedDetails,
    );

    notifyListeners();
  }

  Future<void> updateStatusCashierTransaction(
      String auth, String newStatus, int id) async {
    try {
      final result =
          await TransactionRemoteDataSource().updateStatusCashierTransaction(
        auth,
        newStatus,
        id.toString(),
      );
      if (result) {
        int index =
            cashierTransactions.indexWhere((element) => element.id == id);
        cashierTransactions[index] = cashierTransactions[index].copyWith(
          status: newStatus,
        );
        notifyListeners();
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateCashierTransaction(
      BuildContext context, String token, String data, String id) async {
    submittingCashierTransaction = true;
    notifyListeners();
    try {
      final result = await TransactionRemoteDataSource()
          .updateCashierTransaction(token, data, id);

      updateCashierTransactionState(result);
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    } finally {
      submittingCashierTransaction = false;
      notifyListeners();
    }
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
