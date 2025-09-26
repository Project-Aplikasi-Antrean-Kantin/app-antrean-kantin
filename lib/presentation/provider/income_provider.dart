import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/income_model.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';

class IncomeProvider extends ChangeNotifier {
  Income? selectedIncome;
  String selectedSort = "";
  DateTime date = DateTime.now();
  Map<String, Income>? groupedIncome;
  bool isLoading = true;

  void setIncome(Income? income) {
    this.selectedIncome = income;
    notifyListeners();
  }

  void clearProvider() {
    selectedIncome = null;
    groupedIncome = null;
    notifyListeners();
  }

  Future<void> setSelectedSort(String sort, String token) async {
    date = DateTime.now();
    selectedSort = sort;
    notifyListeners(); // update UI dulu biar langsung ke-detect perubahan

    await getIncome(token); // fetch income sesuai sort terbaru
  }

  Future<void> getIncome(String token) async {
    if (selectedSort == "") return;

    isLoading = true;
    notifyListeners();

    Income? income;
    try {
      if (selectedSort == "Minggu") {
        income = await TenantRemoteDataSource().getIncome(token,
            "tenant/penghasilan-transaksi-tenant?year=${date.year}&month=${date.month}&date=${date.day}");
      }
      if (selectedSort == "Bulan") {
        income = await TenantRemoteDataSource().getIncome(token,
            "tenant/penghasilan-transaksi-tenant?year=${date.year}&month=${date.month}");
      }
      if (selectedSort == "Tahun") {
        income = await TenantRemoteDataSource().getIncome(
            token, "tenant/penghasilan-transaksi-tenant?year=${date.year}");
      }

      // 🔑 Validasi manual: kalau data kosong → lempar exception custom
      if (income == null || income.labels.isEmpty) {
        throw Exception("Data kosong");
      }

      setIncome(income);
    } catch (e) {
      print("Error getIncome: $e");
      rethrow; // biar bisa ditangkap di next/prev
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextNewDate(String token) async {
    final backupDate = date;
    if (selectedSort == "Minggu") date = date.add(const Duration(days: 7));
    if (selectedSort == "Bulan") date = date.add(const Duration(days: 30));
    if (selectedSort == "Tahun") date = date.add(const Duration(days: 365));

    try {
      await getIncome(token);
    } catch (_) {
      date = backupDate; // rollback kalau data kosong
    }

    notifyListeners();
  }

  Future<void> prevNewDate(String token) async {
    final backupDate = date;
    if (selectedSort == "Minggu") date = date.subtract(const Duration(days: 7));
    if (selectedSort == "Bulan") date = date.subtract(const Duration(days: 30));
    if (selectedSort == "Tahun")
      date = date.subtract(const Duration(days: 365));

    try {
      await getIncome(token);
    } catch (_) {
      date = backupDate; // rollback kalau data kosong
    }

    notifyListeners();
  }
}
