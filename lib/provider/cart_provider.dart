import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:testgetdata/http/add_transaksi.dart';
import 'package:testgetdata/http/fetch_data_ruangan.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/model/order_model.dart';
import 'package:testgetdata/model/ruangan_model.dart';

class CartProvider extends ChangeNotifier {
  // CartProvider()

  List<CartMenuModel> _cartMenu = [];
  List<CartMenuModel> get cart => _cartMenu;
  List<Ruangan> listRuangan = [];

  int total = 0;
  int totalHarga = 0;
  int cost = 0;
  int service = 1000;
  bool isCartShow = false;
  int isAntar = 0;
  String? metodePembayaran = null;
  int? ruanganId; // todo : ganti ini

  void addRemove(
      menuId, name, price, gambar, tenantName, deskripsi, bool isAdd) {
    //Jika sudah ada maka yang diupdate cuma count
    if (_cartMenu.where((element) => menuId == element.menuId).isNotEmpty) {
      var index = _cartMenu.indexWhere((element) => menuId == element.menuId);
      if (isAdd) {
        _cartMenu[index].isLoading = true;
      } else {
        _cartMenu[index].isLoading = true;
      }
      if (isAdd) {
        cart[index].count = _cartMenu[index].count + 1;
        total += 1;
        getTotalBelanja(isAdd, _cartMenu[index]);
      } else {
        if (_cartMenu[index].count > 0) {
          cart[index].count = _cartMenu[index].count - 1;
          total -= 1;
          getTotalBelanja(isAdd, _cartMenu[index]);
          if (cart[index].count < 1) {
            _cartMenu.remove(_cartMenu[index]);
          }
        } else {
          _cartMenu[index].count = 0;
          total = 0;
        }
      }
      if (total < 1) {
        setBottomNavVisible(false);
      }
    } else {
      //jika belum ada di cart'
      if (isAdd) {
        _cartMenu.add(
          CartMenuModel(
            menuId: menuId,
            count: 1,
            menuGambar: gambar,
            menuNama: name,
            menuPrice: price,
            deskripsi: deskripsi,
            tenantName: tenantName,
            catatan: '',
          ),
        );
        setBottomNavVisible(true);
        total += 1;
        getTotalBelanja(isAdd, _cartMenu[_cartMenu.length - 1]);
      }
    }
    cekKatalogSudahAda(menuId);
    notifyListeners();
  }

  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }

  getTotalBelanja(bool isAdd, CartMenuModel cart) {
    cost = isAdd ? cost + cart.menuPrice : cost - cart.menuPrice;
  }

  cekKatalogSudahAda(menuId) {
    // var cartSudahAda = _cartMenu.length;
    // var index = _cartMenu.indexWhere((element) => menuId == element.menuId);
    if (_cartMenu.length == 0) {
      isCartShow = false;
    } else {
      isCartShow = true;
    }
    notifyListeners();
  }

  void clearCart() {
    _cartMenu = [];
    isCartShow = false;
    cost = 0;
    total = 0;
    notifyListeners();
  }

  int getTotal() {
    if (isAntar == 1) {
      totalHarga = cost +
          service +
          (cart.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element.count as int) *
              1000);
    } else {
      totalHarga = cost + service;
    }
    return totalHarga;
  }

  int jumlahMenu() {
    return cart.fold(
        0, (previousValue, element) => previousValue + element.count as int);
  }

  void tambahCatatan(menuId, catatan) {
    final cartSelected =
        _cartMenu.where((element) => element.menuId == menuId).toList()[0];
    cartSelected.catatan = catatan;
  }

  Future<OrderModel> buatTransaksi(context, String token) {
    print('isAntar : $isAntar');
    print('sebelum add transaksi ' + toJson());
    return addTransaksi(token, toJson());
  }

  String toJson() => jsonEncode(
        {
          "isAntar": isAntar,
          "total": totalHarga,
          "ruangan_id": ruanganId,
          "metode_pembayaran": metodePembayaran,
          "ongkos_kirim": isAntar == 1 ? jumlahMenu() * 1000 : 0,
          "menus": List<dynamic>.from(_cartMenu.map((x) => x.toJson())),
        },
      );

  setMetodePembayaran(String mtdpembayaran) {
    metodePembayaran = mtdpembayaran;
  }

  setIsAntar(int antar) {
    isAntar = antar;
  }

  setRuanganId(int idRuangan) {
    ruanganId = idRuangan;
  }

  void getRuangan(String token) async {
    listRuangan = await fetchDataRuangan(token);
  }
}
