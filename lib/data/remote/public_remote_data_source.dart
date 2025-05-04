import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

class PublicRemoteDataSource {
  Future<List<TenantModel>> getTenant(
      BuildContext context, String uri, String auth) async {
    final response = await http.get(
      Uri.parse(uri),
      headers: {'Authorization': "Bearer $auth", 'Accept': 'application/json'},
    );

    final json = jsonDecode(response.body);
    String message = json['message'].toString();

    if (response.statusCode == 200) {
      final jsonData = json['data']['tenants'] as List<dynamic>;
      print(jsonData);
      return jsonData.map((e) => TenantModel.fromJson(e)).toList();
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      // Jika token expired atau tidak valid, alihkan ke halaman login
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      });

      throw Exception('Unauthorized access: $message');
    } else {
      print(response.statusCode);
      throw ApiException(status: json['status'], message: message);
    }
  }

  Future<TenantModel> getTenantFoods(
      BuildContext context, String uri, String token) async {
    try {
      print("Starting request to fetch tenant foods...");
      print("Request URI: $uri");
      print("Using token: $token");

      final response = await http.get(
        Uri.parse(uri),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json'
        },
      );

      print("HTTP response received. Status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("Request successful.");
        return TenantModel.fromJson(
            jsonDecode(response.body)["data"]["tenant"]);
      } else if (response.statusCode == 401) {
        print("Unauthorized: Invalid token or access denied.");

        // Navigasi ke login page
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/login', (route) => false);
        });

        throw Exception('Unauthorized Access');
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Data can\'t be loaded');
      }
    } catch (e) {
      print("An error occurred while fetching tenant foods: $e");
      throw Exception('Failed to fetch tenant foods');
    }
  }

  Future<List<SettingsModel>> getOngkir(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/pengaturan'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Raw API Response: ${response.body}'); // Tambahkan log

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          List<dynamic> data = jsonResponse['data'];
          return data.map((json) => SettingsModel.fromJson(json)).toList();
        } else {
          throw Exception(
              'Failed to load settings: ${jsonResponse['message']}');
        }
      } else {
        throw Exception('Failed to load settings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching saldo: $e');
      return [];
    }
  }
}
