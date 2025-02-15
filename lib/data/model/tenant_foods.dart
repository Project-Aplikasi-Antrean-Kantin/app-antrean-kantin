import 'package:testgetdata/data/model/tenant_model.dart';

class TenantFoods {
  final int id;
  final String nama;
  final int kategoriId;
  final dynamic gambar;
  int isReady;
  final dynamic deskripsi;
  final int harga;
  final dynamic deletedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  int? tenantId;
  TenantModel? tenants;
  // DetailMenu? detailMenu;

  TenantFoods({
    required this.id,
    required this.nama,
    required this.kategoriId,
    required this.gambar,
    required this.isReady,
    required this.deskripsi,
    required this.harga,
    required this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tenantId,
    this.tenants,
    // this.detailMenu,
  });

  factory TenantFoods.fromJson(Map<String, dynamic> json) => TenantFoods(
        id: json["id"],
        nama: json["nama"],
        kategoriId: json["kategori_id"],
        // detailMenu: json["detail_menu"] != null
        //     ? DetailMenu.fromJson(json["detail_menu"])
        //     : null,
        gambar: json["gambar"],
        isReady: json["isReady"],
        deskripsi: json["deskripsi"],
        harga: json["harga"],
        deletedAt: json["deleted_at"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        tenantId: json["tenant_id"],
        tenants: json["tenants"] == null
            ? null
            : TenantModel.fromJson(json["tenants"]),
      );
}
