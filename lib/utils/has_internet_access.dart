import 'package:http/http.dart' as http;

Future<bool> hasInternetAccess() async {
  try {
    final response = await http
        .get(
          Uri.parse('https://clients3.google.com/generate_204'),
        )
        .timeout(const Duration(seconds: 7));
    return response.statusCode == 204;
  } catch (e) {
    // log error kalau perlu
    return false;
  }
}
