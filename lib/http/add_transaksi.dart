import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:testgetdata/constants.dart';

Future<bool> addTransaksi(String auth, String data) async {
  final response = await http.post(
    Uri.parse('${MasbroConstants.url}/order'),
    headers: {
      'Authorization': "Bearer $auth",
      'Accept': 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json'
    },
    body: (data),
  );
  if (response.statusCode == 201) {
    return true;
  } else {
    print(response.statusCode);
    // print();
    return false;
  }
}
