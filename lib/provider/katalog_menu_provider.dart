import 'package:flutter/material.dart';
import 'package:testgetdata/http/fetch_katalog_tenant.dart';
import 'package:testgetdata/model/tenant_foods.dart';

class KatalogMenuProvider extends ChangeNotifier {
  List<TenantFoods> data = [];
  final String bearerToken;
  bool isLoading = false;

  KatalogMenuProvider({
    required this.bearerToken,
  }) {
    fetchData();
  }
  void setLoading(bool value) {
    isLoading = value;
    notifyListeners();
  }

  void fetchData() async {
    setLoading(true);
    try {
      final fetchedData = await fetchKatalogTenant(bearerToken);
      data = fetchedData.tenantFoods ?? [];
    } catch (error) {
    } finally {
      setLoading(false);
    }
  }
}
