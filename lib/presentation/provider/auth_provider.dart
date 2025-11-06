import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/settings_model.dart';
import 'package:testgetdata/data/model/user_model.dart';
import 'package:testgetdata/data/remote/auth_remote_data_source.dart';
import 'package:testgetdata/data/remote/public_remote_data_source.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';
import 'package:testgetdata/presentation/views/common/token_manager.dart';

class AuthProvider extends ChangeNotifier {
  final tokenManager = TokenManager();
  UserModel? _user;

  UserModel get user => _user!;
  List<SettingsModel> settings = [];

  Future<bool> register(String nama, String email, String password) async {
    try {
      bool? succes =
          await AuthRemoteDataSource().register(nama, email, password);
      // tokenManager.putToken(user.token);
      return succes;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeUserPhoto() async {
    user.gambar = null;
    notifyListeners();
  }

  Future<String> getCurrentVersion() async {
    try {
      // Ambil data dari PublicRemoteDataSource
      settings = await PublicRemoteDataSource().getSettings();

      // Cari 'version' di settings
      for (var setting in settings) {
        if (setting.nama == 'version') {
          return setting.nilai;
        }
      }

      // Jika tidak ditemukan, return kosong
      return "";
    } catch (e) {
      notifyListeners();
      return "";
    }
  }

  Future<bool> sendEmailForgetPassword(String email) async {
    try {
      final success =
          await AuthRemoteDataSource().sendEmailForgetPassword(email);
      return success;
    } catch (e) {
      print(e);
      return false;
    }
  }

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

  Future<bool> resendVerify(String email) async {
    try {
      final success = await AuthRemoteDataSource().resendVerify(email);
      return success;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<bool> resetPassword(String email, String password,
      String confirmPassword, String token) async {
    try {
      final success = await AuthRemoteDataSource()
          .resetPassword(email, password, confirmPassword, token);
      return success;
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
      return true;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<({bool success, UserModel? user})> authWithToken({
    void Function(dynamic)? errorCallback,
  }) async {
    try {
      UserModel result = await AuthRemoteDataSource().loginWithToken(
        (await tokenManager.getToken())!,
      );

      _user = result;
      tokenManager.putToken(result.token);
      notifyListeners();
      return (success: true, user: result);
    } on SocketException {
      errorCallback?.call("TUKU PAKTEAN SEK COKKKK");
      return (success: false, user: null);
    } catch (error) {
      errorCallback?.call(error);
      return (success: false, user: null);
    }
  }

  void setImage(String image) {
    _user?.gambar = image;
    notifyListeners();
  }

  Future<UserModel> authMe(String token) async {
    try {
      return await AuthRemoteDataSource().authMe(token);
    } catch (e) {
      rethrow;
    }
  }

  Future<({bool success, String? error})> updateTenantStatus(
      String token, bool status) async {
    try {
      final success =
          await TenantRemoteDataSource().updateTenantStatus(token, status);
      if (success.success) {
        _user?.isOnline = status;
        notifyListeners();
        return (success: true, error: null);
      }
      return (success: false, error: success.error);
    } catch (e) {
      return (success: false, error: e.toString());
    }
  }

  Future<void> fetchUserData(String token) async {
    try {
      _user = await AuthRemoteDataSource().fetchUserData(token);
      log("berhasil di get ");
      notifyListeners();
    } catch (e) {
      throw Exception('Error in provider: $e');
    }
  }
}
