import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';

class KatalogMenuProvider extends ChangeNotifier {
  List<TenantFoods> data = [];
  bool isLoading = false;
  String? errorMessage;

  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  Future<void> fetchData(String token) async {
    setLoading(true);
    try {
      final fetchedData = await TenantRemoteDataSource().getMenuTenant(token);
      data = fetchedData.tenantFoods ?? [];
      errorMessage = null;
    } catch (error) {
      errorMessage = 'Gagal memuat data: $error';
    } finally {
      setLoading(false);
      notifyListeners();
    }
  }

  void updateDataById(TenantFoods newData) {
    print("newData: $newData");
    final index = data.indexWhere((food) => food.id == newData.id);
    if (index != -1) {
      data[index] = newData;
      notifyListeners();
    }
  }

  Future<void> updateStatusReady(int menuId) async {
    final newData = data.firstWhere((food) => food.id == menuId);
    newData.isReady = newData.isReady == 1 ? 0 : 1;
    notifyListeners();
  }

  Future<bool> deleteFood(String token, int menuId) async {
    try {
      final result =
          await TenantRemoteDataSource().deleteMenuTenant(token, menuId);
      if (result) {
        data.removeWhere((food) => food.id == menuId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Gagal menghapus menu: $e');
    }
  }
}
