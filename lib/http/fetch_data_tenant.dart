import 'dart:convert';
import 'package:testgetdata/model/tenant_foods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

Future<TenantFoods> fetchTenantFoods(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    print(response.body);
    return TenantFoods.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Data cant be load');
  }
}
