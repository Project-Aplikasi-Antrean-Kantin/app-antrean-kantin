import 'dart:convert';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/presentation/views/common/http_exception.dart';

class DriverDataSource {
  Future<({List<Pesanan>? pesanan, String? error})> getOrderDelivery(
    String auth,
    status,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/masbro/order?status=$status'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json',
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        final jsonData =
            jsonDecode(response.body)['data']['transaksi'] as List<dynamic>;

        return (
          pesanan: jsonData.map((e) => Pesanan.fromJson(e)).toList(),
          error: null,
        );
      } else {
        return (
          pesanan: null,
          error: 'Gagal memuat data. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('An error occurred: $e');
      return (
        pesanan: null,
        error: 'Terjadi kesalahan: $e',
      );
    }
  }

  Future<bool> updateOrderDelivery(String status, String auth, int id) async {
    final response = await http.put(
      Uri.parse('${MasbroConstants.url}/masbro/order/$id'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
      body: {'status': "$status"},
    );
    print({"status code update pesanan": response.statusCode});
    print({"body update pesanan": response.body});

    if (response.statusCode == 200) {
      return true;
    } else if (response.statusCode == 403 || response.statusCode == 400) {
      final body = jsonDecode(response.body);
      final message =
          body['message'] ?? 'Pesanan telah diantar oleh driver lain';
      throw CustomHttpException(message, 403);
    } else {
      return false;
    }
  }

  Future<({bool success, String? error})> pingCustomer(
      String auth, String id) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/masbro/ping-to-buyer/$id'),
        headers: {
          'Authorization': "Bearer $auth",
          'Accept': 'application/json'
        },
      );
      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return (
          success: true,
          error: null,
        );
      } else {
        return (
          success: false,
          error: json['message'].toString(),
        );
      }
    } catch (e) {
      return (
        success: false,
        error: e.toString(),
      );
    }
  }
}
