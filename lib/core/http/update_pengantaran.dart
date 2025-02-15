import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';

Future<bool> updatePengantaran(String status, String auth, int id) async {
  final response = await http.put(
    Uri.parse('${MasbroConstants.url}/masbro/order/$id'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    body: {'status': "$status"},
  );
  print({"status code update pesanan": response.statusCode});
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
