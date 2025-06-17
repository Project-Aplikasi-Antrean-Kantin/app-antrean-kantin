import 'package:testgetdata/data/model/tenant_foods.dart';
import 'package:testgetdata/data/model/tenant_model.dart';

class MenusKelola {
  final int id;
  String? nama;
  final int harga;
  final String gambar;
  final int tenantId;
  final int menuId;
  final int isReady;
  final String namaMenu;
  final String kategoriMenu;
  final TenantModel tenants;
  final TenantFoods menus;
  String? deskripsi;

  MenusKelola({
    required this.id,
    this.nama,
    required this.harga,
    required this.gambar,
    required this.tenantId,
    required this.menuId,
    required this.isReady,
    required this.namaMenu,
    required this.kategoriMenu,
    required this.tenants,
    required this.menus,
    this.deskripsi,
  });

  factory MenusKelola.fromJson(Map<String, dynamic> json) => MenusKelola(
        id: json["id"],
        nama: json["nama"],
        harga: json["harga"],
        gambar: json["gambar"],
        tenantId: json["tenant_id"],
        menuId: json["menu_id"],
        isReady: json["isReady"],
        namaMenu: json["nama_menu"],
        kategoriMenu: json["kategori_menu"],
        deskripsi: json["deskripsi"],
        tenants: TenantModel.fromJson(json["tenants"]),
        menus: TenantFoods.fromJson(json["menus"]),
      );
}
