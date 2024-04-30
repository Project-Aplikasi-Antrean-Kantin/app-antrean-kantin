import 'package:flutter/material.dart';
import 'package:testgetdata/model/user_model.dart';
import 'package:testgetdata/services/auth_futrue.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _user;

  UserModel get user => _user!;

  Future<bool> register(String nama, String email, String password) async {
    try {
      bool? succes = await AuthFuture().register(nama, email, password);
      return succes;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> login(String email, String password, String token) async {
    try {
      UserModel? user = await AuthFuture().login(email, password, token);
      _user = user;
      print(user);
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> logout(String token) async {
    try {
      await AuthFuture().logout(token);
      _user = null;
      print("Success Logout");
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }
}
