import 'package:testgetdata/data/model/tenant_foods.dart';

class CartMenuModel {
  String? tenantName;
  int menuId;
  final String menuNama;
  final int menuPrice;
  final String menuGambar;
  String? catatan;
  int count;
  bool isLoading;
  String? deskripsi;

  CartMenuModel({
    this.tenantName,
    required this.menuId,
    required this.menuGambar,
    required this.menuNama,
    required this.menuPrice,
    this.deskripsi,
    required this.count,
    this.catatan,
    this.isLoading = false,
  });

  Map<String, dynamic> toJson() => {
        "id": menuId,
        "jumlah": count,
        "harga": menuPrice,
        "catatan": catatan,
      };
  CartMenuModel copyWith({
    int? menuId,
    String? name,
    int? count,
  }) {
    return CartMenuModel(
      menuPrice: this.menuPrice,
      menuGambar: this.menuGambar,
      menuId: menuId ?? this.menuId,
      menuNama: name ?? this.menuNama,
      count: count ?? this.count,
    );
  }

  static CartMenuModel fromTenantFoods({
    required TenantFoods tenantFoods,
    String? tenantName,
  }) {
    return CartMenuModel(
      menuId: tenantFoods.id,
      menuGambar: tenantFoods.gambar as String,
      menuNama: tenantFoods.nama,
      menuPrice: tenantFoods.harga,
      tenantName: tenantName,
      count: 1,
    );
  }

  @override
  String toString() {
    return 'CartMenuModel(menuId: $menuId, menuNama: $menuNama, menuPrice: $menuPrice, count: $count)';
  }
}
