import 'dart:convert';

import 'package:http/http.dart' as http;

Future<bool?> updateFoodTenant(url, status) async {
  final response = await http.put(Uri.parse(url),
      headers: {"content-type": "application/json"},
      body: jsonEncode({"status": status}));
  print(response.statusCode);
  if (response.hashCode == 200) {
    return true;
  } else {
    return false;
  }
}
