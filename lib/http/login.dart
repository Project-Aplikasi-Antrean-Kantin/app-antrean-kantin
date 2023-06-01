import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/user_provider.dart';

Future<UserModel> LoginFuture(String email, String password) async {
  final response = await http.post(
    Uri.parse("http://masbrocanteen.me/api/login"),
    body: jsonEncode({"email": email, "password": password}),
    headers: {"content-type": "application/json"},
  );
  if (response.statusCode == 200) {
    final json = jsonDecode(response.body);
    UserModel user = UserModel(
        id: json['data']['id'],
        name: json['data']['name'],
        token: json['token'],
        email: json['data']['email'],
        role: json['data']['role']['name']);
    return user;
  } else {
    throw "err";
  }
}
