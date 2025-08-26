import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';
import 'package:testgetdata/data/remote/tenant_remote_data_source.dart';

class TenantProvider extends ChangeNotifier {
  TenantModel? _tenant;
  TenantModel? get tenant => _tenant;
  List<TenantFoods>? _tenantFoods;
  List<TenantFoods>? get tenantFoods => _tenantFoods;

  Future<void> fetchTenantData(String token) async {
    try {
      _tenant = await TenantRemoteDataSource().fetchTenantData(token);
      log("berhasil di get ");
      notifyListeners();
    } catch (e) {
      throw Exception('Error in provider: $e');
    }
  }

  Future<void> setTenantFoods(List<TenantFoods> tenantFoods) async {
    _tenantFoods = tenantFoods;
    notifyListeners();
  }

  Future<void> setTenant(TenantModel tenant) async {
    _tenant = tenant;
    notifyListeners();
  }

  TenantFoods? getTenantFoodById(int id) {
    return _tenantFoods?.firstWhere((food) => food.id == id, orElse: null);
  }
}
