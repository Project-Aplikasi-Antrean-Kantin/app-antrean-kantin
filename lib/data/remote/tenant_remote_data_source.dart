import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/income_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

class TenantRemoteDataSource {
  Future<TenantFoods?> createMenuTenant(
      String auth, Map<String, dynamic> data) async {
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
          request.files.add(await http.MultipartFile.fromBytes(
              'gambar', fileBytes,
              filename: value));
        }
      } else {
        request.fields[key] = value.toString();
      }
    });
    try {
      final response = await request.send();
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final data = jsonDecode(responseBody);

        return TenantFoods.fromJson(data["data"]["newMenu"]);
      } else {
        throw Exception('Failed to create menu');
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<Income> getIncome(String token, String url) async {
    try {
      final response = await http.get(
        Uri.parse("${MasbroConstants.url}/$url"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        return Income.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 401) {
        // Log untuk unauthorized access

        throw Exception('Unauthorized Access');
      } else {
        // Log untuk error lainnya
        log("Failed to load data. Status code: ${response.statusCode}");
        throw Exception('Data can\'t be loaded');
      }
    } catch (e) {
      // Log untuk error yang tidak terduga

      throw Exception('Failed to fetch data');
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

  Future<bool> updateBusy(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/tenant/interupt'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteMenuTenant(String token, int menuId) async {
    final response = await http.delete(
      Uri.parse('${MasbroConstants.url}/tenant/menu/$menuId'),
      headers: {'Authorization': "Bearer $token", 'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      // fetchKatalogTenant(token);
      return true;
    } else {
      throw Exception('Gagal hapus menu');
    }
  }

  Future<TenantFoods?> updateMenuTenant(
      String auth, Map<String, dynamic> data, int id) async {
    var request = http.MultipartRequest(
        'POST', Uri.parse('${MasbroConstants.url}/tenant/menu/$id'));
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
      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        debugPrint("responseBody ${responseBody}");
        final data = jsonDecode(responseBody);
        debugPrint("data ${data['data']['menu']}");

        return TenantFoods.fromJson(data["data"]["menu"]);
      } else {
        throw ("Gagal update menu");
      }
    } catch (e) {
      throw (e.toString());
    }
  }

  Future<bool> updateMenuisReady(bool status, String auth, int id) async {
    final response = await http.post(
      Uri.parse('${MasbroConstants.url}/tenant/menu/$id'),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
      body: {'isReady': "${status ? 1 : 0}"},
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  Future<({bool success, String? error})> updateTenantStatus(
    String token,
    bool status,
  ) async {
    try {
      final response = await http
          .post(
        Uri.parse("${MasbroConstants.url}/update-user"),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'isOnline': status}),
      )
          .timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException("Request timeout setelah 5 detik");
        },
      );

      log("Nilai isOnline yang dikirim: $status");
      log("Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        return (success: true, error: null);
      } else {
        // Coba ambil error message dari response.body
        String? message;
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? 'Gagal update status';
        } catch (e) {
          message = 'Gagal update status (tidak bisa parsing respons)';
        }
        log("Gagal update: $message");
        return (success: false, error: message);
      }
    } on TimeoutException catch (e) {
      return (success: false, error: e.message ?? 'Request timeout');
    } catch (e) {
      log("Terjadi kesalahan: $e");
      return (success: false, error: 'Terjadi kesalahan: $e');
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

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
