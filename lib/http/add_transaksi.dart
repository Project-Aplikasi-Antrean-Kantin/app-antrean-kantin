// import 'dart:async';
// import 'dart:io';
// import 'dart:math';

// import 'package:http/http.dart' as http;
// import 'package:testgetdata/constants.dart';

// Future<bool> addTransaksi(String auth, String data) async {
//   final response = await http.post(
//     Uri.parse('${MasbroConstants.url}/order'),
//     headers: {
//       'Authorization': "Bearer $auth",
//       'Accept': 'application/json',
//       HttpHeaders.contentTypeHeader: 'application/json'
//     },
//     body: (data),
//   );
//   if (response.statusCode == 201) {
//     return true;
//   } else {
//     print(response.statusCode);
//     // print();
//     return false;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/order_model.dart';

Future<OrderModel> addTransaksi(String auth, String data) async {
  try {
    final response = await http.post(
      Uri.parse('${MasbroConstants.url}/order'),
      headers: {
        'Authorization': "Bearer $auth",
        'Accept': 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json'
      },
      body: data,
    );

    log(response.statusCode.toString());
    if (response.statusCode == 201) {
      return OrderModel.fromJson(
        jsonDecode(
          response.body,
        ),
      );
    } else {
      print('Request failed with status: ${response.statusCode}');
      print('Error response body: ${response.body}');
      throw Exception();
    }
  } catch (e) {
    print('An error occurred: $e');
    throw Exception();
  }
}
