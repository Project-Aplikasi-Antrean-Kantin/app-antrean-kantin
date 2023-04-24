import 'package:flutter/cupertino.dart';
import 'package:testgetdata/model/cart_model.dart';

class CartProvider extends ChangeNotifier{
  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  int total = 0;
  int cost = 0;
  int service = 2000;
  bool isCartShow = false;

  void addRemove(menuId, name, price, gambar, tenantName, bool isAdd){
    //Jika sudah ada maka yang diupdate cuma count
    if(_cart.where((element) => menuId == element.menuId).isNotEmpty){
      var index = _cart.indexWhere((element) => menuId == element.menuId);
      // _cart[index].count = isAdd ? _cart[index].count + 1 : (_cart[index].count > 0) ? _cart[index].count - 1 : 0;

      if(isAdd){
        cart[index].count = _cart[index].count + 1;
        total += 1;
        getTotalBelanja(isAdd, _cart[index]);
      }else{
        if(_cart[index].count > 0){
          cart[index].count = _cart[index].count - 1;
          total -= 1;
          getTotalBelanja(isAdd, _cart[index]);
          if(cart[index].count < 1){
            _cart.remove(_cart[index]);
          }

        }else{
          _cart[index].count = 0;
          total = 0;
          // getTotalBelanja(isAdd, _cart[index]);
        }
      }
      if(total < 1){
        setBottomNavVisible(false);
      }
    }else{
      //jika belum ada di cart'
      if(isAdd){
        _cart.add(CartModel(menuId: menuId, count: 1, menuGambar: gambar, menuNama: name, menuPrice: price, tenantName: tenantName));
        setBottomNavVisible(true);
        total += 1;
        getTotalBelanja(isAdd, _cart[_cart.length-1]);
      }
    }
    notifyListeners();
  }

  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }

  getTotalBelanja(bool isAdd, CartModel cart){

    cost = isAdd ? cost + cart.menuPrice : cost - cart.menuPrice;
    // cost = 0;
    // isAdd ?
    // _cart.forEach((element) {
    //   cost += element.menuPrice;
    // }) : (total > 0) ?_cart.forEach((element) {
    //   cost -= element.menuPrice;
    // }) : cost = 0;
    // return cost;
  }
}