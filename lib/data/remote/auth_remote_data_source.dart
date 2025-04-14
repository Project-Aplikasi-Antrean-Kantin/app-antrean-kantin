import 'dart:convert';
import 'dart:developer';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
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
      // print(response.body);
      final json = jsonDecode(response.body);
      String message = json['message'].toString();

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      }
      print(json);
      throw ApiException(status: json['status'], message: message);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password, String token) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/login"),
        body: jsonEncode(
            {"email": email, "password": password, "fcm_token": token}),
        headers: {"content-type": "application/json"},
      );

      final json = jsonDecode(response.body);
      String message = json['message'].toString();

      if (response.statusCode == 200) {
        UserModel user = UserModel.fromJson(json['data']);
        if (user.isBlank!) {
          print(user.menu.toString());
        }
        return user;
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      }
      print(json);
      throw ApiException(status: json['status'], message: message);
    } catch (e) {
      rethrow;
    }
  }
  // Future<UserModel> login(String email, String password, String token) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse("${MasbroConstants.url}/login"),
  //       body:
  //           jsonEncode({"email": email, "password": password, "token": token}),
  //       headers: {"content-type": "application/json"},
  //     );

  //     final json = jsonDecode(response.body);
  //     String message = json['message'].toString();

  //     if (response.statusCode == 200) {
  //       UserModel user = UserModel.fromJson(json['data']);
  //       if (user.isBlank!) {
  //         print(user.menu.toString());
  //       }
  //       return user;
  //     } else if (response.statusCode == 401) {
  //       throw ApiException(status: json['status'], message: message);
  //     }
  //     print(json);
  //     throw ApiException(status: json['status'], message: message);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  Future<UserModel> loginWithToken(String token) async {
    var url = '${MasbroConstants.url}/auth';
    var headers = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };

    final response = await http.get(Uri.parse(url), headers: headers);

    print(response.body);

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body)['data'];
      log("SUKSES DI SERVIS");
      UserModel user = UserModel.fromJson(data);
      return user;
    } else {
      log("SUKSES DI SERVIS");
      throw jsonDecode(response.body)['message'];
    }
  }

  Future<bool> logout(String token) async {
    try {
      final response = await http.post(
        Uri.parse("${MasbroConstants.url}/logout"),
        headers: {
          "content-type": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      // print(response.body);
      final json = jsonDecode(response.body);
      String message = json['message'].toString();

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw ApiException(status: json['status'], message: message);
      }
      print(json);
      throw ApiException(status: json['status'], message: message);
    } catch (e) {
      rethrow;
    }
  }
}
