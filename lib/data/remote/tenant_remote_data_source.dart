import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

// Future<bool> addMenuKelola(String auth, String data) async {
//   print(data);
//   final response = await http.post(
//     Uri.parse('${MasbroConstants.url}/tenant/menu'),
//     headers: {
//       'Authorization': "Bearer $auth",
//       'Accept': 'application/json',
//       HttpHeaders.contentTypeHeader: 'application/json'
//     },
//     body: (data),
//   );
//   print(response.body);
//   if (response.statusCode == 200) {
//     final jsonData = jsonDecode(response.body)['data'] as Map<String, dynamic>;
//     return true;
//   } else {
//     print(response.statusCode);
//     return false;
//     // throw Exception('Data cant be load');
//   }
// }
class TenantRemoteDataSource {
  Future<bool> createMenuTenant(String auth, Map<String, dynamic> data) async {
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

  Future<TenantModel> getMenuTenant(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${MasbroConstants.url}/tenant"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return TenantModel.fromJson(
            jsonDecode(response.body)["data"]["tenant"]);
      } else if (response.statusCode == 401) {
        // Log untuk unauthorized access
        print(
            "Unauthorized: You do not have access to fetch this data. Please check your token.");
        throw Exception('Unauthorized Access');
      } else {
        // Log untuk error lainnya
        log("Failed to load data. Status code: ${response.statusCode}");
        throw Exception('Data can\'t be loaded');
      }
    } catch (e) {
      // Log untuk error yang tidak terduga
      print("Error in fetchData: $e");
      print("An error occurred: $e");
      throw Exception('Failed to fetch data');
    }
  }

  Future<bool> deleteMenuTenant(String token, int menuId) async {
    final response = await http.delete(
      Uri.parse('${MasbroConstants.url}/tenant/menu/$menuId'),
      headers: {'Authorization': "Bearer $token", 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      debugPrint('Menu berhasil dihapus');
      // fetchKatalogTenant(token);
      return true;
    } else {
      debugPrint('Gagal menghapus menu: ${response.statusCode}');
      throw Exception('Gagal hapus menu');
    }
  }

  Future<bool> updateMenuTenant(
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

  Future<bool> updateMenuisReady(bool status, String auth, int id) async {
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

  Future<bool> updateStatusTenant(String token, bool isOnline) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/update-user"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json', // Tambahkan ini
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'isOnline': isOnline,
        }),
      );
      log("Nilai isOnline yang dikirim: $isOnline");
      print("Nilai isOnline yang dikirim: $isOnline");
      print("Nilai isOnline yang dikirim: ${response.statusCode}");

      if (response.statusCode == 200) {
        log("success cokkkkk");
        log("status code update status tenant: ${response.statusCode}");
        log("body success: ${response.body}");
        return true;
      } else {
        log("Failed with status code: ${response.statusCode}, body: ${response.body}");
        return false;
      }
    } catch (e) {
      log("An error occurred: $e");
      throw Exception('Failed to update status buka tutup tenant');
    }
  }

  Future<TenantModel> fetchTenantData(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${MasbroConstants.url}/tenant/profile-tenant"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print('profile e tenant: ${response.body}');
        log(response.body);
        return TenantModel.fromJson(jsonData['tenant']);
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  Future<bool> updateProfileTenant(
      String token, Map<String, dynamic> data) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${MasbroConstants.url}/tenant/profile-tenant'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    try {
      for (var entry in data.entries) {
        if (entry.key == 'gambar' && entry.value != null) {
          File file = File(entry.value);
          if (await file.exists()) {
            String fileName = file.path.split('/').last;
            request.files.add(
              await http.MultipartFile.fromPath(
                'gambar',
                file.path,
                filename: fileName,
              ),
            );
          }
        } else if (entry.value != null) {
          request.fields[entry.key] = entry.value.toString();
        }
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print('Status Code: ${response.statusCode}');
      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        return true;
      } else {
        print('Failed to update user: $responseBody');
        return false;
      }
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
}
