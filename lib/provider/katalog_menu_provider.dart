import 'package:flutter/material.dart';
import 'package:testgetdata/http/delete_menu_tenant.dart';
import 'package:testgetdata/http/fetch_katalog_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';

class KatalogMenuProvider extends ChangeNotifier {
  List<TenantFoods> data = [];
  // String bearerToken;
  bool isLoading = false;

  // KatalogMenuProvider({
  //   required this.bearerToken,
  // }) {
  //   fetchData();
  // }
  void setLoading(bool value) {
    isLoading = value;
    // notifyListeners();
  }

  Future<void> fetchData(String token) async {
    setLoading(true);
    try {
      final fetchedData = await fetchKatalogTenant(token);
      data = fetchedData.tenantFoods ?? [];
    } catch (error) {
    } finally {
      setLoading(false);
    }
  }

  Future<void> deleteFood(String token, int menuId) async {
    // bearerToken = token;
    // notifyListeners();
    try {
      bool result = await deleteMenu(token, menuId);
      if (result) {
        data.removeWhere((food) => food.id == menuId);
        fetchData(token);
      }
    } catch (e) {
      rethrow;
    }
  }
}
