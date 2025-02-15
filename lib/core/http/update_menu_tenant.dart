import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';

Future<bool> updateMenuTenant(bool status, String auth, int id) async {
  final response = await http.post(
    Uri.parse('${MasbroConstants.url}/tenant/menu/$id'),
    headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    body: {'isReady': "${status ? 1 : 0}"},
  );
  print({"status code update pesanan": response.statusCode});
  if (response.statusCode == 200) {
    return true;
  } else {
    return false;
  }
}
