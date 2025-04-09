import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/remote/get_saldo_coin.dart';

class CoinProvider extends ChangeNotifier {
  int saldoKoin = 0;
  bool isLoading = false;
  int totalPrice = 0;
  int? roomId;
  String? paymentMethod;
  bool orderSuccessful = false;

  int _selectedDeliveryOption = 1;
  int get selectedDeliveryOption => _selectedDeliveryOption;

  Future<void> fetchData(String token) async {
    isLoading = true;
    try {
      final fetchedData = await fetchSaldoCoin(token);

      // Log nilai saldo_koin yang diterima dari API
      debugPrint('Fetched Saldo Koin: ${fetchedData!.saldoKoin}');

      saldoKoin = fetchedData.saldoKoin; // Default ke 0 jika null
    } catch (e) {
      debugPrint('Error fetching saldo koin: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deductCoin(String token, int jumlah) async {
    try {
      // Fetch saldo terbaru langsung dari API
      final fetchedData = await fetchSaldoCoin(token);

      if (fetchedData == null || fetchedData.saldoKoin < jumlah) {
        debugPrint('Saldo koin tidak mencukupi (langsung dari API)');
        return false;
      }

      final url = Uri.parse('${MasbroConstants.url}/saldo/kurang');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final body = jsonEncode({"jumlah": jumlah});

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          saldoKoin =
              data['saldo_koin']; // Update saldo lokal setelah pengurangan
          notifyListeners();
          debugPrint('Saldo Koin berhasil dikurangi: $saldoKoin');
          return true;
        }
      }

      debugPrint('Gagal mengurangi saldo koin');
      return false;
    } catch (e) {
      debugPrint('Error saat mengurangi saldo koin: $e');
      return false;
    }
  }
}
