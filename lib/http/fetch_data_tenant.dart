import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/model/tenant_model.dart';

Future<TenantModel> fetchTenantFoods(String uri, String token) async {
  final response = await http.get(
    Uri.parse(uri),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  print("object");

  if (response.statusCode == 200) {
    print("object");
    return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
  } else {
    throw Exception('Data cant be load');
  }
}
