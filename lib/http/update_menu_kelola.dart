import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:testgetdata/constants.dart';

Future<bool> updateMenuKelola(String auth, String data, int id) async {
  print(data);
  final response = await http.put(
    Uri.parse('${MasbroConstants.url}/tenant/menu/$id'),
    headers: {
      'Authorization': "Bearer $auth",
      'Accept': 'application/json',
      HttpHeaders.contentTypeHeader: 'application/json'
    },
    body: (data),
  );
  print(response.body);
  if (response.statusCode == 200) {
    return true;
  } else {
    print(response.statusCode);
    return false;
  }
}

Future<bool> updateMenuKelolaFile(
    String auth, Map<String, dynamic> data, int id) async {
  var request = http.MultipartRequest(
      'POST', Uri.parse('${MasbroConstants.url}/tenant/menu/$id'));
  request.headers.addAll({
    'Authorization': "Bearer $auth",
    'Accept': 'application/json',
    HttpHeaders.contentTypeHeader: 'multipart/form-data'
  });
// Add form fields
  print(data);
  data.forEach((key, value) async {
    print(key);
    print(value);
    if (key == "gambar") {
      if (value != null) {
        File file = File(value);
        List<int> fileBytes = file.readAsBytesSync();
        print('panjang file : ${fileBytes.length}');
        request.files.add(await http.MultipartFile.fromBytes(
            'gambar', fileBytes,
            filename: 'bere'));
      }
    } else {
      request.fields[key] = value.toString();
    }
  });
// Add files

  try {
    final response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      print(response.statusCode);
      return true;
    } else {
      print(response.statusCode);
      return false;
    }
  } catch (e) {
    return false;
  }
}
