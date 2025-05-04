// import 'package:testgetdata/data/model/tenant_foods.dart';

// class TenantModel {
//   final int id;
//   final String namaTenant;
//   final String namaKavling;
//   final String gambar;
//   final int userId;
//   final String jamBuka;
//   final String jamTutup;
//   int? range;
//   final String? namaGambar;
//   final dynamic deletedAt;
//   final DateTime createdAt;
//   final DateTime updatedAt;
//   List<TenantFoods>? tenantFoods;
//   final bool? isOnline;

//   TenantModel({
//     required this.id,
//     required this.namaTenant,
//     required this.namaKavling,
//     required this.gambar,
//     required this.userId,
//     required this.jamBuka,
//     required this.jamTutup,
//     this.range,
//     required this.namaGambar,
//     required this.deletedAt,
//     required this.createdAt,
//     required this.updatedAt,
//     this.tenantFoods,
//     this.isOnline,
//   });

//   factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
//         id: json["id"],
//         namaTenant: json["nama_tenant"],
//         namaKavling: json["nama_kavling"],
//         gambar: json["gambar"],
//         userId: json["user_id"],
//         jamBuka: json["jam_buka"],
//         jamTutup: json["jam_tutup"],
//         range: json["range"],
//         // tenantFoods: List<TenantFoods>.from(
//         //   json["list_menu"].map(
//         //     (x) => TenantFoods.fromJson(x),
//         //   ),
//         // ),
//         tenantFoods: json["list_menu"] != null
//             ? List<TenantFoods>.from(
//                 json["list_menu"].map(
//                   (x) => TenantFoods.fromJson(x),
//                 ),
//               )
//             : [],
//         namaGambar: json["nama_gambar"] ?? '',
//         isOnline: json["pemilik"] != null
//             ? json["pemilik"]["isOnline"] == 1
//                 ? true
//                 : false
//             : null,
//         deletedAt: json["deleted_at"],
//         createdAt: DateTime.parse(json["created_at"]),
//         updatedAt: DateTime.parse(json["updated_at"]),
//       );
// }

import 'package:testgetdata/data/model/tenant_foods.dart';

class TenantModel {
  final int id;
  final String namaTenant;
  final String namaKavling;
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

  factory TenantModel.fromJson(Map<String, dynamic> json) => TenantModel(
        id: json["id"],
        namaTenant: json["nama_tenant"],
        namaKavling: json["nama_kavling"],
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
