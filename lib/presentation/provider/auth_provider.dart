import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/auth_remote_data_source.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/views/common/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final tokenManager = TokenManager();
  UserModel? _user;

  UserModel get user => _user!;

  Future<bool> register(String nama, String email, String password) async {
    try {
      bool? succes =
          await AuthRemoteDataSource().register(nama, email, password);
      // tokenManager.putToken(user.token);
      return succes;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  // Future<bool> login(String email, String password, String token) async {
  //   try {
  //     UserModel? user =
  //         await AuthRemoteDataSource().login(email, password, token);
  //     _user = user;
  //     tokenManager.putToken(user.token);
  //     print(user);
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }
  // Future<bool> login(String email, String password, String token) async {
  //   try {
  //     UserModel? user =
  //         await AuthRemoteDataSource().login(email, password, token);
  //     _user = user;
  //     tokenManager.putToken(user.token);
  //     tokenManager.saveRoles(user.role);
  //     print(user);
  //     return true;
  //   } catch (e) {
  //     print(e);
  //     rethrow;
  //   }
  // }

  Future<bool> login(String email, String password, String token) async {
    try {
      UserModel? user =
          await AuthRemoteDataSource().login(email, password, token);
      _user = user;

      tokenManager.putToken(user.token);
      tokenManager.saveRoles(user.role);

      // Default set status jadi buka saat login
      // await updateTenantStatus(user.token, true);
      log("IS ONLINE FROM SERVER: ${user.isOnline}");

      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> logout(String token) async {
    try {
      await AuthRemoteDataSource().logout(token);
      _user = null;
      tokenManager.clearTokenAndRole();
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
      UserModel result = await AuthRemoteDataSource().loginWithToken(
        (await tokenManager.getToken())!,
      );

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

  Future<void> updateTenantStatus(String token, bool status) async {
    try {
      await TenantRemoteDataSource().updateStatusTenant(token, status);
      _user?.isOnline = status; // Ubah langsung
      notifyListeners(); // Beritahu widget bahwa state berubah
    } catch (e) {
      print("Error updating tenant status: $e");
    }
  }
}
