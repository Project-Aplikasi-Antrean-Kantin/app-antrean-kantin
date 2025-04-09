import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:testgetdata/data/remote/add_transaksi.dart';
import 'package:testgetdata/data/remote/fetch_penjualan_offline.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/order_model.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';

class KasirProvider extends ChangeNotifier {
  List<TenantFoods> tenantFoodsList = [];
  bool isLoading = false;
  List<CartMenuModel> _cartItems = [];
  List<CartMenuModel> get cart => _cartItems;
  int totalItems = 0;
  int totalPrice = 0;
  int cartCost = 0;
  bool isCartVisible = false;
  String? paymentMethod = "cod";
  bool isOrderSuccessful = false;
  int deliveryStatus = 0;
  int roomId = 0;
  int serviceFee = 1000;
  bool _isCashier = false;
  bool get isKasir => _isCashier;

  void setIsKasir(bool value) {
    _isCashier = value;
    notifyListeners();
  }

  Future<void> fetchData(String token) async {
    isLoading = true;
    try {
      // await Future.delayed(const Duration(seconds: 1));
      final fetchedData = await fetchPenjualanOffline(token);
      tenantFoodsList = fetchedData.tenantFoods ?? [];
    } finally {
      isLoading = false;
    }
  }

  void addItemToCartOrUpdateQuantity(int menuId, String name, int price,
      String gambar, String deskripsi, bool isAdd) {
    var index = _cartItems.indexWhere((element) => menuId == element.menuId);

    if (index != -1) {
      _updateExistingItem(index, isAdd, price);
    } else if (isAdd) {
      addItemToCart(menuId, name, price, gambar, deskripsi);
    }

    isCartVisible = _cartItems.isNotEmpty;
    notifyListeners();
  }

  void _updateCartVisibility() {
    final newVisibility = totalItems > 0;
    if (isCartVisible != newVisibility) {
      isCartVisible = newVisibility;
      notifyListeners();
    }
  }

  void addItemToCart(
      int menuId, String name, int price, String gambar, String deskripsi) {
    _cartItems.add(CartMenuModel(
      menuId: menuId,
      count: 1,
      menuGambar: gambar,
      menuNama: name,
      menuPrice: price,
      deskripsi: deskripsi,
      catatan: '',
    ));
    totalItems++;
    cartCost += price;
  }

  void _updateExistingItem(int index, bool isAdd, int price) {
    _cartItems[index].isLoading = true;
    _cartItems[index].count =
        isAdd ? _cartItems[index].count + 1 : _cartItems[index].count - 1;
    totalItems += isAdd ? 1 : -1;
    cartCost += isAdd ? price : -price;
    if (_cartItems[index].count < 1) {
      _cartItems.removeAt(index);
    }
  }

  void clearCart() {
    _cartItems.clear();
    isCartVisible = false;
    cartCost = 0;
    totalItems = 0;
    notifyListeners();
  }

  void setMetodePembayaran(String metode) {
    paymentMethod = metode;
    notifyListeners();
  }

  Future<OrderModel> buatTransaksi(String token) {
    return addTransaksi(token, toJson());
  }

  String toJson() => jsonEncode({
        "biaya_layanan": 0,
        "status": "selesai",
        "isAntar": deliveryStatus,
        "total": totalPrice,
        "ruangan_id": roomId,
        "metode_pembayaran": paymentMethod,
        "ongkos_kirim": deliveryStatus == 1 ? jumlahMenu() * 0 : 0,
        "menus": _cartItems.map((x) => x.toJson()).toList(),
      });

  int jumlahMenu() =>
      cart.fold(0, (sum, element) => sum + element.count as int);

  int getTotal() {
    totalPrice = cartCost + serviceFee;
    log(totalPrice.toString());
    return totalPrice;
  }

  int getItemCount(int menuId) {
    final index = cart.indexWhere((item) => item.menuId == menuId);
    return index != -1 ? cart[index].count : 0;
  }
}
