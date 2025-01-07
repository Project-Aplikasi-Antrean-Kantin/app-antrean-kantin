// import 'dart:convert';
// import 'package:testgetdata/constants.dart';
// import 'dart:async';
// import 'package:http/http.dart' as http;
// import 'package:testgetdata/model/tenant_model.dart';

// Future<TenantModel> fetchKatalogTenant(String token) async {
//   final response = await http.get(
//     Uri.parse("${MasbroConstants.url}/tenant"),
//     headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
//   );

//   if (response.statusCode == 200) {
//     return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
//   } else {
//     throw Exception('Data cant be load');
//   }
// }

import 'dart:convert';
import 'dart:developer';
import 'package:testgetdata/constants.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/model/tenant_model.dart';

Future<TenantModel> fetchKatalogTenant(String token) async {
  try {
    final response = await http.get(
      Uri.parse("${MasbroConstants.url}/tenant"),
      headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
    } else if (response.statusCode == 401) {
      // Log untuk unauthorized access
      print(
          "Unauthorized: You do not have access to fetch this data. Please check your token.");
      throw Exception('Unauthorized Access');
    } else {
      // Log untuk error lainnya
      log("Failed to load data. Status code: ${response.statusCode}");
      throw Exception('Data can\'t be loaded');
    }
  } catch (e) {
    // Log untuk error yang tidak terduga
    print("An error occurred: $e");
    throw Exception('Failed to fetch data');
  }
}
