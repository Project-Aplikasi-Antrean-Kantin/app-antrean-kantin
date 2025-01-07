// import 'dart:convert';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:testgetdata/model/tenant_model.dart';

// Future<TenantModel> fetchTenantFoods(String uri, String token) async {
//   final response = await http.get(
//     Uri.parse(uri),
//     headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//   );

//   print("dancok");

//   if (response.statusCode == 200) {
//     print("object");
//     return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
//   } else {
//     throw Exception('Data cant be load');
//   }
// }

import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/model/tenant_model.dart';

Future<TenantModel> fetchTenantFoods(String uri, String token) async {
  try {
    print("Starting request to fetch tenant foods...");
    print("Request URI: $uri");
    print("Using token: $token");

    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    print("HTTP response received. Status code: ${response.statusCode}");

    if (response.statusCode == 200) {
      print("Request successful.");
      return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
    } else if (response.statusCode == 401) {
      print("Unauthorized: Invalid token or access denied.");
      throw Exception('Unauthorized Access');
    } else {
      print("Failed to load data. Status code: ${response.statusCode}");
      print("Response body: ${response.body}");
      throw Exception('Data can\'t be loaded');
    }
  } catch (e) {
    print("An error occurred while fetching tenant foods: $e");
    throw Exception('Failed to fetch tenant foods');
  }
}
