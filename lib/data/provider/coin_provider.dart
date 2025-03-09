import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/http/add_transaksi.dart';
import 'package:testgetdata/core/http/get_saldo_coin.dart';
import 'package:testgetdata/data/model/order_model.dart';

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

  // Future<OrderModel> createTransaction(BuildContext context, String token) {
  //   print('isAntar : $_selectedDeliveryOption');
  //   print('sebelum add transaksi ' + toJson());
  //   orderSuccessful = true;
  //   notifyListeners();

  //   // Add transaction using server API
  //   return addTransaksi(token, toJson());
  // }

  // // Converts the current state to JSON format
  // String toJson() => jsonEncode({
  //       "isAntar": _selectedDeliveryOption,
  //       "total": totalPrice,
  //       "ruangan_id": roomId,
  //       "metode_pembayaran": paymentMethod,
  //       "ongkos_kirim":
  //           _selectedDeliveryOption == 1 ? getTotalItemCount() * 1000 : 0,
  //       "menus": _cartMenu.map((x) => x.toJson()).toList(),
  //     });

  Future<bool> deductCoin(String token, int jumlah) async {
    if (saldoKoin < jumlah) {
      debugPrint('Saldo koin tidak mencukupi');
      return false;
    }

    final url = Uri.parse('${MasbroConstants.url}/saldo/kurang');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token'
    };
    final body = jsonEncode({"jumlah": jumlah});

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          saldoKoin = data['saldo_koin']; // Update saldo koin dari response
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
