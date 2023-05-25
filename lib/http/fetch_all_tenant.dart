import 'dart:convert';
// import 'dart:js_util';

import 'package:testgetdata/model/tenant_foods.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/model/tenant_model.dart';

// const String uri = 'http://192.168.1.36:8000/api/tenant/1';

Future<List<TenantModel>> fetchTenant(String uri) async {
  final response = await http.get(Uri.parse(uri));

  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body)['data'] as List<dynamic>;
    return jsonData.map((e) => TenantModel.fromJson(e)).toList();
  } else {
    print(response.statusCode);
    throw Exception('Data cant be load');
  }
}
