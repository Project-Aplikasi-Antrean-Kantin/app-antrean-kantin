import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';
import 'package:testgetdata/data/model/ruangan_model.dart';

Future<List<Ruangan>> fetchDataRuangan(String auth) async {
  final response = await http.get(
    Uri.parse('${MasbroConstants.url}/ruangan'),
    headers: {
      'Authorization': "Bearer $auth",
      'Accept': 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json'
    },
  );
  if (response.statusCode == 200) {
    final jsonData =
        jsonDecode(response.body)['data']['ruangan'] as List<dynamic>;
    return jsonData.map((e) => Ruangan.fromJson(e)).toList();
  } else {
    throw Exception(
      jsonDecode(response.body)["massage"],
    );
  }
}
