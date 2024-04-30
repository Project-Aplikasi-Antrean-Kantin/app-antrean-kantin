import 'dart:convert';
import 'dart:developer';

import 'package:testgetdata/constants.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:http/http.dart' as http;

Future<UserModel> loginWithToken(String token) async {
  var url = '${MasbroConstants.url}/auth';
  var headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  final response = await http.get(Uri.parse(url), headers: headers);

  print(response.body);

  if (response.statusCode == 200) {
    var data = jsonDecode(response.body)['data'];
    log("SUKSES DI SERVIS");
    UserModel user = UserModel.fromJson(data);
    return user;
  } else {
    log("SUKSES DI SERVIS");
    throw jsonDecode(response.body)['message'];
  }
}
