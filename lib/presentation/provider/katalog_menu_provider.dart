// import 'package:flutter/material.dart';
// import 'package:testgetdata/data/model/tenant_foods.dart';
// import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';

// class KatalogMenuProvider extends ChangeNotifier {
//   List<TenantFoods> data = [];
//   bool isLoading = false;
//   String? errorMessage;

//   void setLoading(bool value) {
//     isLoading = value;
//     notifyListeners();
//   }

//   Future<void> fetchData(String token) async {
//     setLoading(true);
//     try {
//       final fetchedData = await TenantRemoteDataSource().getMenuTenant(token);
//       data = fetchedData.tenantFoods ?? [];
//       errorMessage = null;
//     } catch (error) {
//       errorMessage = 'Gagal memuat data: $error';
//       debugPrint(errorMessage);
//     } finally {
//       setLoading(false);
//       notifyListeners();
//     }
//   }

//   Future<void> deleteFood(String token, int menuId) async {
//     try {
//       final result =
//           await TenantRemoteDataSource().deleteMenuTenant(token, menuId);
//       if (result) {
//         data.removeWhere((food) => food.id == menuId);
//         notifyListeners();
//       } else {
//         throw Exception('Gagal menghapus menu');
//       }
//     } catch (e) {
//       debugPrint('Error deleting menu: $e');
//       rethrow;
//     }
//   }
// }

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
      debugPrint(errorMessage);
    } finally {
      setLoading(false);
      notifyListeners();
    }
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
      debugPrint('Error deleting menu: $e');
      throw Exception('Gagal menghapus menu: $e');
    }
  }
}
