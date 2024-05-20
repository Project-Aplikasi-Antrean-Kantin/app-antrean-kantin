import 'dart:convert';
// import 'dart:js_util';

import 'package:testgetdata/exceptions/api_exception.dart';
import 'package:testgetdata/model/tenant_foods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/model/tenant_model.dart';

// const String uri = 'http://192.168.1.36:8000/api/tenant/1';

// <<<<<<< HEAD
Future<List<TenantModel>> fetchTenant(String uri, String auth) async {
  final response = await http.get(
    Uri.parse(uri),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
  );
  final json = jsonDecode(response.body);
  String message = json['message'].toString();
  // print(json);
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
