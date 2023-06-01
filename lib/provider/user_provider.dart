import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:testgetdata/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  late UserModel user;

  void setUserModel(UserModel user1) {
    user = user1;
    putToken(user.token);
    notifyListeners();
  }

  Future<void> putToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", token);
    await prefs.setString("role", user.role);
    await prefs.setInt("id", user.id);
  }

  Future<String> get token async {
    print("Lagi ngeget token");
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, String> data = {
        "token": prefs.getString("token")!,
        "role": prefs.getString("role")!,
      };
      if (data['token'] == null) {
        return "";
      } else {
        return data['role']!;
      }
    } catch (e) {
      print(e.toString());
      return "";
    }
  }

  Future<int> get id async {
    print("Lagi ngeget token");
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.getInt("id")!;
    } catch (e) {
      print(e.toString());
      return -1;
    }
  }

  getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("token")!;
  }

  getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    var id = prefs.getInt("id")!;
    return prefs.getInt("id")!;
  }
}
