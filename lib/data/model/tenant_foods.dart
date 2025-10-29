import 'package:testgetdata/data/model/tenant_model.dart';

class TenantFoods {
  final int id;
  final String nama;
  final int kategoriId;
  final dynamic gambar;
  int isReady;
  final dynamic deskripsi;
  final int harga;
  final DateTime? deletedAt;
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
    this.deletedAt,
    this.createdAt,
    this.updatedAt,
    this.tenantId,
    this.tenants,
    // this.detailMenu,
  });

  factory TenantFoods.fromJson(Map<String, dynamic> json) => TenantFoods(
        id: json["id"],
        nama: json["nama"] ?? json["nama_menu"],
        kategoriId: json["kategori_id"] ?? 0,
        // detailMenu: json["detail_menu"] != null
        //     ? DetailMenu.fromJson(json["detail_menu"])
        //     : null,
        gambar: json["gambar"],
        isReady: json["isReady"] ?? 0,
        deskripsi: json["deskripsi"],
        harga: json["harga"],
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.parse(json["deleted_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        tenantId: json["tenant_id"],
        tenants: json["tenants"] != null
            ? TenantModel.fromJson(json["tenants"])
            : json["tenant"] != null
                ? TenantModel.fromJson(json["tenant"])
                : null,
      );
  @override
  String toString() {
    return 'TenantFoods: $isReady';
  }
}
