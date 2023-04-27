import 'package:flutter/cupertino.dart';
import 'package:testgetdata/model/cart_model.dart';

class CartProvider extends ChangeNotifier {
  List<CartModel> _cart = [];
  List<CartModel> get cart => _cart;
  int total = 0;
  int cost = 0;
  bool isCartShow = false;
  bool isKatalogInCart = false;

  void addRemove(menuId, name, price, gambar, tenantName, bool isAdd) {
    //Jika sudah ada maka yang diupdate cuma count
    if (_cart.where((element) => menuId == element.menuId).isNotEmpty) {
      var index = _cart.indexWhere((element) => menuId == element.menuId);
      if (isAdd) {
        cart[index].count = _cart[index].count + 1;
        total += 1;
        getTotalBelanja(isAdd, _cart[index]);
      } else {
        if (_cart[index].count > 0) {
          cart[index].count = _cart[index].count - 1;
          total -= 1;
          getTotalBelanja(isAdd, _cart[index]);
          if (cart[index].count < 1) {
            _cart.remove(_cart[index]);
          }
        } else {
          _cart[index].count = 0;
          total = 0;
        }
      }
      if (total < 1) {
        setBottomNavVisible(false);
      }
    } else {
      //jika belum ada di cart'
      if (isAdd) {
        _cart.add(CartModel(
            menuId: menuId,
            count: 1,
            menuGambar: gambar,
            menuNama: name,
            menuPrice: price,
            tenantName: tenantName));
        setBottomNavVisible(true);
        total += 1;
        getTotalBelanja(isAdd, _cart[_cart.length - 1]);
      }
    }
    cekKatalogSudahAda(menuId);
    notifyListeners();
  }

  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }

  getTotalBelanja(bool isAdd, CartModel cart) {
    cost = isAdd ? cost + cart.menuPrice : cost - cart.menuPrice;
  }

  cekKatalogSudahAda(menuId) {
    var index = _cart.indexWhere((element) => menuId == element.menuId);
    if (index < 0) {
      isCartShow = false;
    } else {
      isCartShow = true;
    }
    notifyListeners();
  }
}
