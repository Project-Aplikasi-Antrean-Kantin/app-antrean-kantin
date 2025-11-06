import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testgetdata/data/model/cart_menu_modelllll.dart';
import 'package:testgetdata/data/model/cart_per_tenant.dart';

class CartLocalDataSource {
  Future<void> saveTenantCartToLocal(CartPerTenant cartPerTenant) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(cartPerTenant.toJson());
    await prefs.setString('cart_${cartPerTenant.tenantId}', encoded);
  }

  Future<CartPerTenant?> loadTenantCartFromLocal(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('cart_$tenantId');

    if (raw == null) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw);
      final cartMenuList = (decoded['cartMenuList'] as List<dynamic>)
          .map((e) => CartMenuModel.fromJson(e))
          .toList();

      return CartPerTenant(
        tenantId: decoded['tenantId'],
        tenantName: decoded['tenantName'],
        tenantGambar: decoded['tenantGambar'],
        cartMenuList: cartMenuList,
      );
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, CartPerTenant>> loadAllCartsToTenantMap() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    final cartKeys = keys.where((key) => key.startsWith('cart_')).toList();
    final Map<String, CartPerTenant> result = {};

    for (var key in cartKeys) {
      final raw = prefs.getString(key);
      if (raw != null) {
        try {
          final decoded = jsonDecode(raw);
          final cartMenuList = (decoded['cartMenuList'] as List<dynamic>)
              .map((e) => CartMenuModel.fromJson(e))
              .toList();

          final tenantId = decoded['tenantId'];

          result[tenantId] = CartPerTenant(
            tenantId: tenantId,
            tenantName: decoded['tenantName'],
            tenantGambar: decoded['tenantGambar'],
            cartMenuList: cartMenuList,
          );
        } catch (e) {
          debugPrint('Gagal decode cart untuk key: $key. Error: $e');
        }
      }
    }

    return result;
  }

  Future<void> clearCart(String tenantId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('cart_$tenantId');
  }
}
