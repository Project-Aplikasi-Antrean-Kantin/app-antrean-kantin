import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:testgetdata/http/add_transaksi.dart';
import 'package:testgetdata/http/fetch_penjualan_offline.dart';
import 'package:testgetdata/model/cart_menu_modelllll.dart';
import 'package:testgetdata/model/order_model.dart';
import 'package:testgetdata/model/tenant_foods.dart';

class KasirProvider extends ChangeNotifier {
  List<TenantFoods> data = [];
  bool isLoading = false;
  List<CartMenuModel> _cartMenu = [];
  List<CartMenuModel> get cart => _cartMenu;
  int total = 0;
  int totalHarga = 0;
  int cost = 0;
  bool isCartShow = false;
  String? metodePembayaran = null;
  bool orderBerhasil = false;
  int isAntar = 0;
  int? ruanganId;
  int service = 0;
  // bool get isKasir => true;
  bool get isKasir => _isKasir;
  bool _isKasir = false;

  void setisKasir(bool value) {
    _isKasir = value;
    notifyListeners();
  }

  void setLoading(bool value) {
    isLoading = value;
    // notifyListeners();
  }

  Future<void> fetchData(String token) async {
    setLoading(true);
    try {
      final fetchedData = await fetchPenjualanOffline(token);
      data = fetchedData.tenantFoods ?? [];
    } catch (error) {
    } finally {
      setLoading(false);
    }
  }

  void addRemove(menuId, name, price, gambar, deskripsi, bool isAdd) {
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
      if (isAdd) {
        _cartMenu.add(
          CartMenuModel(
            menuId: menuId,
            count: 1,
            menuGambar: gambar,
            menuNama: name,
            menuPrice: price,
            deskripsi: deskripsi,
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

  getTotalBelanja(bool isAdd, CartMenuModel cart) {
    cost = isAdd ? cost + cart.menuPrice : cost - cart.menuPrice;
  }

  void setBottomNavVisible(bool value) {
    isCartShow = value;
    notifyListeners();
  }

  cekKatalogSudahAda(menuId) {
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

  setMetodePembayaran(String mtdpembayaran) {
    metodePembayaran = mtdpembayaran;
  }

  Future<OrderModel> buatTransaksi(context, String token) {
    print('sebelum add transaksi ' + toJson());
    orderBerhasil == true;
    notifyListeners();
    return addTransaksi(token, toJson());
  }

  String toJson() => jsonEncode(
        {
          "biaya_layanan": 0,
          "status": "selesai",
          "isAntar": isAntar,
          "total": totalHarga,
          "ruangan_id": ruanganId,
          "metode_pembayaran": metodePembayaran,
          // "ongkos_kirim": isAntar == 1 ? jumlahMenu() * 1000 : 0,
          // untuk coba prod midtrans
          "ongkos_kirim": isAntar == 1 ? jumlahMenu() * 0 : 0,
          "menus": List<dynamic>.from(_cartMenu.map((x) => x.toJson())),
        },
      );

  int jumlahMenu() {
    return cart.fold(
        0, (previousValue, element) => previousValue + element.count as int);
  }

  int getTotal() {
    if (isAntar == 0) {
      totalHarga = cost +
          service +
          (cart.fold(
                  0,
                  (previousValue, element) =>
                      previousValue + element.count as int) *
              0 /** coba prod midtrnas jadi 0, jika akan release ubah ke 1000**/);
    } else {
      totalHarga = cost + service;
    }
    return totalHarga;
  }
}
