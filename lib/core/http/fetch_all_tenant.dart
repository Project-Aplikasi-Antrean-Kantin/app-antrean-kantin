import 'dart:convert';
// import 'dart:js_util';

import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/model/tenant_model.dart';

Future<List<TenantModel>> fetchTenant(String uri, String auth) async {
  final response = await http.get(
    Uri.parse(uri),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );
  final json = jsonDecode(response.body);
  String message = json['message'].toString();
  if (response.statusCode == 200) {
    final jsonData =
        jsonDecode(response.body)['data']['tenants'] as List<dynamic>;
    print(jsonData);
    return jsonData.map((e) => TenantModel.fromJson(e)).toList();
  } else {
    print(response.statusCode);
    throw ApiException(status: json['status'], message: message);
  }
}
