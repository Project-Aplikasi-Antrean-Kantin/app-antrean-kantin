import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String> LoginFuture(String email, String password) async {
  print('${email}k ${password}k');
  final response = await http.post(Uri.parse("http://192.168.1.31:8000/api/login"),
      body: jsonEncode({"email": email, "password": password}),
      // Uri.parse('http://masbrocanteen.me/api/transaction'),
      headers: {"content-type": "application/json"},
      // body: jsonEncode({
      //   "data": data
      // })
      );
  if (response.statusCode == 200) {
    print(jsonDecode(response.body).toString());
    return jsonDecode(response.body)['token'];
  } else {
    print("faala");
    return "gagal";
  }
}
