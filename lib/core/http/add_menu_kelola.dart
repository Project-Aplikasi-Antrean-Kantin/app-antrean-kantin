import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testgetdata/core/constants.dart';

Future<bool> addMenuKelola(String auth, String data) async {
  print(data);
  final response = await http.post(
    Uri.parse('${MasbroConstants.url}/tenant/menu'),
    headers: {
      'Authorization': "Bearer $auth",
      'Accept': 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json'
    },
    body: (data),
  );
  print(response.body);
  if (response.statusCode == 200) {
    final jsonData = jsonDecode(response.body)['data'] as Map<String, dynamic>;
    return true;
  } else {
    print(response.statusCode);
    return false;
    // throw Exception('Data cant be load');
  }
}

Future<bool> addMenuKelolaFile(String auth, Map<String, dynamic> data) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('${MasbroConstants.url}/tenant/menu'));
  request.headers.addAll({
    'Authorization': "Bearer $auth",
    'Accept': 'application/json',
    HttpHeaders.contentTypeHeader: 'multipart/form-data'
  });
// Add form fields
  data.forEach((key, value) async {
    if (key == "gambar") {
      if (value != null) {
        File file = File(value);
        List<int> fileBytes = file.readAsBytesSync();
        print('panjang file : ${fileBytes.length}');
        request.files.add(await http.MultipartFile.fromBytes(
            'gambar', fileBytes,
            filename: value));
      }
    } else {
      request.fields[key] = value.toString();
    }
  });

  final response = await request.send();
  print(response.statusCode);
  if (response.statusCode == 200) {
    return true;
  } else {
    print(response.statusCode);
    return false;
  }
}
