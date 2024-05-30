import 'dart:convert';
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/pesanan_model.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<List<Pesanan>> fetchRiwayat(String auth, String role) async {
  final response = await http.get(
    Uri.parse('${MasbroConstants.url}/order/$role'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );
  print(response.statusCode);
  if (response.statusCode == 200) {
    final jsonData =
        jsonDecode(response.body)['data']['transaksi'] as List<dynamic>;
    print("iki respon e bro: $jsonData");
    return jsonData.map((e) => Pesanan.fromJson(e)).toList();
  } else {
    print(response.statusCode);
    throw Exception('Data cant be load');
  }
}
