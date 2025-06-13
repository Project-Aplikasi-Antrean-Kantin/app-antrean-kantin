import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';

class HistoryProvider with ChangeNotifier {
  // State terpisah untuk setiap role
  final Map<String, List<Pesanan>> _listPesananByRole = {};
  final Map<String, bool> _isLoadingByRole = {};
  final Map<String, String?> _errorMessageByRole = {};
  final Map<String, DateTime?> _lastFetchTimeByRole = {};

  // Set untuk tracking request yang sedang berjalan
  final Set<String> _activeRequests = {};

  // Getter methods untuk setiap role
  List<Pesanan> getListPesanan(String role) => _listPesananByRole[role] ?? [];
  bool getIsLoading(String role) => _isLoadingByRole[role] ?? false;
  String? getErrorMessage(String role) => _errorMessageByRole[role];
  DateTime? getLastFetchTime(String role) => _lastFetchTimeByRole[role];

  // Method untuk mengecek apakah data perlu di-refresh
  bool shouldRefreshData(String role,
      {Duration maxAge = const Duration(minutes: 5)}) {
    final lastFetch = _lastFetchTimeByRole[role];
    if (lastFetch == null) return true;

    return DateTime.now().difference(lastFetch) > maxAge;
  }

  // Getter untuk backward compatibility (jika masih ada yang menggunakan)
  List<Pesanan> get listPesanan => [];
  bool get isLoading => false;
  String? get errorMessage => null;

  Future<void> fetchHistory(BuildContext context, UserModel user, String role,
      {bool forceRefresh = false}) async {
    // Skip jika sedang loading dan bukan force refresh
    if (_isLoadingByRole[role] == true && !forceRefresh) {
      return;
    }

    // Cancel request sebelumnya untuk role ini jika masih berjalan
    if (_activeRequests.contains(role)) {
      return;
    }

    _activeRequests.add(role);
    _isLoadingByRole[role] = true;
    _errorMessageByRole[role] = null;
    notifyListeners();

    try {
      final pesananList = await TransactionRemoteDataSource()
          .getHistory(context, user.token, role);

      // Cek apakah request masih aktif (tidak di-cancel)
      if (_activeRequests.contains(role)) {
        _listPesananByRole[role] = pesananList;
        _errorMessageByRole[role] = null;
        _lastFetchTimeByRole[role] = DateTime.now();
      }
    } catch (e) {
      if (_activeRequests.contains(role)) {
        _errorMessageByRole[role] = 'Gagal memuat riwayat: $e';
        _listPesananByRole[role] = [];
      }
    } finally {
      _activeRequests.remove(role);
      _isLoadingByRole[role] = false;
      notifyListeners();
    }
  }

  Future<void> refreshHistory(
      BuildContext context, UserModel user, String role) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    await fetchHistory(context, user, role, forceRefresh: true);
  }

  // Method untuk fetch data jika diperlukan
  Future<void> fetchHistoryIfNeeded(
      BuildContext context, UserModel user, String role) async {
    final shouldRefresh =
        shouldRefreshData(role) || getListPesanan(role).isEmpty;

    if (shouldRefresh) {
      await fetchHistory(context, user, role);
    }
  }

  // Method untuk clear data role tertentu
  void clearHistoryByRole(String role) {
    _listPesananByRole[role] = [];
    _isLoadingByRole[role] = false;
    _errorMessageByRole[role] = null;
    _lastFetchTimeByRole[role] = null;
    _activeRequests.remove(role);
    notifyListeners();
  }

  // Method untuk clear semua data
  void clearAllHistory() {
    _listPesananByRole.clear();
    _isLoadingByRole.clear();
    _errorMessageByRole.clear();
    _lastFetchTimeByRole.clear();
    _activeRequests.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _activeRequests.clear();
    super.dispose();
  }
}
