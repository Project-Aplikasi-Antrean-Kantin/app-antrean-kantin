import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';

class HistoryProvider with ChangeNotifier {
  List<Pesanan> _listPesanan = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Pesanan> get listPesanan => _listPesanan;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchHistory(
      BuildContext context, UserModel user, String role) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final pesananList = await TransactionRemoteDataSource()
          .getHistory(context, user.token, role);
      _listPesanan = pesananList;
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory(
      BuildContext context, UserModel user, String role) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    await fetchHistory(context, user, role);
  }
}
