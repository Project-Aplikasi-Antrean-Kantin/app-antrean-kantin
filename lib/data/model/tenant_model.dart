import 'package:testgetdata/data/model/tenant_foods.dart';

class TenantModel {
  final int id;
  final String namaTenant;
  final String namaKavling;
  String? nomorRekeningToko;
  String? nomorRekeningPribadi;
  final String gambar;
  final int userId;
  final String? jamBuka;
  final String? jamTutup;
  int? range;
  final String? namaGambar;
  final dynamic deletedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<TenantFoods>? tenantFoods;
  final bool? isOnline;

  TenantModel({
    required this.id,
    required this.namaTenant,
    required this.namaKavling,
    this.nomorRekeningToko,
    this.nomorRekeningPribadi,
    required this.gambar,
    required this.userId,
    this.jamBuka,
    this.jamTutup,
    this.range,
    this.namaGambar,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
    this.tenantFoods,
    this.isOnline,
  });
  TenantModel copyWith({
    int? id,
    String? namaTenant,
    String? namaKavling,
    String? nomorRekeningToko,
    String? nomorRekeningPribadi,
    String? gambar,
    int? userId,
    String? jamBuka,
    String? jamTutup,
    int? range,
    String? namaGambar,
    dynamic deletedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<TenantFoods>? tenantFoods,
    bool? isOnline,
  }) {
    return TenantModel(
      id: id ?? this.id,
      namaTenant: namaTenant ?? this.namaTenant,
      namaKavling: namaKavling ?? this.namaKavling,
      nomorRekeningToko: nomorRekeningToko ?? this.nomorRekeningToko,
      nomorRekeningPribadi: nomorRekeningPribadi ?? this.nomorRekeningPribadi,
      gambar: gambar ?? this.gambar,
      userId: userId ?? this.userId,
      jamBuka: jamBuka ?? this.jamBuka,
      jamTutup: jamTutup ?? this.jamTutup,
      range: range ?? this.range,
      namaGambar: namaGambar ?? this.namaGambar,
      deletedAt: deletedAt ?? this.deletedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tenantFoods: tenantFoods ?? this.tenantFoods,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
        id: json["id"],
        namaTenant: json["nama_tenant"],
        namaKavling: json["nama_kavling"],
        nomorRekeningToko: json["no_rekening_toko"],
        nomorRekeningPribadi: json["no_rekening_pribadi"],
        gambar: json["gambar"] ?? '',
        userId: json["user_id"],
        jamBuka: json["jam_buka"],
        jamTutup: json["jam_tutup"],
        range: json["range"],
        tenantFoods: json["list_menu"] != null
            ? List<TenantFoods>.from(
                json["list_menu"].map(
                  (x) => TenantFoods.fromJson(x),
                ),
              )
            : [],
        namaGambar: json["nama_gambar"],
        isOnline: json["pemilik"] != null
            ? json["pemilik"]["isOnline"] == 1
                ? true
                : false
            : null,
        deletedAt: json["deleted_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );
}
