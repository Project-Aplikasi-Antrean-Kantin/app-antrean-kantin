import 'dart:convert';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/presentation/views/common/http_exception.dart';

class DriverDataSource {
  Future<List<Pesanan>> getOrderDelivery(String auth, status) async {
    final response = await http.get(
      Uri.parse('${MasbroConstants.url}/masbro/order?status=$status'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );
    print(response.statusCode);
    if (response.statusCode == 200) {
      final jsonData =
          jsonDecode(response.body)['data']['transaksi'] as List<dynamic>;
      // print(jsonData);
      return jsonData.map((e) => Pesanan.fromJson(e)).toList();
    } else {
      print(response.statusCode);
      throw Exception('Data cant be load');
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
    } else if (response.statusCode == 403) {
      throw CustomHttpException('Pesanan telah diantar oleh driver lain', 403);
    } else {
      return false;
    }
  }
}
