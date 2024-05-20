import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'token';
  SharedPreferences? _sharedPreferences;

  Future<String?> getToken() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!.getString(_tokenKey);
  }

  Future<void> putToken(String token) async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    _sharedPreferences!.setString(_tokenKey, token);
  }

  Future<bool> clearToken() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return await _sharedPreferences!.clear();
  }
}
