import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/exceptions/api_exception.dart';

Future<bool> updatePesanan(String status, String auth, int id) async {
  final response = await http.put(
    Uri.parse('${MasbroConstants.url}/tenant/order/$id'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    body: {'status': "$status"},
  );
  final json = jsonDecode(response.body);
  String message = json['message'].toString();
  print({"status code update pesanan": response.statusCode});
  if (response.statusCode == 200) {
    return true;
  } else {
    throw ApiException(status: 'failed', message: message);
    // return false;
  }
}
