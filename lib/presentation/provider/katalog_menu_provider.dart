import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/remote/menu_tenant_remote_data_source.dart';

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
      final fetchedData =
          await MenuTenantRemoteDataSource().getMenuTenant(token);
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
      bool result =
          await MenuTenantRemoteDataSource().deleteMenuTenant(token, menuId);
      if (result) {
        data.removeWhere((food) => food.id == menuId);
        fetchData(token);
      }
    } catch (e) {
      rethrow;
    }
  }
}
