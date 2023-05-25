import 'package:flutter/cupertino.dart';
import 'package:testgetdata/model/cart_model.dart';
import 'package:testgetdata/model/user_model.dart';

class UserProvider extends ChangeNotifier {
  var user;

  void setUserModel(UserModel user1) {
    user = user1;
    notifyListeners();
  }
}
