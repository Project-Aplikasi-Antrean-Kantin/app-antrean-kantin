import 'package:testgetdata/model/tenant_foods.dart';

class TenantModel {
  final int id;
  final String namaTenant;
  final String namaKavling;
  final String gambar;
  final int userId;
  final String jamBuka;
  final String jamTutup;
  int? range;
  List<TenantFoods>? tenantFoods;

  TenantModel({
    required this.id,
    required this.namaTenant,
    required this.namaKavling,
    required this.gambar,
    required this.userId,
    required this.jamBuka,
    required this.jamTutup,
    this.range,
    this.tenantFoods,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
        id: json["id"],
        namaTenant: json["nama_tenant"],
        namaKavling: json["nama_kavling"],
        gambar: json["gambar"],
        userId: json["user_id"],
        jamBuka: json["jam_buka"],
        jamTutup: json["jam_tutup"],
        range: json["range"],
        tenantFoods: List<TenantFoods>.from(
          json["list_menu"].map(
            (x) => TenantFoods.fromJson(x),
          ),
        ),
      );
}
