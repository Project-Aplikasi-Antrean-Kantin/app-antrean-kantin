import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/provider/user_provider.dart';

Future<UserModel> LoginFuture(String email, String password) async {
  print('${email}k ${password}k');
  final response = await http.post(
    Uri.parse("http://192.168.1.14:8000/api/login"),
    body: jsonEncode({"email": email, "password": password}),
    // Uri.parse('http://masbrocanteen.me/api/transaction'),
    headers: {"content-type": "application/json"},
    // body: jsonEncode({
    //   "data": data
    // })
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
