import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/data/model/review_selection.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
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
    print('message dari server: $json');

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

  Future<String> submitReview(
    String token,
    int rating,
    String description,
    List<int> ratingMoods,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${MasbroConstants.url}/ratings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'description': description,
          'rating_moods': ratingMoods,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['message'] as String;
      } else {
        throw Exception('Failed to submit review: ${response.body}');
      }
    } catch (e) {
      throw Exception('Failed to submit review: $e');
    }
  }

  Future<List<ReviewSelection>> getReviewSelection(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/rating-moods'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
        },
      );

      final json = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final jsonData = json['data'] as List<dynamic>;

        // ubah ke List<ReviewSelection>
        final list = jsonData.map((e) => ReviewSelection.fromJson(e)).toList();

        // urutkan berdasarkan 'order'
        list.sort((a, b) => a.order.compareTo(b.order));

        return list;
      } else {
        throw Exception('Failed to load review selection');
      }
    } catch (e) {
      throw Exception('Failed to load review selection');
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

  Future<TenantFoods> getTenantFoodsById(String menuId, String token) async {
    try {
      debugPrint('Fetching tenant foods for menu ID: $menuId');
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/menus/$menuId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );
      final json = jsonDecode(response.body);
      debugPrint('API Response: $json');
      return TenantFoods.fromJson(json['data']['menu']);
    } catch (e) {
      debugPrint('$e');
      throw Exception('Failed to fetch tenant foods');
    }
  }

  Future<List<SettingsModel>> getSettings() async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/pengaturan'),
        headers: {
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

  Future<int> isThereActiveDriver(String token) async {
    try {
      final response = await http.get(
        Uri.parse('${MasbroConstants.url}/order/driver'),
        headers: {
          'Authorization': "Bearer $token",
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      final json = jsonDecode(response.body);
      final data = json['data'];
      print('data nih bos:${data['jumlah_driver'] > 0}');

      return data['jumlah_driver'];
    } catch (e) {
      throw Exception('Failed to get driver active');
    }
  }
}
