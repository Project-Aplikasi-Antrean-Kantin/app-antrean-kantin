import 'package:provider/provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:testgetdata/model/cart_model.dart';

class CartProvider extends ChangeNotifier{
  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  int total = 0;
  bool isCartShow = false;

  void addRemove(menuId, bool isAdd){
    if(_cart.where((element) => menuId == element.menuId).isNotEmpty){
      var index = _cart.indexWhere((element) => menuId == element.menuId);
      _cart[index].count = isAdd ? _cart[index].count + 1 : (_cart[index].count > 0) ? _cart[index].count - 1 : 0;
      if(isAdd){
        setBottomNavVisible(true);
        total += 1;
      }else if(total > 0){
        total -= 1;
      }else{
        setBottomNavVisible(false);
      }
    }else{
      _cart.add(CartModel(menuId: menuId, count: 1));
      setBottomNavVisible(true);
      total += 1;
    }
    print(total);
    notifyListeners();
  }

  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }
}