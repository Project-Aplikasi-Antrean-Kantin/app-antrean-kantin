import 'dart:convert';
import 'package:testgetdata/core/constants.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/model/tenant_model.dart';

Future<TenantModel> fetchPenjualanOffline(String token) async {
  final response = await http.get(
    Uri.parse("${MasbroConstants.url}/tenant"),
    headers: {'Authorization': 'Bearer $token', 'Accept': 'application/json'},
  );

  if (response.statusCode == 200) {
    return TenantModel.fromJson(jsonDecode(response.body)["data"]["tenant"]);
  } else {
    throw Exception('Data cant be load');
  }
}
