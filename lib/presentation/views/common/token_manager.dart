// import 'package:shared_preferences/shared_preferences.dart';

// class TokenManager {
//   static const _tokenKey = 'token';
//   SharedPreferences? _sharedPreferences;

//   Future<String?> getToken() async {
//     _sharedPreferences ??= await SharedPreferences.getInstance();
//     return _sharedPreferences!.getString(_tokenKey);
//   }

//   Future<void> putToken(String token) async {
//     _sharedPreferences ??= await SharedPreferences.getInstance();
//     _sharedPreferences!.setString(_tokenKey, token);
//   }

//   Future<bool> clearToken() async {
//     _sharedPreferences ??= await SharedPreferences.getInstance();
//     return await _sharedPreferences!.clear();
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const _tokenKey = 'token';

  SharedPreferences? _sharedPreferences;

  Future<SharedPreferences> _prefs() async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  Future<String?> getToken() async {
    final prefs = await _prefs();
    return prefs.getString(_tokenKey);
  }

  Future<void> putToken(String token) async {
    final prefs = await _prefs();
    prefs.setString(_tokenKey, token);
  }

  Future<void> saveRoles(List<String> roles) async {
    final prefs = await _prefs();
    await prefs.setStringList('roles', roles);
  }

  Future<List<String>> getRoles() async {
    final prefs = await _prefs();
    return prefs.getStringList('roles') ?? [];
  }

//   Future<bool> clearTokenAndRole() async {
//     final prefs = await _prefs();
//     return await prefs.clear();
//   }
  Future<void> clearTokenAndRole() async {
    final prefs = await _prefs();
    await prefs.remove('token');
    await prefs.remove('roles');
  }
}
