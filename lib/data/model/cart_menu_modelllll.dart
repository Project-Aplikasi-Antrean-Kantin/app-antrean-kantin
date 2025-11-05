import 'package:testgetdata/data/model/tenant_foods.dart';

class CartMenuModel {
  int menuId;
  final String menuNama;
  int isReady;
  int kategoriId;
  int menuPrice;
  final String menuGambar;
  final String tenantId;
  String? catatan;
  int count;
  bool isLoading;
  String? deskripsi;

  CartMenuModel({
    required this.isReady,
    required this.tenantId,
    required this.kategoriId,
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
        "tenant_id": tenantId,
        "harga": menuPrice,
        "catatan": catatan,
        "menu_nama": menuNama,
        "menu_gambar": menuGambar,
        "kategori_id": kategoriId,
        "is_ready": isReady
      };
  CartMenuModel copyWith({
    int? menuId,
    String? name,
    int? count,
    String? catatan,
  }) {
    return CartMenuModel(
      tenantId: this.tenantId,
      kategoriId: this.kategoriId,
      isReady: this.isReady,
      menuPrice: this.menuPrice,
      menuGambar: this.menuGambar,
      catatan: catatan ?? this.catatan,
      menuId: menuId ?? this.menuId,
      menuNama: menuNama,
      count: count ?? this.count,
    );
  }

  static CartMenuModel fromTenantFoods({
    required TenantFoods tenantFoods,
    String? tenantName,
  }) {
    return CartMenuModel(
      tenantId: tenantFoods.tenantId.toString(),
      kategoriId: tenantFoods.kategoriId,
      isReady: tenantFoods.isReady,
      menuId: tenantFoods.id,
      menuGambar: tenantFoods.gambar ?? '', // fallback kalau null
      menuNama: tenantFoods.nama,
      menuPrice: tenantFoods.harga,
      count: 1,
    );
  }

  factory CartMenuModel.fromJson(Map<String, dynamic> json) {
    return CartMenuModel(
      tenantId: json['tenant_id'] ?? '',
      kategoriId: json['kategori_id'],
      isReady: json['is_ready'],
      menuId: json['id'],
      count: json['jumlah'],
      menuPrice: json['harga'],
      catatan: json['catatan'],
      menuNama: json['menu_nama'] ?? '', // fallback kosong
      menuGambar: json['menu_gambar'] ?? '', // fallback kosong
      deskripsi: json['deskripsi'],
    );
  }

  @override
  String toString() {
    return 'CartMenuModel(menuId: $menuId, isReady: $isReady, kategoriId: $kategoriId, menuNama: $menuNama, menuPrice: $menuPrice, count: $count menuGambar: $menuGambar catatan: $catatan)';
  }
}
