import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/transaction_remote_data_source.dart';

class HistoryProvider with ChangeNotifier {
  // State terpisah untuk setiap role
  final Map<String, List<Pesanan>> _listPesananByRole = {};
  final Map<String, bool> _isLoadingByRole = {};
  final Map<String, bool> _loadMoreDataByRole = {};
  final Map<String, bool> _alreadyAllFetchedByRole = {};
  final Map<String, String?> _errorMessageByRole = {};
  final Map<String, int> _currentPageByRole = {};
  final Map<String, DateTime?> _lastFetchTimeByRole = {};
  String unreadMessages = '';
  List<int> unreadMessagesList = [];
  List<int> availableChatList = [];

  // Set untuk tracking request yang sedang berjalan
  final Set<String> _activeRequests = {};

  // Getter methods untuk setiap role
  List<Pesanan> getListPesanan(String role) => _listPesananByRole[role] ?? [];
  Pesanan? selectedPesanan;

  bool getIsLoading(String role) => _isLoadingByRole[role] ?? false;
  bool getLoadMoreData(String role) => _loadMoreDataByRole[role] ?? false;
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
  bool get isLoading => false;
  String? get errorMessage => null;

  Future<void> fetchHistory(
      BuildContext context, UserModel user, String role, bool isInitialFetch,
      {bool forceRefresh = false}) async {
    print("ngefetch cak");
    // Skip jika sedang loading dan bukan force refresh
    if (_isLoadingByRole[role] == true && !forceRefresh) {
      return;
    }

    // Cancel request sebelumnya untuk role ini jika masih berjalan
    if (_activeRequests.contains(role)) {
      return;
    }

    if (_alreadyAllFetchedByRole[role] == true) return;

    _activeRequests.add(role);
    if (isInitialFetch) {
      _isLoadingByRole[role] = true;
    } else {
      _loadMoreDataByRole[role] = true;
    }

    _errorMessageByRole[role] = null;
    notifyListeners();
    final currentPage = isInitialFetch ? 1 : _currentPageByRole[role] ?? 1;

    try {
      final pesananList = await TransactionRemoteDataSource()
          .getHistory(context, user.token, role, currentPage);

      // Cek apakah request masih aktif (tidak di-cancel)
      if (_activeRequests.contains(role)) {
        final existing = _listPesananByRole[role] ?? [];
        final newData = pesananList.listPesanan ?? [];
        if (newData.isEmpty) _alreadyAllFetchedByRole[role] = true;

        _currentPageByRole[role] = pesananList.currentPage + 1;

// Gabungkan dengan prioritas data baru
        final mergedMap = {
          for (var p in [...existing, ...newData]) p.id: p,
        };

// Ambil values-nya (urutan: existing dulu, lalu newData override)
        _listPesananByRole[role] = mergedMap.values.toList();
      }
    } catch (e) {
      if (_activeRequests.contains(role)) {
        _errorMessageByRole[role] = 'Gagal memuat riwayat: $e';
        _listPesananByRole[role] = [];
      }
    } finally {
      _activeRequests.remove(role);
      _isLoadingByRole[role] = false;
      _loadMoreDataByRole[role] = false;
      notifyListeners();
    }
  }

  Future<void> saveUnreadMessages(int transaksiId) async {
    final prefs = await SharedPreferences.getInstance();
    if (!unreadMessagesList.contains(transaksiId))
      unreadMessagesList.add(transaksiId);
    if (!availableChatList.contains(transaksiId))
      availableChatList.add(transaksiId);
    unreadMessages = unreadMessagesList.join(',');
    await prefs.setString('available_chat', unreadMessages);
    await prefs.setString('unread', unreadMessages);
    notifyListeners();
  }

  Future<void> removeUnreadMessages(int transaksiId) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.reload();
    unreadMessagesList.remove(transaksiId);
    if (unreadMessagesList.isEmpty) {
      prefs.remove('unread');
      unreadMessages = '';
    } else {
      unreadMessages = unreadMessagesList.join(',');
      await prefs.setString('unread', unreadMessages);
    }
    notifyListeners();
  }

  Future<void> removeAvailableChat(int transaksiId) async {
    final prefs = await SharedPreferences.getInstance();
    availableChatList.remove(transaksiId);
    final availableChat = availableChatList.join(',');
    print('availableChat: $availableChat');
    await prefs.setString('available_chat', availableChat);
    notifyListeners();
  }

  Future<void> loadUnreadMessages() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final unread = prefs.getString('unread') ?? '';
    final availableChat = prefs.getString('available_chat') ?? '';
    availableChatList = availableChat.isEmpty
        ? []
        : availableChat.split(',').map(int.parse).toList();
    unreadMessagesList =
        unread.isEmpty ? [] : unread.split(',').map(int.parse).toList();
    print('Saved unreadwkwk: ${prefs.getString('unread')}');
    notifyListeners();
  }

  Future<void> refreshHistory(
      BuildContext context, UserModel user, String role) async {
    print("ngefetch cak");
    await Future.delayed(const Duration(seconds: 1)); // Simulasi delay
    await fetchHistory(context, user, role, true, forceRefresh: true);
  }

  // Method untuk fetch data jika diperlukan
  Future<void> fetchHistoryIfNeeded(
      BuildContext context, UserModel user, String role) async {
    final shouldRefresh =
        shouldRefreshData(role) || getListPesanan(role).isEmpty;

    if (shouldRefresh) {
      await fetchHistory(context, user, role, true);
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

  void updateSelectedPesanan(Pesanan updatedPesanan) {
    selectedPesanan = updatedPesanan;
    notifyListeners();
  }

  void updatedPesanan(Pesanan updatedPesanan, String role) {
    final index = _listPesananByRole[role]!
        .indexWhere((pesanan) => pesanan.id == updatedPesanan.id);
    if (index != -1) {
      _listPesananByRole[role]![index] = updatedPesanan;
      notifyListeners();
    }
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
