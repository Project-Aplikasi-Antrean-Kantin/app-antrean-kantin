import 'dart:convert';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Pesanan>> fetchPengantaran(String auth, status) async {
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
