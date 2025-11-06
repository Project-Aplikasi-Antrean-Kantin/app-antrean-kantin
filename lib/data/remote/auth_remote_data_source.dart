import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/constants.dart';
import 'package:testgetdata/core/exceptions/api_exception.dart';
import 'package:testgetdata/data/model/user_model.dart';

class AuthRemoteDataSource {
  Future<bool> register(String nama, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/register"),
        body: jsonEncode({"name": nama, "email": email, "password": password}),
        headers: {"content-type": "application/json"},
      );
      final json = jsonDecode(response.body);
      String message = json['message'].toString();

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'last_send_verify_email', DateTime.now().toString());
        return true;
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      }
      throw ApiException(status: json['status'], message: message);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resendVerify(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/send-email-verification"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"email": email}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(response.body);
          throw ApiException(status: json['status'], message: json['message']);
        } else {
          throw ApiException(
            status: response.statusCode,
            message: 'Unknown error',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> sendEmailForgetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/forgot-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({"email": email}),
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(
            'last_send_reset_password', DateTime.now().toString());

        return true;
      } else {
        if (response.body.isNotEmpty) {
          final json = jsonDecode(response.body);
          throw ApiException(status: json['status'], message: json['message']);
        } else {
          throw ApiException(
            status: response.statusCode,
            message: 'Unknown error',
          );
        }
      }
    } catch (e) {
      print("Error caught: $e");
      return false;
    }
  }

  Future<bool> resetPassword(
    String email,
    String password,
    String confirmPassword,
    String token,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/reset-password"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          "email": email,
          "password": password,
          "password_confirmation": confirmPassword,
          "token": token,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        if (response.body.isNotEmpty) {
          throw ApiException(
              status: 'error',
              message: 'Waktu reset habis, silakan kirim ulang email.');
        } else {
          throw ApiException(
            status: response.statusCode,
            message: 'Unknown error',
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password, String token) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/login"),
        body: jsonEncode({
          "email": email,
          "password": password,
          "fcm_token": token,
        }),
        headers: {"content-type": "application/json"},
      );

      final json = jsonDecode(response.body);
      String message = json['message'].toString();
      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(json['data']);

        return user;
      } else if (response.statusCode == 400) {
        throw ApiException(status: json['status'], message: message);
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      } else if (response.statusCode == 403) {
        throw ApiException(status: json['status'], message: message);
      }
      throw ApiException(status: json['status'], message: 'Kesalahan Server');
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> fetchUserData(String token) async {
    try {
      final response = await http.get(
        Uri.parse("${MasbroConstants.url}/auth"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['status'] == 'success') {
          log(response.body);
          return UserModel.fromJson(jsonData['data']);
        } else {
          throw Exception('Failed to load user data: ${jsonData['message']}');
        }
      } else {
        throw Exception('Failed to load user data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching user data: $e');
    }
  }

  // Update profile user with compress image banggg uhuyy
  Future<bool> updateProfileUser(
    String token,
    Map<String, dynamic> data,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('${MasbroConstants.url}/update-user'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'multipart/form-data',
    });

    try {
      for (var entry in data.entries) {
        if (entry.key == 'image' && entry.value != null) {
          File file = File(entry.value);
          if (await file.exists()) {
            String fileName = file.path.split('/').last;
            request.files.add(
              await http.MultipartFile.fromPath(
                'image',
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

  Future<UserModel> loginWithToken(String token) async {
    var url = '${MasbroConstants.url}/auth';
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data);
      return user;
    } else {
      log("SUKSES DI SERVIS");
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<UserModel> authMe(String token) async {
    var url = '${MasbroConstants.url}/user';
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      UserModel user = UserModel.fromJson(data);
      return user;
    } else {
      log("SUKSES DI SERVIS");
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<bool> logout(String token) async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    final prefs = await SharedPreferences.getInstance();
    try {
      final response =
          await http.post(Uri.parse("${MasbroConstants.url}/logout"),
              headers: {
                "content-type": "application/json",
                "Authorization": "Bearer $token",
              },
              body: jsonEncode({'fcm_token': fcmToken}));
      final json = jsonDecode(response.body);
      String message = json['message'].toString();
      if (response.statusCode == 200) {
        prefs.clear();
        return true;
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      }
      throw ApiException(status: json['status'], message: message);
    } catch (e) {
      rethrow;
    }
  }
}
