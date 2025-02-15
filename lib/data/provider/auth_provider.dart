import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testgetdata/core/http/login_with_token.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/services/auth_futrue.dart';
import 'package:testgetdata/presentation/views/common/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final tokenManager = TokenManager();
  UserModel? _user;

  UserModel get user => _user!;

  Future<bool> register(String nama, String email, String password) async {
    try {
      bool? succes = await AuthFuture().register(nama, email, password);
      // tokenManager.putToken(user.token);
      return succes;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      UserModel? user = await AuthFuture().login(email, password);
      _user = user;
      tokenManager.putToken(user.token);
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
      tokenManager.clearToken();
      print("Success Logout");
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> authWithToken({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      log("COKK");
      UserModel result = await loginWithToken((await tokenManager.getToken())!);

      _user = result;
      tokenManager.putToken(result.token);
      notifyListeners();
      return true;
    } on SocketException {
      errorCallback?.call("TUKU PAKTEAN SEK COKKKK");
      return false;
    } catch (error) {
      errorCallback?.call(error);
      return false;
    }
  }
}
