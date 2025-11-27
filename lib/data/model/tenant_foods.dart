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
        id: safeParseInt(json["id"]),
        kategoriId: safeParseInt(json["kategori_id"]),
        isReady: safeParseInt(json["isReady"]),
        harga: safeParseInt(json["harga"]),
        tenantId:
            json["tenant_id"] == null ? null : safeParseInt(json["tenant_id"]),
        nama: json["nama"] ?? json["nama_menu"],
        gambar: json["gambar"] ?? json["link_gambar"],
        deskripsi: json["deskripsi"],
        deletedAt: json["deleted_at"] == null
            ? null
            : DateTime.parse(json["deleted_at"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        tenants: json["tenants"] != null
            ? TenantModel.fromJson(json["tenants"])
            : json["tenant"] != null
                ? TenantModel.fromJson(json["tenant"])
                : null,
      );

  @override
  String toString() {
    return 'TenantFoods: $isReady tenants: $tenants id: $id nama: $nama kategoriId: $kategoriId gambar: $gambar isReady: $isReady deskripsi: $deskripsi harga: $harga deletedAt: $deletedAt createdAt: $createdAt updatedAt: $updatedAt tenantId: $tenantId';
  }

  static int safeParseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String && value.trim().isEmpty) return defaultValue;
    return int.tryParse(value.toString()) ?? defaultValue;
  }
}
