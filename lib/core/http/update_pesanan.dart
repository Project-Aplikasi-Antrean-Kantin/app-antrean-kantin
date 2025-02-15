// import 'dart:convert';

// import 'package:http/http.dart' as http;
// import 'package:testgetdata/constants.dart';
// import 'package:testgetdata/exceptions/api_exception.dart';

// Future<bool> updatePesanan(String status, String auth, int id) async {
//   final response = await http.put(
//     Uri.parse('${MasbroConstants.url}/tenant/order/$id'),
//     headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
//     body: {'status': "$status"},
//   );
//   final json = jsonDecode(response.body);
//   String message = json['message'].toString();
//   print({"status code update pesanan": response.statusCode});
//   if (response.statusCode == 200) {
//     return true;
//   } else {
//     throw ApiException(status: 'failed', message: message);
//     // return false;
//   }
// }

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';

Future<bool> updatePesanan(String status, String auth, int id) async {
  try {
    print("Starting request to update order...");
    print("Request URL: ${MasbroConstants.url}/tenant/order/$id");
    print("Authorization token: $auth");
    print("Order status to update: $status");

    final response = await http.put(
      Uri.parse('${MasbroConstants.url}/tenant/order/$id'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
      body: {'status': "$status"},
    );

    print("HTTP response received. Status code: ${response.statusCode}");

    final json = jsonDecode(response.body);
    String message = json['message'].toString();
    print("Response message: $message");

    if (response.statusCode == 200) {
      print("Order update successful!");
      return true;
    } else {
      print("Failed to update order. Throwing exception...");
      throw ApiException(status: 'failed', message: message);
    }
  } catch (e) {
    print("An error occurred while updating the order: $e");
    throw Exception('Failed to update order');
  }
}
